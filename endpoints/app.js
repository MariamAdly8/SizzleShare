const express = require('express');
const app = express();
const recipeRoutes = require('./routers/recipeRoutes');
const userRoutes = require('./routers/userRoutes');
const commentRoutes = require('./routers/commentRoutes');
const mealPlannerRoutes = require('./routers/mealPlannerRoutes');
const adminRoutes = require('./routers/adminRoutes');
const cors = require('cors');
require('dotenv').config();
app.use(cors());

// Middleware
app.use(express.json());

// Serve static files from public directory
app.use(express.static('public'));

// Use routes
app.use('/api/recipes', recipeRoutes);
app.use('/api/users', userRoutes);
app.use('/api/comments', commentRoutes);
app.use('/api/mealplanner', mealPlannerRoutes);
app.use('/api/admin', adminRoutes);

// Serve the admin app
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/public/index.html');
});

module.exports = app;

