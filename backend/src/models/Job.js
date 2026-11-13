const mongoose = require('mongoose');

const Job = mongoose.model('Job', new mongoose.Schema({
    title: { type: String, required: true },
    description: String,
    location: { type: String, default: 'Your home' },
    status: { type: String, default: 'Finding pros...' },
    requiredSkills: [String],
    clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
}));

module.exports = Job;
