const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');

const app = express();
app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect('mongodb+srv://vasu:vasu123@cluster0.71son.mongodb.net/?retryWrites=true&w=majority')
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

// Login endpoint
app.post('/api/login', async (req, res) => {
  try {
    const { phone, password } = req.body;
    const user = await User.findOne({ phone });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid password' });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Register new user
app.post('/api/register', async (req, res) => {
  try {
    const { phone, password } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ phone });
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create new user
    const user = new User({
      phone,
      password: hashedPassword
    });

    await user.save();
    console.log('New user registered:', phone);
    res.json({ success: true });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});