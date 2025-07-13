const mongoose = require('mongoose');

const recipeSchema = new mongoose.Schema({
    recipeName: {
        type: String,
        required: true
    },
    description: {
        type: [String],
        required: true,
    },
    totalTime: {
        type: Number,
        required: true,
    },
    averageRate: {
        type: Number,
    },
    cuisine: {
        type: String,
    },
    imageURL: {
        type: String,
    },
    ingredients: [
        {
            name: {
                type: String,
                required: true
            },
            quantity: {
                type: String,
                required: true
            }
        }
    ],
    category: {
        type: [String],
        required: true,
        enum: [
            "Quick & Easy",
            "Breakfast",
            "Lunch",
            "Dinner",
            "Desserts",
            "Snacks",
            "Vegan",
            "Keto",
            "Low Carb",
            "Gluten-Free",
            "Diabetic-Friendly",
            "Heart-Healthy",
            "Weight-Loss"
        ]
    }, 
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    status: {
        type: String,
        enum: ['pending', 'approved', 'rejected'],
        default: 'pending'
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model("Recipe", recipeSchema);