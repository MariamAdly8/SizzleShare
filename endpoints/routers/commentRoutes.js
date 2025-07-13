const express = require('express');
const router = express.Router();
const commentController = require('../controllers/commentController');
const { authMiddleware, optionalBanCheck } = require('../middleware/authMiddleware');

// Public routes - but check for banned users
router.get('/:recipeId', optionalBanCheck, commentController.getCommentsByRecipeId);

// Protected routes - require authentication
router.use(authMiddleware); // Apply auth middleware to all routes below

router.post('/', commentController.createComment);
router.put('/:commentId', commentController.updateComment);
router.delete('/:commentId', commentController.deleteComment);

module.exports = router;
