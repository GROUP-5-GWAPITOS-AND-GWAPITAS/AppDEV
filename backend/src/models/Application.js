const mongoose = require('mongoose');

const Application = mongoose.model('Application', new mongoose.Schema({
    jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job', required: true },
    workerId: { type: mongoose.Schema.Types.ObjectId, ref: 'WorkerProfile', required: true },
    clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
    initiatedBy: { type: String, enum: ['client', 'worker'], default: 'client' }
}, { timestamps: true }));

module.exports = Application;
