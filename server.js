const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');

const app = express();
app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect('mongodb+srv://vasu:root@cluster0.71son.mongodb.net/?retryWrites=true&w=majority')
  .then(() => console.log('Connected to MongoDB successfully'))
  .catch(err => console.error('MongoDB connection error:', err));

// Add a test route for /api
app.get('/api', (req, res) => {
  res.json({ message: 'API is working!' });
});

// Add a test route for root
app.get('/', (req, res) => {
  res.json({ message: 'Server is running!' });
});

// User Schema
const userSchema = new mongoose.Schema({
  phone: { type: String, unique: true, required: true },
  password: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', userSchema);

// Check if user exists (for enabling/disabling login button)
app.post('/api/check-user', async (req, res) => {
  try {
    const { phone } = req.body;
    console.log('Checking user existence for phone:', phone);
    
    const user = await User.findOne({ phone });
    const exists = !!user;
    
    console.log('User exists:', exists);
    res.json({ exists });
  } catch (error) {
    console.error('Error checking user:', error);
    res.status(500).json({ error: error.message });
  }
});

// Login endpoint with improved error handling and logging
app.post('/api/login', async (req, res) => {
  try {
    const { phone, password } = req.body;
    console.log('Login attempt for phone:', phone); // Debug log

    // Validate input
    if (!phone || !password) {
      console.log('Missing credentials');
      return res.status(400).json({ error: 'Phone and password are required' });
    }

    // Find user
    const user = await User.findOne({ phone });
    console.log('User found:', !!user); // Debug log
    
    if (!user) {
      console.log('User not found');
      return res.status(404).json({ error: 'User not found' });
    }

    // Compare passwords
    const isValid = await bcrypt.compare(password, user.password);
    console.log('Password valid:', isValid); // Debug log

    if (!isValid) {
      console.log('Invalid password');
      return res.status(401).json({ error: 'Invalid password' });
    }

    // Success response
    console.log('Login successful for phone:', phone);
    res.json({ 
      success: true,
      message: 'Login successful',
      user: {
        phone: user.phone,
        createdAt: user.createdAt
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ 
      error: 'Login failed',
      details: error.message 
    });
  }
});

// Register new user
app.post('/api/register', async (req, res) => {
  try {
    console.log('Received registration request:', req.body); // Debug log

    const { phone, password } = req.body;

    // Validate input
    if (!phone || !password) {
      console.log('Missing required fields');
      return res.status(400).json({ error: 'Phone and password are required' });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ phone });
    if (existingUser) {
      console.log('User already exists:', phone);
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create new user
    const user = new User({
      phone: phone,
      password: hashedPassword
    });

    // Save user to database
    await user.save();
    console.log('New user registered successfully:', phone);
    
    // Send success response
    res.status(201).json({ 
      success: true,
      message: 'User registered successfully',
      phone: phone 
    });

  } catch (error) {
    console.error('Registration error:', error);
    
    // Send detailed error response
    if (error.code === 11000) {
      return res.status(400).json({ error: 'Phone number already registered' });
    }
    
    res.status(500).json({ 
      error: 'Registration failed',
      details: error.message 
    });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});