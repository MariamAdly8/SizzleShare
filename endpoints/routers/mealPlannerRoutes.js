// const express = require('express');
// const router = express.Router();
// const mealPlannerController = require('../controllers/mealPlannerController');
// const { authMiddleware } = require('../middleware/authMiddleware');

// // Protected routes - require authentication
// router.use(authMiddleware); // Apply auth middleware to all routes below

// router.get('/', mealPlannerController.getAllMealPlanners);
// router.get('/user', mealPlannerController.getMealPlannerByUserId);
// router.get('/:mealPlannerId', mealPlannerController.getMealPlannerById);
// router.post('/add-meal', mealPlannerController.addMealToPlanner);
// router.put('/:mealPlannerId', mealPlannerController.updateMealPlanner);
// router.delete('/:mealPlannerId', mealPlannerController.deleteMealPlanner);
// router.delete('/delete-meal', mealPlannerController.deleteMeal);

// module.exports = router;



const express = require('express');
const router = express.Router();
const mealPlannerController = require('../controllers/mealPlannerController');
const { authMiddleware } = require('../middleware/authMiddleware');

// Protected routes - require authentication
router.use(authMiddleware); // Apply auth middleware to all routes below

router.get('/', mealPlannerController.getAllMealPlanners);
router.get('/user', mealPlannerController.getMealPlannerByUserId);
router.get('/:mealPlannerId', mealPlannerController.getMealPlannerById);
router.post('/add-meal', mealPlannerController.addMealToPlanner);
router.put('/:mealPlannerId', mealPlannerController.updateMealPlanner);
// //router.delete('/:mealPlannerId', mealPlannerController.deleteMealPlanner);
// mealPlannerRoutes.js
router.delete('/delete-meal', mealPlannerController.deleteMeal); // Correct
module.exports = router;
