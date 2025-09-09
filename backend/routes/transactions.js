const express = require('express');
const Transaction = require('../models/Transaction');
const auth = require('../middleware/auth');

const router = express.Router();

// Get all transactions for user
router.get('/', auth, async (req, res) => {
  try {
    console.log('Fetching transactions for user:', req.user._id);
    
    const transactions = await Transaction.find({ userId: req.user._id.toString() })
      .sort({ date: -1, createdAt: -1 });
    
    console.log(`Found ${transactions.length} transactions`);
    res.json(transactions);
  } catch (error) {
    console.error('Error fetching transactions:', error);
    res.status(500).json({ error: 'Failed to fetch transactions' });
  }
});

// Create new transaction
router.post('/', auth, async (req, res) => {
  try {
    console.log('Creating transaction:', req.body);
    
    const { type, amount, category, description, date } = req.body;

    // Validation
    if (!type || !amount || !category) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    if (amount <= 0) {
      return res.status(400).json({ error: 'Amount must be greater than 0' });
    }

    const transaction = new Transaction({
      userId: req.user._id.toString(), // Convert to string
      type,
      amount: parseFloat(amount),
      category: category.trim(),
      description: description ? description.trim() : '',
      date: date ? new Date(date) : new Date()
    });

    await transaction.save();
    console.log('Transaction created successfully:', transaction._id);
    res.status(201).json(transaction);
  } catch (error) {
    console.error('Error creating transaction:', error);
    res.status(500).json({ error: 'Failed to create transaction' });
  }
});

// Update transaction
router.put('/:id', auth, async (req, res) => {
  try {
    console.log('Updating transaction:', req.params.id, req.body);
    
    const { type, amount, category, description, date } = req.body;
    const transactionId = req.params.id;

    // Validation
    if (amount && amount <= 0) {
      return res.status(400).json({ error: 'Amount must be greater than 0' });
    }

    const updateData = {};
    if (type) updateData.type = type;
    if (amount) updateData.amount = parseFloat(amount);
    if (category) updateData.category = category.trim();
    if (description !== undefined) updateData.description = description.trim();
    if (date) updateData.date = new Date(date);

    const transaction = await Transaction.findOneAndUpdate(
      { 
        _id: transactionId, 
        userId: req.user._id.toString() // Ensure user owns the transaction
      },
      updateData,
      { new: true, runValidators: true }
    );

    if (!transaction) {
      return res.status(404).json({ error: 'Transaction not found' });
    }

    console.log('Transaction updated successfully:', transaction._id);
    res.json(transaction);
  } catch (error) {
    console.error('Error updating transaction:', error);
    res.status(500).json({ error: 'Failed to update transaction' });
  }
});

// Delete transaction
router.delete('/:id', auth, async (req, res) => {
  try {
    console.log('Deleting transaction:', req.params.id);
    
    const transactionId = req.params.id;

    const transaction = await Transaction.findOneAndDelete({
      _id: transactionId,
      userId: req.user._id.toString() // Ensure user owns the transaction
    });

    if (!transaction) {
      return res.status(404).json({ error: 'Transaction not found' });
    }

    console.log('Transaction deleted successfully:', transactionId);
    res.json({ message: 'Transaction deleted successfully' });
  } catch (error) {
    console.error('Error deleting transaction:', error);
    res.status(500).json({ error: 'Failed to delete transaction' });
  }
});

// Get transaction by ID
router.get('/:id', auth, async (req, res) => {
  try {
    const transactionId = req.params.id;
    
    const transaction = await Transaction.findOne({
      _id: transactionId,
      userId: req.user._id.toString()
    });

    if (!transaction) {
      return res.status(404).json({ error: 'Transaction not found' });
    }

    res.json(transaction);
  } catch (error) {
    console.error('Error fetching transaction:', error);
    res.status(500).json({ error: 'Failed to fetch transaction' });
  }
});

// Get transaction summary
router.get('/summary', auth, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    let filter = { userId: req.user._id.toString() };
    
    if (startDate && endDate) {
      filter.date = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    }

    const transactions = await Transaction.find(filter);
    
    const totalIncome = transactions
      .filter(t => t.type === 'income')
      .reduce((sum, t) => sum + t.amount, 0);
    
    const totalExpense = transactions
      .filter(t => t.type === 'expense')
      .reduce((sum, t) => sum + t.amount, 0);
    
    const balance = totalIncome - totalExpense;

    // Category-wise breakdown
    const categoryBreakdown = {};
    transactions.forEach(transaction => {
      if (!categoryBreakdown[transaction.category]) {
        categoryBreakdown[transaction.category] = {
          income: 0,
          expense: 0,
          total: 0
        };
      }
      
      if (transaction.type === 'income') {
        categoryBreakdown[transaction.category].income += transaction.amount;
      } else {
        categoryBreakdown[transaction.category].expense += transaction.amount;
      }
      
      categoryBreakdown[transaction.category].total += 
        transaction.type === 'income' ? transaction.amount : -transaction.amount;
    });

    res.json({
      totalIncome,
      totalExpense,
      balance,
      transactionCount: transactions.length,
      categoryBreakdown
    });
  } catch (error) {
    console.error('Error generating summary:', error);
    res.status(500).json({ error: 'Failed to generate summary' });
  }
});

// Get transactions by date range
router.get('/range/date', auth, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Start date and end date are required' });
    }

    const transactions = await Transaction.find({
      userId: req.user._id.toString(),
      date: {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      }
    }).sort({ date: -1 });

    res.json(transactions);
  } catch (error) {
    console.error('Error fetching transactions by date range:', error);
    res.status(500).json({ error: 'Failed to fetch transactions' });
  }
});

module.exports = router;