const User = require('../models/userModel');
const Recipe = require('../models/recipeModel');
const sanitizeHtml = require('sanitize-html');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const nodemailer = require('nodemailer');
const validator = require('validator');
const axios = require('axios');
// Temporary in-memory store for pending signups
const pendingSignups = {};
const Comment = require('../models/commentModel');


// Nodemailer setup (basic, for Gmail or SMTP)
const transporter = nodemailer.createTransport({
    service: 'gmail', // يمكنك التغيير حسب مزود الخدمة
    auth: {
        user: process.env.EMAIL_USER, // ضع الإيميل في env
        pass: process.env.EMAIL_PASS  // ضع الباسورد في env
    }
});

// Get all users
exports.getAllUsers = async (req, res) => {
    try {
        const users = await User.find()
            .select('-password -__v -updatedAt')
            .sort({ createdAt: -1 }); // Newest first
        
        res.json(users);
    } catch (err) {
        res.status(500).json({ 
            message: 'Failed to retrieve users',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

exports.loginUser = async (req, res) => {
    try {
        const email = sanitizeHtml(req.body.email?.trim().toLowerCase());
        const password = sanitizeHtml(req.body.password);
 
        if (!email || !password) {
            return res.status(400).json({ message: 'Email and password are required' });
        }

        const user = await User.findOne({ email: email.toLowerCase().trim() }).select('+password');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        
        // Check if user is banned
        if (user.banned) {
            return res.status(403).json({ 
                message: 'Your account has been banned',
                bannedAt: user.bannedAt
            });
        }
        
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Incorrect password' });
        }
        
        const token = jwt.sign(
            { userId: user._id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.json({
            message: 'Login successful',
            token,
            user: {
                _id: user._id,
                email: user.email,
                name: user.name,
                userAvatar: user.userAvatar,
                type: user.type,
                favorites: user.favorites,
                ratedRecipes: user.ratedRecipes,
                shoppingList: user.shoppingList,
                updatedAt: user.updatedAt,
                active: user.active
            }
        });
    } catch (err) {
        console.error('Validation error:', err.errors);
        console.error('Full error:', err);
        res.status(500).json({
            message: 'Login failed',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};


// sign up user
// exports.signupUser = async (req, res) => {
//     try {
//         const { name, email, password, userAvatar, allergyOptions, preferenceOptions } = req.body;

//         if (!name || !email || !password) {
//             return res.status(400).json({ message: 'Name, email, and password are required' });
//         }

//         // --- تحقق من صيغة الإيميل والدومين المسموح ---
//         if (!validator.isEmail(email)) {
//             return res.status(400).json({ message: 'Invalid email format' });
//         }
//         const allowedDomains = [
//             'gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com',
//             'icloud.com', 'live.com', 'aol.com', 'protonmail.com'
//         ];
//         const domain = email.split('@')[1]?.toLowerCase();
//         if (!allowedDomains.includes(domain)) {
//             return res.status(400).json({ message: 'Email domain is not allowed. Please use a known email provider.' });
//         }
//         // --- نهاية التحقق ---

//         const existingUser = await User.findOne({ email: email.toLowerCase().trim() });
//         if (existingUser) {
//             return res.status(400).json({ message: 'Email already registered' });
//         }

//         // Check if there's already a pending signup for this email
//         if (pendingSignups[email.toLowerCase().trim()]) {
//             return res.status(400).json({ message: 'A verification code has already been sent to this email. Please verify your email or wait for the code to expire.' });
//         }

//         const hashedPassword = await bcrypt.hash(password, 10);
//         const sanitizedData = {
//             name: sanitizeHtml(name.trim()),
//             email: sanitizeHtml(email.trim().toLowerCase()),
//             password: hashedPassword,
//             userAvatar: userAvatar || 'default-avatar',
//             allergyOptions: allergyOptions || [],
//             preferenceOptions: preferenceOptions || [],
//             type: 'user',
//             active: true,
//             isEmailVerified: false,
//             shoppingList: [],
//             favorites: [],
//             ratedRecipes: []
//         };

//         // Generate 6-digit code
//         const code = Math.floor(100000 + Math.random() * 900000).toString();
//         const expires = Date.now() + 5 * 60 * 1000; // 5 minutes
//         pendingSignups[email.toLowerCase().trim()] = {
//             data: sanitizedData,
//             code,
//             expires
//         };

//         // Send email
//         await transporter.sendMail({
//             from: process.env.EMAIL_USER,
//             to: sanitizedData.email,
//             subject: 'Email Verification Code',
//             text: `Your verification code is: ${code}`
//         });

//         res.status(200).json({
//             message: 'Verification code sent to email. Please verify to complete signup.'
//         });
//     } catch (err) {
//         res.status(500).json({
//             message: 'Signup failed',
//             error: process.env.NODE_ENV === 'development' ? err.message : undefined
//         });
//     }
// };


const validateEmail = async (email) => {
    const apiKey = process.env.EMAIL_VALIDATION_API_KEY; // Replace with your actual key
    const url = `https://api.emailvalidation.io/v1/info?email=${encodeURIComponent(email)}&apikey=${apiKey}`;
    try {
        const response = await axios.get(url);
        if (response.data.state === 'deliverable') {
            return true;
        }
        return false;
    } catch (error) {
        console.error("Validation Error:", error.message);
    }
}

//sign up user
exports.signupUser = async (req, res) => {
    try {
        const { name, email, password, userAvatar, allergyOptions, preferenceOptions } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({ message: 'Name, email, and password are required' });
        }

        if (!validator.isEmail(email)) {
            return res.status(400).json({ message: 'Invalid email format' });
        }
        const isValid = await validateEmail(email);
        if (!isValid) {
            return res.status(400).json({ message: 'Email is not valid, please use a valid email address' });
        }

        const existingUser = await User.findOne({ email: email.toLowerCase().trim() });
        if (existingUser) {
            return res.status(400).json({ message: 'Email already registered' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const sanitizedData = {
            name: sanitizeHtml(name.trim()),
            email: sanitizeHtml(email.trim().toLowerCase()),
            password: hashedPassword,
            userAvatar: userAvatar || 'default-avatar',
            allergyOptions: allergyOptions || [],
            preferenceOptions: preferenceOptions || [],
            type: 'user',
            active: true,
            isEmailVerified: false,
            shoppingList: [],
            favorites: [],
            ratedRecipes: []
        };

        // Generate 6-digit code
        const code = Math.floor(100000 + Math.random() * 900000).toString();
        const expires = Date.now() + 15 * 60 * 1000; // 15 minutes
        pendingSignups[email.toLowerCase().trim()] = {
            data: sanitizedData,
            code,
            expires
        };

        // Send email
        await transporter.sendMail({
            from: process.env.EMAIL_USER,
            to: sanitizedData.email,
            subject: 'Email Verification Code',
            text: `Your verification code is: ${code}`
        });

        res.status(200).json({
            message: 'Verification code sent to email. Please verify to complete signup.'
        });
    } catch (err) {
        res.status(500).json({
            message: 'Signup failed',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};


// Update current user
exports.updateUser = async (req, res) => {
    try {
        const updates = req.body;
        
        // Remove restricted fields
        delete updates.password;
        delete updates.createdAt;
        delete updates._id;
        delete updates.email; // Prevent email updates through this endpoint
        delete updates.type;
        
        // Sanitize update fields
        for (const key in updates) {
            if (typeof updates[key] === 'string') {
                updates[key] = sanitizeHtml(updates[key].trim());
            }
        }
        
        const user = await User.findByIdAndUpdate(
            req.user._id,
            updates,
            { 
                new: true,
                runValidators: true
            }
        ).select('-password -__v');
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        
        res.json(user);
    } catch (err) {
        if (err.code === 11000) {
            const field = Object.keys(err.keyPattern)[0];
            return res.status(400).json({ 
                message: `${field} already exists`,
                field: field
            });
        }
        
        res.status(400).json({ 
            message: 'Update failed',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

// Delete current user
// exports.deleteUser = async (req, res) => {
//     try {
//         const user = await User.findByIdAndDelete(req.user._id);
        
//         if (!user) {
//             return res.status(404).json({ message: 'User not found' });
//         }
        
//         res.json({ message: 'User deleted successfully' });
//     } catch (err) {
//         res.status(500).json({ 
//             message: 'Failed to delete user',
//             error: process.env.NODE_ENV === 'development' ? err.message : undefined
//         });
//     }
// };

// Delete current user
exports.deleteUser = async (req, res) => {
    try {
        const userId = req.user._id;
        
        // First delete all comments by this user
        await Comment.deleteMany({ userId: userId.toString() });
        
        // Then delete the user
        const user = await User.findByIdAndDelete(userId);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        
        res.json({ message: 'User and all associated comments deleted successfully' });
    } catch (err) {
        res.status(500).json({ 
            message: 'Failed to delete user',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

exports.addToShoppingList = async (req, res) => {
    try {
        const { ingredName } = req.body;
        const trimmedName = ingredName.toLowerCase().trim();
        const user = await User.findById(req.user._id);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        // Check if ingredient already exists in shopping list
        const existingItem = user.shoppingList.find(item => item.name == trimmedName);
        if (existingItem) {
            return res.status(400).json({ message: 'Ingredient already in shopping list' });
        }

        // Add new item with checked status
        user.shoppingList.push({
            name: trimmedName,
            checked: false
        });
        
        await user.save();
        res.json({ message: 'Ingredient added to shopping list' });
    } catch (err) {
        res.status(500).json({ 
            message: 'Failed to add ingredient to shopping list',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

exports.removeFromShoppingList = async (req, res) => {
    try {
        const { ingredName } = req.body;
        const trimmedName = ingredName.toLowerCase().trim();
        const user = await User.findById(req.user._id);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Find and remove the item
        const initialLength = user.shoppingList.length;
        user.shoppingList = user.shoppingList.filter(item => item.name !== trimmedName);
        
        if (user.shoppingList.length === initialLength) {
            return res.status(400).json({ message: 'Ingredient not in shopping list' });
        }

        await user.save();
        res.json({ message: 'Ingredient removed from shopping list' });
    } catch (err) {
        res.status(500).json({ 
            message: 'Failed to remove ingredient from shopping list',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

exports.getShoppingList = async (req, res) => {
    try {
        const user = await User.findById(req.user._id);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        
        res.json({ shoppingList: user.shoppingList });
    } catch (err) {
        res.status(500).json({ 
            message: 'Failed to get shopping list',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

exports.updateShoppingListItem = async (req, res) => {
    try {
        const { ingredName } = req.body;
        const trimmedName = ingredName.toLowerCase().trim();
        const user = await User.findById(req.user._id);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const item = user.shoppingList.find(item => item.name === trimmedName);
        if (!item) {
            return res.status(400).json({ message: 'Ingredient not in shopping list' });
        }

        // Toggle the checked status
        item.checked = !item.checked;
        await user.save();
        
        res.json({ 
            message: 'Shopping list item status updated',
            item: item
        });
    } catch (err) {
        res.status(500).json({ 
            message: 'Failed to update shopping list item status',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

// Add or remove recipe from favorites (toggle)
exports.toggleFavorite = async (req, res) => {
    try {
        const { recipeId } = req.body;

        if (!recipeId) {
            return res.status(400).json({ message: 'Recipe ID is required' });
        }

        // Check if recipe exists and get its name
        const recipe = await Recipe.findById(recipeId);
        if (!recipe) {
            return res.status(404).json({ message: 'Recipe not found' });
        }

        const user = await User.findById(req.user._id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Initialize favorites array if it doesn't exist
        if (!user.favorites) {
            user.favorites = [];
        }


        // Check if recipe is already in favorites
        const favIndex = user.favorites.findIndex(fav => 
            fav.recipeId.toString() === recipe._id.toString()
        );

        let action;
        if (favIndex === -1) {
            // Add to favorites
            user.favorites.push({
                recipeId: recipe._id,
                recipeName: recipe.recipeName
            });
            action = 'added';
        } else {
            // Remove from favorites
            user.favorites.splice(favIndex, 1);
            action = 'removed';
        }

        await user.save();
        const updatedUser = await User.findById(req.user._id)
            .select('_id name email userAvatar type favorites ratedRecipes shoppingList updatedAt active');

        res.json({
            message: `Recipe ${action} to favorites successfully`,
            user: updatedUser,
            action
        });
    } catch (err) {
        console.error('Error toggling favorite:', err);
        res.status(500).json({
            message: 'Failed to toggle favorite',
            error: err.message
        });
    }
};

// Get all favorites for the current user
exports.getFavorites = async (req, res) => {
    try {
        const user = await User.findById(req.user._id).select('favorites');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json({ favorites: user.favorites || [] });
    } catch (err) {
        res.status(500).json({
            message: 'Failed to get favorites',
            error: err.message
            //error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

// Get user by ID
exports.getUserById = async (req, res) => {
    try {
        const userId = req.params.id;
        const user = await User.findById(userId).select('-password -__v');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json(user);
    } catch (err) {
        res.status(500).json({
            message: 'Failed to retrieve user',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

// Get current user by token
exports.getCurrentUser = async (req, res) => {
    try {
        // req.user is set by authMiddleware
        if (!req.user) {
            return res.status(401).json({ message: 'User not authenticated' });
        }
        // Remove sensitive fields if any
        const userObj = req.user.toObject ? req.user.toObject() : req.user;
        delete userObj.password;
        delete userObj.__v;
        res.json(userObj);
    } catch (err) {
        res.status(500).json({
            message: 'Failed to retrieve user',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

// Get favorite status and user rating for a specific recipe
exports.getFavoriteStatusAndRating = async (req, res) => {
    try {
        const { recipeId } = req.params;
        if (!recipeId) {
            return res.status(400).json({ message: 'Recipe ID is required' });
        }
        const user = await User.findById(req.user._id).select('favorites ratedRecipes');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        // Check favorite status
        const isFavorite = (user.favorites || []).some(fav => {
            // Handle both Object and possible legacy ObjectId
            if (fav.recipeId) {
                return fav.recipeId.toString() === recipeId;
            }
            return false;
        });
        // Get user rating for this recipe
        const rated = (user.ratedRecipes || []).find(r => r.recipeId.toString() === recipeId);
        const userRating = rated ? rated.rate : null;
        res.json({ isFavorite, userRating });
    } catch (err) {
        res.status(500).json({
            message: 'Failed to retrieve favorite status and rating',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

// Get personalized recipe recommendations
// exports.getRecommendedRecipes = async (req, res) => {
//     try {
//         const user = await User.findById(req.user._id);
//         if (!user) {
//             return res.status(404).json({ message: 'User not found' });
//         }

//         const { limit = 10 } = req.query; // Default limit of 10 recipes
//         const limitNum = parseInt(limit);

//         // Check if user has preferences or allergies
//         const hasPreferences = user.preferenceOptions && user.preferenceOptions.length > 0;
//         const hasAllergies = user.allergyOptions && user.allergyOptions.length > 0;

//         // Get user's favorites and highly-rated recipes
//         const favoriteIds = (user.favorites || []).map(fav => fav.recipeId.toString());
//         const highRatedIds = (user.ratedRecipes || [])
//             .filter(r => r.rate > 4.5)
//             .map(r => r.recipeId.toString());
//         const specialIds = Array.from(new Set([...favoriteIds, ...highRatedIds]));

//         let recommendedRecipes = [];

//         // Fetch special recipes (favorites and highly-rated)
//         let specialRecipes = [];
//         if (specialIds.length > 0) {
//             specialRecipes = await Recipe.find({
//                 _id: { $in: specialIds },
//                 status: 'approved'
//             }).populate('userId', 'name email');
//         }

//         // Filter out allergy ingredients from special recipes
//         if (hasAllergies && specialRecipes.length > 0) {
//             specialRecipes = specialRecipes.filter(recipe => {
//                 const hasAllergy = recipe.ingredients.some(ingredient => {
//                     const ingredientName = ingredient.name.toLowerCase();
//                     return user.allergyOptions.some(allergy => 
//                         ingredientName.includes(allergy.toLowerCase())
//                     );
//                 });
//                 return !hasAllergy;
//             });
//         }

//         // Add recommendation reasons to special recipes
//         specialRecipes = specialRecipes.map(recipe => {
//             const isFavorite = favoriteIds.includes(recipe._id.toString());
//             const isHighRated = highRatedIds.includes(recipe._id.toString());
            
//             let reason = '';
//             if (isFavorite && isHighRated) {
//                 reason = 'Your favorite and highly-rated recipe';
//             } else if (isFavorite) {
//                 reason = 'Your favorite recipe';
//             } else if (isHighRated) {
//                 reason = 'Your highly-rated recipe (above 4.5)';
//             }
            
//             if (hasAllergies) {
//                 reason += ' (Allergy-safe)';
//             }

//             return {
//                 ...recipe.toObject(),
//                 recommendationReason: reason
//             };
//         });

//         // Calculate remaining slots for other recommendations
//         const alreadyIncludedIds = specialRecipes.map(r => r._id.toString());
//         const remainingLimit = Math.max(0, limitNum - specialRecipes.length);

//         if (hasPreferences || hasAllergies) {
//             // Build query based on user preferences and allergies
//             let query = { 
//                 status: 'approved',
//                 _id: { $nin: alreadyIncludedIds }
//             };

//             // Add preference filter if user has preferences
//             if (hasPreferences) {
//                 query.category = { $in: user.preferenceOptions };
//             }

//             // Get recipes matching preferences
//             let preferenceRecipes = await Recipe.find(query)
//                 .populate('userId', 'name email')
//                 .sort({ averageRate: -1, createdAt: -1 })
//                 .limit(remainingLimit * 2); // Get more recipes to filter by allergies

//             // Filter out recipes with allergy ingredients
//             if (hasAllergies && preferenceRecipes.length > 0) {
//                 preferenceRecipes = preferenceRecipes.filter(recipe => {
//                     const hasAllergy = recipe.ingredients.some(ingredient => {
//                         const ingredientName = ingredient.name.toLowerCase();
//                         return user.allergyOptions.some(allergy => 
//                             ingredientName.includes(allergy.toLowerCase())
//                         );
//                     });
//                     return !hasAllergy;
//                 });
//             }

//             const otherRecipes = preferenceRecipes.slice(0, remainingLimit);

//             // If we don't have enough recipes after filtering, get top-rated recipes
//             if (otherRecipes.length < remainingLimit) {
//                 const additionalLimit = remainingLimit - otherRecipes.length;
//                 const existingIds = [...alreadyIncludedIds, ...otherRecipes.map(recipe => recipe._id.toString())];
                
//                 let additionalQuery = { 
//                     status: 'approved',
//                     _id: { $nin: existingIds }
//                 };

//                 // Filter out allergy ingredients for additional recipes
//                 if (hasAllergies) {
//                     const allRecipes = await Recipe.find(additionalQuery);
//                     const filteredRecipes = allRecipes.filter(recipe => {
//                         const hasAllergy = recipe.ingredients.some(ingredient => {
//                             const ingredientName = ingredient.name.toLowerCase();
//                             return user.allergyOptions.some(allergy => 
//                                 ingredientName.includes(allergy.toLowerCase())
//                             );
//                         });
//                         return !hasAllergy;
//                     });
                    
//                     const additionalRecipes = filteredRecipes
//                         .sort((a, b) => (b.averageRate || 0) - (a.averageRate || 0))
//                         .slice(0, additionalLimit);
                    
//                     otherRecipes.push(...additionalRecipes);
//                 } else {
//                     const additionalRecipes = await Recipe.find(additionalQuery)
//                         .populate('userId', 'name email')
//                         .sort({ averageRate: -1, createdAt: -1 })
//                         .limit(additionalLimit);
                    
//                     otherRecipes.push(...additionalRecipes);
//                 }
//             }

//             // Add recommendation reasons to other recipes
//             const otherRecipesWithReason = otherRecipes.map(recipe => {
//                 let reason = 'Top rated recipe';
                
//                 if (hasPreferences && recipe.category.some(cat => user.preferenceOptions.includes(cat))) {
//                     reason = `Matches your ${recipe.category.find(cat => user.preferenceOptions.includes(cat))} preference`;
//                 }
                
//                 if (hasAllergies) {
//                     reason += ' (Allergy-safe)';
//                 }

//                 return {
//                     ...recipe.toObject(),
//                     recommendationReason: reason
//                 };
//             });

//             recommendedRecipes = [...specialRecipes, ...otherRecipesWithReason];

//         } else {
//             // User has no preferences or allergies - return random recipes
//             let otherRecipes = [];
//             if (remainingLimit > 0) {
//                 otherRecipes = await Recipe.aggregate([
//                     { 
//                         $match: { 
//                             status: 'approved',
//                             _id: { $nin: alreadyIncludedIds.map(id => mongoose.Types.ObjectId(id)) }
//                         } 
//                     },
//                     { $sample: { size: remainingLimit } },
//                     {
//                         $lookup: {
//                             from: 'users',
//                             localField: 'userId',
//                             foreignField: '_id',
//                             as: 'userId'
//                         }
//                     },
//                     { $unwind: '$userId' },
//                     {
//                         $project: {
//                             'userId.password': 0,
//                             'userId.__v': 0
//                         }
//                     }
//                 ]);

//                 // Add recommendation reasons to random recipes
//                 otherRecipes = otherRecipes.map(recipe => ({
//                     ...recipe,
//                     recommendationReason: 'Random recommendation'
//                 }));
//             }

//             recommendedRecipes = [...specialRecipes, ...otherRecipes];
//         }

//         res.json({
//             message: 'Recommended recipes retrieved successfully',
//             count: recommendedRecipes.length,
//             hasPreferences,
//             hasAllergies,
//             recipes: recommendedRecipes
//         });

//     } catch (err) {
//         console.error('Error getting recommendations:', err);
//         res.status(500).json({
//             message: 'Failed to get recommended recipes',
//             error: process.env.NODE_ENV === 'development' ? err.message : undefined
//         });
//     }
// };

// Verify email with code
exports.verifyEmail = async (req, res) => {
    try {
        const { email, code } = req.body;
        if (!email || !code) {
            return res.status(400).json({ message: 'Email and code are required' });
        }
        const emailKey = email.toLowerCase().trim();
        const pending = pendingSignups[emailKey];
        if (!pending) {
            return res.status(400).json({ message: 'No pending signup found for this email. Please sign up again.' });
        }
        if (Date.now() > pending.expires) {
            delete pendingSignups[emailKey];
            return res.status(400).json({ message: 'Verification code expired. Please sign up again.' });
        }
        if (pending.code !== code) {
            return res.status(400).json({ message: 'Invalid verification code' });
        }
        
        // Create user in DB
        pending.data.isEmailVerified = true; 
        const user = new User(pending.data);
        const newUser = await user.save();

        // create token
        const token = jwt.sign(
            { userId: newUser._id, email: newUser.email },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }
        );
        const userResponse = newUser.toObject();
        delete userResponse.password;
        delete userResponse.__v;
        // Remove from pending
        delete pendingSignups[emailKey];
        res.status(201).json({
            message: 'Email verified and user created successfully',
            token,
            user: userResponse
        });
    } catch (err) {
        res.status(500).json({ message: 'Failed to verify email', error: err.message });
    }
};
exports.resendVerificationCode = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ message: 'Email is required' });
        }
        const emailKey = email.toLowerCase().trim();
        const pending = pendingSignups[emailKey];
        if (!pending) {
            return res.status(400).json({ message: 'No pending signup found for this email. Please sign up again.' });
        }
        const code = Math.floor(100000 + Math.random() * 900000);
        pending.code = code.toString();
        pending.expires = Date.now() + 5 * 60 * 1000; // 5 minutes
        pendingSignups[emailKey] = pending;
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Verification Code',
            text: `Your verification code is ${code}.`,
        }
        transporter.sendMail(mailOptions, (err, info) => {
            if (err) {
                return res.status(500).json({ message: 'Failed to send verification code' });
            }
            return res.status(200).json({ message: 'Verification code sent successfully' });
        });
    } catch (err) {
        return res.status(500).json({ message: 'Failed to send verification code' });
    }
};

// Smart personalized recommendation system
exports.getSmartRecommendations = async (req, res) => {
    try {
        const user = await User.findById(req.user._id);
        if (!user) return res.status(404).json({ message: 'User not found' });

        // 1. Collect recipe IDs from favorites, high ratings, last 20 viewed, and searched recipes
        const favoriteIds = (user.favorites || []).map(fav => fav.recipeId.toString());
        const highRatedIds = (user.ratedRecipes || []).filter(r => r.rate >= 4).map(r => r.recipeId.toString());
        const viewedIds = (user.viewedRecipes || []).slice(-20).map(v => v.recipeId.toString());
        const userAllergies = (user.allergyOptions || []).map(a => a.toLowerCase());
        const userPreferences = user.preferenceOptions || [];

        // Searched recipes: get last 10 search queries, find recipes matching name or ingredient
        let searchedRecipeIds = [];
        if (user.searchHistory && user.searchHistory.length > 0) {
            const lastSearches = user.searchHistory.slice(-10).map(s => s.query);
            const searchRegexes = lastSearches.map(q => new RegExp(q, 'i'));
            const searchedRecipes = await Recipe.find({
                $or: [
                    { recipeName: { $in: searchRegexes } },
                    { 'ingredients.name': { $in: searchRegexes } }
                ],
                status: 'approved'
            }, '_id');
            searchedRecipeIds = searchedRecipes.map(r => r._id.toString());
        }

        // Combine all interested recipe IDs
        const interestedRecipeIds = Array.from(new Set([
            ...favoriteIds,
            ...highRatedIds,
            ...viewedIds,
            ...searchedRecipeIds
        ]));

        // 2. If no interactions, return 10 random recipes
        if (interestedRecipeIds.length === 0) {
            const randomRecipes = await Recipe.aggregate([
                { $match: { status: 'approved' } },
                { $sample: { size: 10 } }
            ]);
            return res.json({ message: 'Random recommendations', recipes: randomRecipes });
        }

        // 3. Build user profile: liked categories and ingredients
        const interestedRecipes = await Recipe.find({ _id: { $in: interestedRecipeIds } });
        let likedCategories = [];
        let likedIngredients = [];
        interestedRecipes.forEach(recipe => {
            likedCategories = likedCategories.concat(recipe.category || []);
            likedIngredients = likedIngredients.concat((recipe.ingredients || []).map(ing => ing.name.toLowerCase()));
        });
        likedCategories = [...new Set(likedCategories)];
        likedIngredients = [...new Set(likedIngredients)];

        // 4. Score all other recipes by overlap with liked categories/ingredients and interaction weights
        const otherRecipes = await Recipe.find({
            _id: { $nin: interestedRecipeIds },
            status: 'approved'
        });
        
        const scoredRecipes = otherRecipes.map(recipe => {
            let score = 0;
            if (favoriteIds.includes(recipe._id.toString())) score += 4;
            if (highRatedIds.includes(recipe._id.toString())) score += 3;
            if (viewedIds.includes(recipe._id.toString())) score += 1;
            if (searchedRecipeIds.includes(recipe._id.toString())) score += 1;
            // Content overlap
            const categoryScore = (recipe.category || []).filter(cat => likedCategories.includes(cat)).length;
            const ingredientScore = (recipe.ingredients || []).filter(ing => likedIngredients.includes(ing.name.toLowerCase())).length;
            const preferenceScore = (recipe.category || []).filter(cat => userPreferences.includes(cat)).length;
            score += categoryScore + ingredientScore + 1.5* preferenceScore;
            return { recipe, score };
        })
        .filter(({ recipe }) => {
            if (!userAllergies.length) return true;
            return !(recipe.ingredients || []).some(ing =>
                userAllergies.some(allergy => ing.name.toLowerCase().includes(allergy))
            );
        });
        scoredRecipes.sort((a, b) => b.score - a.score);
        const recommended = scoredRecipes.slice(0, 10).map(r => r.recipe);

        // 5. Return recommendations
        res.json({
            message: 'Smart recommendations based on your interactions (weighted, allergy & preferences aware)',
            recipes: recommended
        });
    } catch (err) {
        res.status(500).json({ message: 'Failed to get recommendations', error: err.message });
    }
};


// Get recipes of the current user
exports.getRecipesByUserId = async (req, res) => {
    try {
        const userId = req.user._id;
        const recipes = await Recipe.find({ userId: userId });
        res.json({
            message: `Found ${recipes.length} recipe(s)`,
            recipes: recipes
        });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
}