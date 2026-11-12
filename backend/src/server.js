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

// --- APPLICATION MODEL (ISSUE #1) ---
const Application = mongoose.model('Application', new mongoose.Schema({
    jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job', required: true },
    workerId: { type: mongoose.Schema.Types.ObjectId, ref: 'WorkerProfile', required: true },
    clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' }
}, { timestamps: true }));

// --- AUTHENTICATION ROUTES ---
app.post('/api/register', async (req, res) => {
    try {
        const hashedPassword = await bcrypt.hash(req.body.password, 10);
        const user = await User.create({ ...req.body, password: hashedPassword });
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
    res.json({ token, user: { name: user.name, email: user.email, role: user.role } });
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

// --- WORKER ROUTES (With Matching Algorithm) ---
app.get('/api/workers', async (req, res) => {
    try {
        const { jobId } = req.query;
        const workers = await WorkerProfile.find().populate('userId', 'name');
        
        let job = null;
        if (jobId) {
            job = await Job.findById(jobId);
        }

        if (!job || !job.requiredSkills || job.requiredSkills.length === 0) {
            return res.json(workers.map(w => ({ ...w._doc, match: 0 })));
        }

        const matchedWorkers = workers.map(worker => {
            const workerSkills = worker.skills || [];
            const requiredSkills = job.requiredSkills;
            
            const matches = requiredSkills.filter(skill => workerSkills.includes(skill));
            const matchPercentage = Math.round((matches.length / requiredSkills.length) * 100);
            
            return { ...worker._doc, match: matchPercentage };
        });

        matchedWorkers.sort((a, b) => b.match - a.match);

        res.json(matchedWorkers);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- OFFER ROUTES (ISSUE #2) ---
app.post('/api/workers/shortlist', async (req, res) => {
    try {
        const { workerId, jobId, clientId } = req.body;
        const existingOffer = await Application.findOne({ workerId, jobId });
        if (existingOffer) return res.status(400).json({ error: "Offer already sent." });

        const newOffer = await Application.create({ workerId, jobId, clientId });
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

// --- SEED ROUTE (ISSUE #3) ---
app.get('/api/seed', async (req, res) => {
    try {
        await Job.deleteMany({});
        await WorkerProfile.deleteMany({});
        
        // Create a Test Client
        let client = await User.findOne({ email: "client@test.com" });
        if (!client) {
            client = await User.create({ name: "John Doe", email: "client@test.com", password: await bcrypt.hash("123", 10), role: "client" });
        }

        const job1 = await Job.create({ title: "Plumbing Repair", description: "Leaky sink", status: "Finding pros...", requiredSkills: ["Site Safety", "Blueprint Reading"] });
        const job2 = await Job.create({ title: "Electrical Wiring", description: "Fix the lights", status: "Finding pros...", requiredSkills: ["Problem Solving"] });
        
        // Create Workers with hashed passwords
        const w1 = await User.create({ name: "Marco Dela Cruz", email: "marco@test.com", password: await bcrypt.hash("123", 10), role: "worker" });
        const w2 = await User.create({ name: "Rafael Santos", email: "rafael@test.com", password: await bcrypt.hash("123", 10), role: "worker" });

        const worker1 = await WorkerProfile.create({ userId: w1._id, roleTitle: "Site Construction Supervisor", location: "Cagayan de Oro", skills: ["Site Safety", "Team Coordination"] });
        const worker2 = await WorkerProfile.create({ userId: w2._id, roleTitle: "Site Construction Supervisor", location: "Cagayan de Oro", skills: ["Blueprint Reading", "Problem Solving"] });

        // Create Test Offers
        await Application.create({ jobId: job1._id, workerId: worker1._id, clientId: client._id, status: 'pending' });
        await Application.create({ jobId: job2._id, workerId: worker2._id, clientId: client._id, status: 'accepted' });
        await Application.create({ jobId: job2._id, workerId: worker1._id, clientId: client._id, status: 'rejected' });

        res.json({ message: "Database Seeded! Test offers generated.", workerLogin: "marco@test.com / 123" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(PORT, () => {
    console.log(`🚀 Backend running on http://localhost:${PORT}`);
});