const express = require('express');
const Category = require('../models/Category');

const router = express.Router();

// Get all categories
router.get('/', async (req, res) => {
  try {
    const categories = await Category.find();
    res.json(categories);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create default categories (run once)
router.post('/default', async (req, res) => {
  try {
    const defaultCategories = [
      // Income categories
      { name: 'Salary', type: 'income', icon: '💼' },
      { name: 'Freelance', type: 'income', icon: '💻' },
      { name: 'Investment', type: 'income', icon: '📈' },
      { name: 'Gift', type: 'income', icon: '🎁' },
      { name: 'Other Income', type: 'income', icon: '💰' },
      
      // Expense categories
      { name: 'Food', type: 'expense', icon: '🍔' },
      { name: 'Transport', type: 'expense', icon: '🚗' },
      { name: 'Rent', type: 'expense', icon: '🏠' },
      { name: 'Utilities', type: 'expense', icon: '💡' },
      { name: 'Entertainment', type: 'expense', icon: '🎬' },
      { name: 'Healthcare', type: 'expense', icon: '🏥' },
      { name: 'Shopping', type: 'expense', icon: '🛒' },
      { name: 'Education', type: 'expense', icon: '📚' },
      { name: 'Other Expense', type: 'expense', icon: '💸' }
    ];

    await Category.deleteMany({});
    const categories = await Category.insertMany(defaultCategories);
    
    res.json({ message: 'Default categories created', categories });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;