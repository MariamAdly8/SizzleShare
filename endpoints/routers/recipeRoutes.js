const express = require('express');
const router = express.Router();
const recipeController = require('../controllers/recipeController');
const { authMiddleware, optionalBanCheck } = require('../middleware/authMiddleware');
const upload = require('../middleware/upload');
 
// Public routes - but check for banned users
router.get('/filter/search', authMiddleware, recipeController.searchRecipes);
router.get('/', optionalBanCheck, recipeController.getAllRecipes);
router.get('/:recipeId', optionalBanCheck, recipeController.getRecipeById);
router.get('/rate/:minRate', optionalBanCheck, recipeController.getRecipesByMinRate);
router.get('/category/:category', optionalBanCheck, recipeController.getRecipesByCategory);

// Protected routes - require authentication
router.use(authMiddleware); // Apply auth middleware to all routes below

router.post('/', upload.single('image'), recipeController.createRecipe);
router.patch('/:recipeId', upload.single('image'), recipeController.updateRecipe);
router.delete('/:recipeId', recipeController.deleteRecipe);
router.post('/:recipeId/rate', recipeController.rateRecipe);

module.exports = router;