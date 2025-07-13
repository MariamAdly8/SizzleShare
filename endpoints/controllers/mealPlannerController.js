
const MealPlanner = require('../models/mealplannersModel');

// Add a meal to the planner (creates planner if doesn't exist)
exports.addMealToPlanner = async (req, res) => {
    try {
        const { date, mealType, recipeId } = req.body;
        const userId = req.user._id; // Get user ID from token
        const validMeals = ['breakfast', 'lunch', 'dinner','snacks'];

        if (!date || !mealType || !recipeId) {
            return res.status(400).json({ message: 'date, mealType, and recipeId are required.' });
        }
        if (!validMeals.includes(mealType)) {
            return res.status(400).json({ message: 'Invalid mealType. Must be breakfast, lunch, or dinner.' });
        }

        // Find or create meal planner for the user
        let mealPlanner = await MealPlanner.findOne({ userId });
        if (!mealPlanner) {
            // Create new meal planner if it doesn't exist
            mealPlanner = new MealPlanner({ userId, meals: [] });
        }

        // Check if meal already exists for this date and mealType
        const existingMealIndex = mealPlanner.meals.findIndex(meal => 
            meal.date.toDateString() === new Date(date).toDateString() && 
            meal.mealType === mealType
        );

        if (existingMealIndex !== -1) {
            // Update existing meal
            mealPlanner.meals[existingMealIndex].recipeId = recipeId;
        } else {
            // Add new meal
            mealPlanner.meals.push({ date: new Date(date), mealType, recipeId });
        }

        await mealPlanner.save();
        
        const message = !mealPlanner._id ? 'Meal planner created and meal added successfully' : 'Meal added to planner successfully';
        res.json({ message, mealPlanner });
    } catch (err) {
        res.status(500).json({ message: 'Failed to add meal to planner', error: err.message });
    }
};

// Get all meal planners
exports.getAllMealPlanners = async (req, res) => {
    try {
        const planners = await MealPlanner.find().populate('userId', 'name email');
        res.json(planners);
    } catch (err) {
        res.status(500).json({ message: 'Failed to get meal planners', error: err.message });
    }
};

// Get a meal planner by ID
exports.getMealPlannerById = async (req, res) => {
    try {
        const { mealPlannerId } = req.params;
        const planner = await MealPlanner.findById(mealPlannerId);
        if (!planner) {
            return res.status(404).json({ message: 'Meal planner not found' });
        }
        res.json(planner);
    } catch (err) {
        res.status(500).json({ message: 'Failed to get meal planner', error: err.message });
    }
};

// Update a meal planner
exports.updateMealPlanner = async (req, res) => {
    try {
        const { mealPlannerId } = req.params;
        const updates = req.body;
        const planner = await MealPlanner.findByIdAndUpdate(mealPlannerId, updates, { new: true });
        if (!planner) {
            return res.status(404).json({ message: 'Meal planner not found' });
        }
        res.json(planner);
    } catch (err) {
        res.status(500).json({ message: 'Failed to update meal planner', error: err.message });
    }
};

//Delete a meal planner
exports.deleteMealPlanner = async (req, res) => {
    try {
        const { mealPlannerId } = req.params;
        const planner = await MealPlanner.findByIdAndDelete(mealPlannerId);
        if (!planner) {
            return res.status(404).json({ message: 'Meal planner not found' });
        }
        res.json({ message: 'Meal planner deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Failed to delete meal planner', error: err.message });
    }
};



// Get meal planner by authenticated user ID (using token)
exports.getMealPlannerByUserId = async (req, res) => {
    try {
        const userId = req.user._id; // Get user ID from token
        
        const mealPlanner = await MealPlanner.findOne({ userId });
        if (!mealPlanner) {
            return res.status(404).json({ message: 'Meal planner not found for this user' });
        }
        
        res.json(mealPlanner);
    } catch (err) {
        res.status(500).json({ message: 'Failed to get meal planner', error: err.message });
    }
};

// Delete a specific meal
exports.deleteMeal = async (req, res) => {
  try {
    const { date, mealType } = req.body;
    const userId = req.user._id;
    
    if (!date || !mealType) {
      return res.status(400).json({ message: 'date and mealType are required.' });
    }

    const mealPlanner = await MealPlanner.findOne({ userId });
    if (!mealPlanner) {
      return res.status(404).json({ message: 'Meal planner not found' });
    }

    // Filter out the meal to remove
    mealPlanner.meals = mealPlanner.meals.filter(meal => 
      !(new Date(meal.date).toDateString() === new Date(date).toDateString() && 
        meal.mealType === mealType)
    );

    await mealPlanner.save();
    res.json({ message: 'Meal deleted successfully', mealPlanner });
  } catch (err) {
    res.status(500).json({ message: 'Failed to delete meal', error: err.message });
  }
};
// };
