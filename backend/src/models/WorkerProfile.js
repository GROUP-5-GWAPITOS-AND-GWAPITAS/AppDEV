const mongoose = require('mongoose');

const WorkerProfile = mongoose.model('WorkerProfile', new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    roleTitle: String,
    location: String,
    skills: [String],
    shortlisted: { type: Boolean, default: false }
}));

module.exports = WorkerProfile;
