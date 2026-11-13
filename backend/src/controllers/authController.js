const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const WorkerProfile = require('../models/WorkerProfile');

const register = async (req, res) => {
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
                roleTitle: 'Professional',
                location: 'Unknown',
                skills: []
            });
        }

        res.status(201).json({ message: 'User created successfully' });
    } catch (err) {
        res.status(400).json({ error: 'Email already exists' });
    }
};

const login = async (req, res) => {
    const user = await User.findOne({ email: req.body.email });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const validPass = await bcrypt.compare(req.body.password, user.password);
    if (!validPass) return res.status(400).json({ error: 'Invalid password' });

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
};

module.exports = { register, login };
