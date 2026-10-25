const express = require('express');
const router = express.Router();
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, '../../../data/dev/skillssharejob.db');
const db = new sqlite3.Database(dbPath);

// GET all jobs
router.get('/', (req, res) => {
  db.all("SELECT * FROM jobs", [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// POST a new job
router.post('/', (req, res) => {
  const { title, description, location, skill_required, schedule, expires_at } = req.body;
  
  const sql = `INSERT INTO jobs (title, description, location, skill_required, schedule, expires_at) VALUES (?, ?, ?, ?, ?, ?)`;
  const params = [title, description, location, skill_required, schedule, expires_at];

  db.run(sql, params, function(err) {
    if (err) return res.status(400).json({ error: err.message });
    res.status(201).json({
      id: this.lastID,
      title,
      message: "Job posted successfully"
    });
  });
});

module.exports = router;