const express = require('express');
const router = express.Router();
const pool = require('../db');

// Get all properties
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM properties ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create a new property
router.post('/', async (req, res) => {
  const { title, type, price, location, description, image_url } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO properties (title, type, price, location, description, image_url)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [title, type, price, location, description, image_url]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
