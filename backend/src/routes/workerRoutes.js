const express = require('express');
const {
    getAllJobs,
    getWorkers,
    updateProfile,
    shortlistWorker,
    getOffers,
    applyForJob,
    getClientApplications,
    respondToOffer
} = require('../controllers/workerController');

const router = express.Router();

router.get('/worker/all-jobs', getAllJobs);
router.get('/workers', getWorkers);
router.put('/worker/profile/:workerId', updateProfile);
router.post('/workers/shortlist', shortlistWorker);
router.get('/worker/offers/:workerId', getOffers);
router.post('/worker/apply', applyForJob);
router.get('/client/applications/:clientId', getClientApplications);
router.post('/worker/offers/:offerId/respond', respondToOffer);

module.exports = router;
