const express = require('express');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors()); // Allows Flutter to talk to the backend
app.use(express.json()); // Allows the backend to read JSON data

// A simple test route
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'SkillsShareJob API is healthy' });
});

// We will add the jobs and workers routes here later

module.exports = app;