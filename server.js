const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');

const app = express();
app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect('mongodb+srv://vasu:null@cluster0.71son.mongodb.net/?retryWrites=true&w=majority')
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
  phone: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
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

// Register endpoint with detailed logging
app.post('/api/register', async (req, res) => {
  try {
    console.log('Register request received');
    console.log('Request body:', req.body);
    console.log('Phone:', req.body.phone);
    console.log('Password:', req.body.password);

    const { phone, password } = req.body;

    // Detailed validation
    if (!req.body) {
      return res.status(400).json({ error: 'Request body is empty' });
    }

    if (!phone) {
      return res.status(400).json({ error: 'Phone number is required' });
    }

    if (!password) {
      return res.status(400).json({ error: 'Password is required' });
    }

    // Check if user exists
    const existingUser = await User.findOne({ phone });
    if (existingUser) {
      return res.status(400).json({ error: 'Phone number already registered' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user
    const user = new User({
      phone,
      password: hashedPassword
    });

    await user.save();
    console.log('User registered successfully:', phone);
    
    res.json({ 
      success: true, 
      message: 'Registration successful',
      phone: phone
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed', details: error.message });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});