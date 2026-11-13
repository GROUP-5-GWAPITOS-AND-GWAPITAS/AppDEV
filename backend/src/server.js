const dns = require('dns');
dns.setServers(['8.8.8.8']);

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const jobRoutes = require('./routes/jobRoutes');
const workerRoutes = require('./routes/workerRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api', authRoutes);
app.use('/api', jobRoutes);
app.use('/api', workerRoutes);

connectDB().catch((err) => {
    console.error('❌ DB Error: ', err);
});

app.listen(PORT, () => {
    console.log(`🚀 Backend running on http://localhost:${PORT}`);
});
