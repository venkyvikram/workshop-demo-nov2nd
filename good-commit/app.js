const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const validator = require('validator');

// Secrets from environment — never from source code
const { IBM_API_KEY, DB_PASSWORD } = require('./config');

const app = express();

// FIXED: Security headers on every response
app.use(helmet());

// FIXED: Rate limiting — prevents OWASP API Top 10 #4 (resource exhaustion)
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 100,                   // max 100 requests per window per IP
  message: 'Too many requests, please try again later.'
});
app.use(limiter);

// FIXED: Input is validated and sanitised before use
app.get('/search', (req, res) => {
  const query = req.query.q;

  if (!query || !validator.isLength(query, { min: 1, max: 100 })) {
    return res.status(400).json({ error: 'Invalid search query.' });
  }

  // Sanitise — strip HTML tags to prevent XSS
  const safeQuery = validator.escape(query);
  res.json({ results: [], query: safeQuery });
});

// FIXED: Admin endpoint requires authentication header
app.get('/admin', (req, res) => {
  const token = req.headers['authorization'];
  if (!token || !token.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized.' });
  }
  // Token validation would happen here (e.g. IBM App ID token check)
  res.json({ message: 'Admin access granted.' });
});

// FIXED: Bind to localhost only — not all interfaces
app.listen(3000, '127.0.0.1', () => {
  // FIXED: Never log secrets
  console.log('App running on port 3000 (localhost only)');
  console.log('Secrets loaded: IBM_API_KEY =', IBM_API_KEY ? '[SET]' : '[MISSING]');
});
