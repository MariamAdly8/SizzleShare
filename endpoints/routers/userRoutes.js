const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authMiddleware } = require('../middleware/authMiddleware');
 
// Public routes
router.post('/login', userController.loginUser);
router.post('/signup', userController.signupUser);
router.post('/verify-email', userController.verifyEmail);
 router.post('/resend-verification-code', userController.resendVerificationCode);
// Protected routes - require authentication
router.use(authMiddleware); // Apply auth middleware to all routes below


router.get('/all', userController.getAllUsers);
router.patch('/update', userController.updateUser);
router.delete('/delete', userController.deleteUser);

// Shopping list routes
router.post('/shopping-list/add', userController.addToShoppingList);
router.delete('/shopping-list/remove', userController.removeFromShoppingList);
router.get('/shopping-list', userController.getShoppingList);
router.patch('/shopping-list/update', userController.updateShoppingListItem);

// Favorites routes
router.post('/favorites/toggle', userController.toggleFavorite);
router.get('/favorites', userController.getFavorites);
router.get('/favorites/status/:recipeId', userController.getFavoriteStatusAndRating);

// Recommendation route
// router.get('/recommendations', userController.getRecommendedRecipes);
router.get('/recommendations/smart', userController.getSmartRecommendations);

router.get('/me', userController.getCurrentUser);
router.get('/recipes', userController.getRecipesByUserId);
router.get('/:id', userController.getUserById);
module.exports = router; 