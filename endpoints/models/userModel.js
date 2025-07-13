const mongoose = require('mongoose');
const validator = require('validator');
 
const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Name is required'],
        trim: true,
        maxlength: [100, 'Name cannot exceed 100 characters'],
        validate: {
            validator: function(v) {
                return /^[a-zA-Z\s'-]+$/.test(v);
            },
            message: props => `${props.value} contains invalid characters for a name`
        }
    },
    email: {
        type: String,
        required: [true, 'Email is required'],
        unique: true,
        trim: true,
        lowercase: true,
        validate: {
          validator: function(v) {
            // Check email format
            if (!validator.isEmail(v)) return false;
            // Check known domains
            const allowedDomains = [
              'gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com',
              'icloud.com', 'live.com', 'aol.com', 'protonmail.com'
            ];
            const domain = v.split('@')[1]?.toLowerCase();
            return allowedDomains.includes(domain);
          },
          message: props => `${props.value} is not a valid email address or not from a known domain!`
        }
      },
    
    password: {
        type: String,
        required: [true, 'Password is required'],
        minlength: [8, 'Password must be at least 8 characters long'],
        select: false,
        validate: {
            validator: function(v) {
                return /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9])[A-Za-z\d\W]{8,}$/.test(v);
            },
            message: 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'
        }
    },
    userAvatar: {
        type: String,
        default: 'default-avatar'
    },
    allergyOptions: {
        type: [String],
        enum: ['milk', 'banana', 'meat', 'kiwi', 'eggs', 'fish', 'Almonds', 'Peanuts', 'Shrimp', 'Shellfish', 'Tree Nuts'],
        default: []
    },
    preferenceOptions: {
        type: [String],
        enum: [
                'Quick & Easy',
                'Breakfast',
                'Lunch',
                'Dinner',
                'Desserts',
                'Snacks',
                'Vegan',
                'Keto',
                'Low Carb',
                'Gluten-Free',
                'Diabeic-Friendly',
                'Heart-Healthy',
                'Weight-Loss'
            ],
        default: []
    },
    type: {
        type: String,
        enum: {
            values: ['admin', 'user'],
            message: 'User type must be either "admin" or "user"'
        },
        required: [true, 'User type is required'],
        default: 'user'
    },
    // Ban-related fields
    banned: {
        type: Boolean,
        default: false
    },
   
    bannedAt: {
        type: Date,
        default: null
    },
   
    createdAt: {
        type: Date,
        default: Date.now,
        immutable: true
    },
    updatedAt: {
        type: Date,
        default: Date.now
    },
    lastLogin: {
        type: Date
    },
    active: {
        type: Boolean,
        default: true
    },
    favorites: [{
        type: Object,
        default: {}
    }],
    ratedRecipes: [{
        recipeId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Recipe',
            required: true
        },
        rate: {
            type: Number,
            required: true,
            min: 0,
            max: 5
        }
    }],
    shoppingList: {
        type: [
            {
                name: { type: String, required: true },
                checked: { type: Boolean, default: false }
            }
        ],
        default: []
    },
    isEmailVerified: {
        type: Boolean,
        default: false
    },
    viewedRecipes: [
        {
            recipeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Recipe' },
            viewedAt: { type: Date, default: Date.now }
        }
    ],
    searchHistory: [
        {
            query: String,
            searchedAt: { type: Date, default: Date.now }
        }
    ]
});

module.exports = mongoose.model("User", userSchema);