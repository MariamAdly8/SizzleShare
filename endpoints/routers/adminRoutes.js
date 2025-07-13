const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { authMiddleware, adminMiddleware } = require('../middleware/authMiddleware');

// Admin login
router.post('/login', adminController.loginAdmin);

// User management routes (requires admin authentication)
router.get('/users', authMiddleware, adminMiddleware, adminController.getAllUsers);
router.get('/users/:userId', authMiddleware, adminMiddleware, adminController.getUserById);
router.put('/ban-user/:userId', authMiddleware, adminMiddleware, adminController.banUser);
router.put('/unban-user/:userId', authMiddleware, adminMiddleware, adminController.unbanUser);

// Recipe management routes (requires admin authentication)
router.get('/pending-recipes', authMiddleware, adminMiddleware, adminController.getPendingRecipes);
router.put('/accept-recipe/:recipeId', authMiddleware, adminMiddleware, adminController.acceptRecipe);
router.put('/reject-recipe/:recipeId', authMiddleware, adminMiddleware, adminController.rejectRecipe);

module.exports = router; 