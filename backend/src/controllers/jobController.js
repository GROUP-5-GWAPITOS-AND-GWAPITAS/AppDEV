const Job = require('../models/Job');
const User = require('../models/User');
const WorkerProfile = require('../models/WorkerProfile');
const Application = require('../models/Application');
const bcrypt = require('bcryptjs');

const getJobs = async (req, res) => {
    const jobs = await Job.find();
    res.json(jobs);
};

const postJob = async (req, res) => {
    const newJob = await Job.create(req.body);
    res.status(201).json(newJob);
};

const seedData = async (req, res) => {
    try {
        await Job.deleteMany({});
        await WorkerProfile.deleteMany({});
        await Application.deleteMany({});
        await User.deleteMany({ email: { $in: ['marco@test.com', 'rafael@test.com', 'client@test.com'] } });

        const client = await User.create({
            name: 'John Doe',
            email: 'client@test.com',
            password: await bcrypt.hash('123', 10),
            role: 'client'
        });

        const job1 = await Job.create({
            title: 'Plumbing Repair',
            description: 'Leaky sink',
            status: 'Finding pros...',
            requiredSkills: ['Site Safety', 'Blueprint Reading'],
            clientId: client._id
        });
        const job2 = await Job.create({
            title: 'Electrical Wiring',
            description: 'Fix the lights',
            status: 'Finding pros...',
            requiredSkills: ['Problem Solving'],
            clientId: client._id
        });

        const w1 = await User.create({
            name: 'Marco Dela Cruz',
            email: 'marco@test.com',
            password: await bcrypt.hash('123', 10),
            role: 'worker'
        });
        const w2 = await User.create({
            name: 'Rafael Santos',
            email: 'rafael@test.com',
            password: await bcrypt.hash('123', 10),
            role: 'worker'
        });

        const worker1 = await WorkerProfile.create({
            userId: w1._id,
            roleTitle: 'Site Construction Supervisor',
            location: 'Cagayan de Oro',
            skills: ['Site Safety', 'Team Coordination']
        });
        const worker2 = await WorkerProfile.create({
            userId: w2._id,
            roleTitle: 'Site Construction Supervisor',
            location: 'Cagayan de Oro',
            skills: ['Blueprint Reading', 'Problem Solving']
        });

        await Application.create({
            jobId: job1._id,
            workerId: worker1._id,
            clientId: client._id,
            status: 'pending',
            initiatedBy: 'client'
        });
        await Application.create({
            jobId: job2._id,
            workerId: worker2._id,
            clientId: client._id,
            status: 'accepted',
            initiatedBy: 'client'
        });
        await Application.create({
            jobId: job2._id,
            workerId: worker1._id,
            clientId: client._id,
            status: 'rejected',
            initiatedBy: 'worker'
        });

        res.json({ message: 'Database Seeded! Test offers generated.', workerLogin: 'marco@test.com / 123' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

module.exports = { getJobs, postJob, seedData };
