const express = require('express');
const { getJobs, postJob, seedData } = require('../controllers/jobController');

const router = express.Router();

router.get('/jobs', getJobs);
router.post('/jobs', postJob);
router.get('/seed', seedData);

module.exports = router;
