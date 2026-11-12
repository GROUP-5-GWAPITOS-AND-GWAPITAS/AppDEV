const dns = require('dns');
dns.setServers(['8.8.8.8', '8.8.4.4']);

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// --- DATABASE CONNECTION ---
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch((err) => console.log('❌ DB Error: ', err));

// --- MODELS ---
const User = mongoose.model('User', new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, default: 'client' } 
}));

const Job = mongoose.model('Job', new mongoose.Schema({
    title: { type: String, required: true },
    description: String,
    location: { type: String, default: "Your home" },
    status: { type: String, default: "Finding pros..." },
    requiredSkills: [String],
    clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
}));

const WorkerProfile = mongoose.model('WorkerProfile', new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    roleTitle: String,
    location: String,
    skills: [String],
    shortlisted: { type: Boolean, default: false }
}));

// --- UPDATED APPLICATION MODEL ---
const Application = mongoose.model('Application', new mongoose.Schema({
    jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job', required: true },
    workerId: { type: mongoose.Schema.Types.ObjectId, ref: 'WorkerProfile', required: true },
    clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
    initiatedBy: { type: String, enum: ['client', 'worker'], default: 'client' } 
}, { timestamps: true }));

// --- AUTHENTICATION ROUTES ---
app.post('/api/register', async (req, res) => {
    try {
        const hashedPassword = await bcrypt.hash(req.body.password, 10);
        const user = await User.create({ 
            name: req.body.name,
            email: req.body.email,
            password: hashedPassword,
            role: req.body.role || 'client' 
        });

        if (user.role === 'worker') {
            await WorkerProfile.create({ 
                userId: user._id, 
                roleTitle: "Professional", 
                location: "Unknown", 
                skills: [] 
            });
        }

        res.status(201).json({ message: "User created successfully" });
    } catch (err) {
        res.status(400).json({ error: "Email already exists" });
    }
});

app.post('/api/login', async (req, res) => {
    const user = await User.findOne({ email: req.body.email });
    if (!user) return res.status(404).json({ error: "User not found" });

    const validPass = await bcrypt.compare(req.body.password, user.password);
    if (!validPass) return res.status(400).json({ error: "Invalid password" });

    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET);
    
    let workerProfileId = null;
    if (user.role === 'worker') {
        const profile = await WorkerProfile.findOne({ userId: user._id });
        if (profile) workerProfileId = profile._id;
    }

    res.json({ 
        token, 
        user: { 
            id: user._id.toString(),
            name: user.name, 
            email: user.email, 
            role: user.role,
            workerProfileId: workerProfileId ? workerProfileId.toString() : null
        } 
    });
});

// --- JOB ROUTES ---
app.get('/api/jobs', async (req, res) => {
    const jobs = await Job.find();
    res.json(jobs);
});

app.post('/api/jobs', async (req, res) => {
    const newJob = await Job.create(req.body);
    res.status(201).json(newJob);
});

// --- WORKER ROUTES ---
app.get('/api/worker/all-jobs', async (req, res) => {
    try {
        const jobs = await Job.find().populate('clientId', 'name');
        res.json(jobs);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/workers', async (req, res) => {
    try {
        const { jobId } = req.query;
        const workers = await WorkerProfile.find().populate('userId', 'name');
        
        let job = null;
        if (jobId) job = await Job.findById(jobId);

        if (!job || !job.requiredSkills || job.requiredSkills.length === 0) {
            return res.json(workers.map(w => ({ ...w._doc, match: 0 })));
        }

        const matchedWorkers = workers.map(worker => {
            const workerSkills = worker.skills || [];
            const matches = job.requiredSkills.filter(skill => workerSkills.includes(skill));
            const matchPercentage = Math.round((matches.length / job.requiredSkills.length) * 100);
            return { ...worker._doc, match: matchPercentage };
        });

        matchedWorkers.sort((a, b) => b.match - a.match);
        res.json(matchedWorkers);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/worker/profile/:workerId', async (req, res) => {
    try {
        const { roleTitle, location, skills } = req.body;
        const updatedProfile = await WorkerProfile.findByIdAndUpdate(
            req.params.workerId,
            { roleTitle, location, skills },
            { new: true }
        );
        res.json({ message: "Profile updated successfully", profile: updatedProfile });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- OFFER ROUTES ---
app.post('/api/workers/shortlist', async (req, res) => {
    try {
        const { workerId, jobId, clientId } = req.body;
        const existingOffer = await Application.findOne({ workerId, jobId });
        if (existingOffer) return res.status(400).json({ error: "Offer already sent." });

        const newOffer = await Application.create({ workerId, jobId, clientId, initiatedBy: 'client' });
        res.status(201).json({ message: "Offer sent successfully", offer: newOffer });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/worker/offers/:workerId', async (req, res) => {
    try {
        const offers = await Application.find({ workerId: req.params.workerId })
            .populate('jobId')
            .populate('clientId', 'name');
        res.json(offers);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/worker/apply', async (req, res) => {
    try {
        const { workerId, jobId, clientId } = req.body;
        const existing = await Application.findOne({ workerId, jobId });
        if (existing) return res.status(400).json({ error: "You already applied for this job." });

        const newApplication = await Application.create({ 
            workerId, jobId, clientId, 
            initiatedBy: 'worker',
            status: 'pending' 
        });
        res.status(201).json({ message: "Application sent to client!", application: newApplication });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/client/applications/:clientId', async (req, res) => {
    try {
        const applications = await Application.find({ clientId: req.params.clientId })
            .populate('jobId')
            .populate({ path: 'workerId', populate: { path: 'userId', select: 'name' } });
        res.json(applications);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/worker/offers/:offerId/respond', async (req, res) => {
    try {
        const { status } = req.body;
        if (!['accepted', 'rejected'].includes(status)) return res.status(400).json({ error: "Invalid status" });
        const offer = await Application.findByIdAndUpdate(req.params.offerId, { status }, { new: true });
        res.json({ message: `Offer ${status}`, offer });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- SEED ROUTE ---
app.get('/api/seed', async (req, res) => {
    try {
        await Job.deleteMany({});
        await WorkerProfile.deleteMany({});
        await Application.deleteMany({});
        await User.deleteMany({ email: { $in: ["marco@test.com", "rafael@test.com", "client@test.com"] } }); 
        
        let client = await User.create({ name: "John Doe", email: "client@test.com", password: await bcrypt.hash("123", 10), role: "client" });

        const job1 = await Job.create({ title: "Plumbing Repair", description: "Leaky sink", status: "Finding pros...", requiredSkills: ["Site Safety", "Blueprint Reading"], clientId: client._id });
        const job2 = await Job.create({ title: "Electrical Wiring", description: "Fix the lights", status: "Finding pros...", requiredSkills: ["Problem Solving"], clientId: client._id });
        
        const w1 = await User.create({ name: "Marco Dela Cruz", email: "marco@test.com", password: await bcrypt.hash("123", 10), role: "worker" });
        const w2 = await User.create({ name: "Rafael Santos", email: "rafael@test.com", password: await bcrypt.hash("123", 10), role: "worker" });

        const worker1 = await WorkerProfile.create({ userId: w1._id, roleTitle: "Site Construction Supervisor", location: "Cagayan de Oro", skills: ["Site Safety", "Team Coordination"] });
        const worker2 = await WorkerProfile.create({ userId: w2._id, roleTitle: "Site Construction Supervisor", location: "Cagayan de Oro", skills: ["Blueprint Reading", "Problem Solving"] });

        await Application.create({ jobId: job1._id, workerId: worker1._id, clientId: client._id, status: 'pending', initiatedBy: 'client' });
        await Application.create({ jobId: job2._id, workerId: worker2._id, clientId: client._id, status: 'accepted', initiatedBy: 'client' });
        await Application.create({ jobId: job2._id, workerId: worker1._id, clientId: client._id, status: 'rejected', initiatedBy: 'worker' });

        res.json({ message: "Database Seeded! Test offers generated.", workerLogin: "marco@test.com / 123" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(PORT, () => {
    console.log(`🚀 Backend running on http://localhost:${PORT}`);
});