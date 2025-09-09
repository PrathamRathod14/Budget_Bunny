// backend/routes/user.js
const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();

// Get user profile
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password');
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update user profile
router.put('/profile', auth, async (req, res) => {
  try {
    const { name, email, phone } = req.body;
    
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { name, email, phone },
      { new: true, runValidators: true }
    ).select('-password');
    
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user settings
router.get('/settings', auth, async (req, res) => {
  try {
    // Return default settings for now
    res.json({
      notificationsEnabled: true,
      biometricsEnabled: false,
      currency: 'USD',
      themeMode: 'Light'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update user settings
router.put('/settings', auth, async (req, res) => {
  try {
    // For now, just return the received settings
    res.json(req.body);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;