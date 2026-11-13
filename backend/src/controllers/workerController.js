const Job = require('../models/Job');
const WorkerProfile = require('../models/WorkerProfile');
const Application = require('../models/Application');

const getAllJobs = async (req, res) => {
    try {
        const jobs = await Job.find().populate('clientId', 'name');
        res.json(jobs);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const getWorkers = async (req, res) => {
    try {
        const { jobId } = req.query;
        const workers = await WorkerProfile.find().populate('userId', 'name');

        let job = null;
        if (jobId) job = await Job.findById(jobId);

        if (!job || !job.requiredSkills || job.requiredSkills.length === 0) {
            return res.json(workers.map((worker) => ({ ...worker._doc, match: 0 })));
        }

        const matchedWorkers = workers.map((worker) => {
            const workerSkills = worker.skills || [];
            const matches = job.requiredSkills.filter((skill) => workerSkills.includes(skill));
            const matchPercentage = Math.round((matches.length / job.requiredSkills.length) * 100);
            return { ...worker._doc, match: matchPercentage };
        });

        matchedWorkers.sort((a, b) => b.match - a.match);
        res.json(matchedWorkers);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const updateProfile = async (req, res) => {
    try {
        const { roleTitle, location, skills } = req.body;
        const updatedProfile = await WorkerProfile.findByIdAndUpdate(
            req.params.workerId,
            { roleTitle, location, skills },
            { new: true }
        );
        res.json({ message: 'Profile updated successfully', profile: updatedProfile });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const shortlistWorker = async (req, res) => {
    try {
        const { workerId, jobId, clientId } = req.body;
        const existingOffer = await Application.findOne({ workerId, jobId });
        if (existingOffer) return res.status(400).json({ error: 'Offer already sent.' });

        const newOffer = await Application.create({ workerId, jobId, clientId, initiatedBy: 'client' });
        res.status(201).json({ message: 'Offer sent successfully', offer: newOffer });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const getOffers = async (req, res) => {
    try {
        const offers = await Application.find({ workerId: req.params.workerId })
            .populate('jobId')
            .populate('clientId', 'name');
        res.json(offers);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const applyForJob = async (req, res) => {
    try {
        const { workerId, jobId, clientId } = req.body;
        const existing = await Application.findOne({ workerId, jobId });
        if (existing) return res.status(400).json({ error: 'You already applied for this job.' });

        const newApplication = await Application.create({
            workerId,
            jobId,
            clientId,
            initiatedBy: 'worker',
            status: 'pending'
        });
        res.status(201).json({ message: 'Application sent to client!', application: newApplication });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const getClientApplications = async (req, res) => {
    try {
        const applications = await Application.find({ clientId: req.params.clientId })
            .populate('jobId')
            .populate({ path: 'workerId', populate: { path: 'userId', select: 'name' } });
        res.json(applications);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const respondToOffer = async (req, res) => {
    try {
        const { status } = req.body;
        if (!['accepted', 'rejected'].includes(status)) {
            return res.status(400).json({ error: 'Invalid status' });
        }
        const offer = await Application.findByIdAndUpdate(req.params.offerId, { status }, { new: true });
        res.json({ message: `Offer ${status}`, offer });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = {
    getAllJobs,
    getWorkers,
    updateProfile,
    shortlistWorker,
    getOffers,
    applyForJob,
    getClientApplications,
    respondToOffer
};
