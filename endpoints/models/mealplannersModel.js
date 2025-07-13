const mongoose = require('mongoose');

const mealSchema = new mongoose.Schema({
    date: {
        type: Date,
        required: true
    },
    mealType: {
        type: String,
        enum: ['breakfast', 'lunch', 'dinner','snacks'],
        required: true
    },
    recipeId: {
        type: String,
        required: true
    }
}, { _id: false });

const mealPlannerSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true
    },
    meals: {
        type: [mealSchema],
        default: []
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('MealPlanner', mealPlannerSchema); 