const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const transactionRoutes = require('./routes/transactions');
const categoryRoutes = require('./routes/categories');
const userRoutes = require('./routes/user');

const app = express();

// Get local IP address for better logging
const os = require('os');
const interfaces = os.networkInterfaces();
let localIp = 'localhost';

for (const interfaceName in interfaces) {
  for (const iface of interfaces[interfaceName]) {
    if (iface.family === 'IPv4' && !iface.internal) {
      localIp = iface.address;
      break;
    }
  }
}

// Enhanced CORS configuration for mobile devices
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:50255', // Flutter web
      'http://10.0.2.2:3000',   // Android emulator
      `http://${localIp}:3000`, // Your computer IP
      `http://${localIp}:50255`, // Your computer IP for web
      // Add any other domains you need
    ];
    
    // Allow all local network origins for development
    if (origin.includes('localhost') || 
        origin.includes('127.0.0.1') || 
        origin.includes('10.0.2.2') ||
        origin.includes(localIp) ||
        origin.match(/^http:\/\/192\.168\.\d+\.\d+:\d+$/)) { // Allow any 192.168.x.x IP
      return callback(null, true);
    }
    
    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    
    console.log('Blocked by CORS:', origin);
    const msg = 'The CORS policy for this site does not allow access from the specified Origin.';
    return callback(new Error(msg), false);
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: true
}));

// Enhanced middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  console.log('Origin:', req.headers.origin);
  console.log('User-Agent:', req.headers['user-agent']);
  if (Object.keys(req.body).length > 0) {
    console.log('Body:', req.body);
  }
  next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/user', userRoutes);

// Enhanced MongoDB Connection with better error handling
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/expense_tracker';

mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000, // Timeout after 5 seconds
  socketTimeoutMS: 45000, // Close sockets after 45 seconds of inactivity
})
.then(() => {
  console.log('MongoDB connected successfully');
  console.log('Database:', mongoose.connection.name);
})
.catch(err => {
  console.error('MongoDB connection error:', err);
  console.error('Connection URI:', MONGODB_URI);
  process.exit(1); // Exit process if DB connection fails
});

// MongoDB connection events
mongoose.connection.on('error', err => {
  console.error('MongoDB connection error:', err);
});

mongoose.connection.on('disconnected', () => {
  console.log('MongoDB disconnected');
});

mongoose.connection.on('reconnected', () => {
  console.log('MongoDB reconnected');
});

// Enhanced health check endpoint
app.get('/api/health', (req, res) => {
  const dbStatus = mongoose.connection.readyState;
  const dbStatusMessage = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnecting'
  }[dbStatus] || 'unknown';

  res.json({ 
    message: 'Server is running', 
    timestamp: new Date().toISOString(),
    database: {
      status: dbStatusMessage,
      name: mongoose.connection.name,
      host: mongoose.connection.host
    },
    network: {
      local: `http://localhost:${PORT}`,
      network: `http://${localIp}:${PORT}`
    },
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

// Test endpoint for debugging
app.get('/api/debug', (req, res) => {
  res.json({
    headers: req.headers,
    query: req.query,
    body: req.body,
    timestamp: new Date().toISOString()
  });
});

// Connection test endpoint for mobile devices
app.get('/api/connection-test', (req, res) => {
  res.json({
    success: true,
    message: 'Connection successful',
    serverTime: new Date().toISOString(),
    clientIP: req.ip,
    clientHeaders: req.headers
  });
});

// Enhanced error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ 
    error: 'Internal server error',
    message: err.message,
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Endpoint not found',
    path: req.originalUrl,
    method: req.method,
    timestamp: new Date().toISOString()
  });
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down gracefully...');
  await mongoose.connection.close();
  console.log('MongoDB connection closed.');
  process.exit(0);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Local: http://localhost:${PORT}/api/health`);
  console.log(`🌐 Network: http://${localIp}:${PORT}/api/health`);
  console.log(`🐛 Debug endpoint: http://localhost:${PORT}/api/debug`);
  console.log(`🔗 MongoDB URI: ${MONGODB_URI}`);
  console.log(`📱 Mobile test: http://${localIp}:${PORT}/api/connection-test`);
});

// Export for testing
module.exports = app;