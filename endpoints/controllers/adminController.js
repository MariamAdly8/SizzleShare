const User = require('../models/userModel');
const Recipe = require('../models/recipeModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Admin login
exports.loginAdmin = async (req, res) => {
    try {
        const { email, password } = req.body;

        console.log('Login attempt:', { email, password: password ? '***' : 'missing' });

        // Find admin user
        const admin = await User.findOne({ email, type: 'admin' }).select('+password');
        if (!admin) {
            return res.status(401).json({ message: 'Invalid credentials or not an admin account' });
        }

        // Check password
        const isPasswordValid = await bcrypt.compare(password, admin.password);
        if (!isPasswordValid) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Generate JWT token
        const token = jwt.sign(
            { userId: admin._id, type: admin.type },
            process.env.JWT_SECRET || 'your-secret-key',
            { expiresIn: '24h' }
        );

        // Update last login
        admin.lastLogin = new Date();
        await admin.save();

        console.log('Admin logged in successfully:', admin._id);

        res.json({
            message: 'Admin logged in successfully',
            token,
            admin: {
                id: admin._id,
                name: admin.name,
                email: admin.email,
                type: admin.type
            }
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Login failed. Please try again.' });
    }
};

// Get all users for admin management
exports.getAllUsers = async (req, res) => {
    try {
        const users = await User.find()
            .select('-password')
            .sort({ createdAt: -1 });

        console.log(`Found ${users.length} users for admin review`);
        
        res.json(users);
    } catch (error) {
        console.error('Error getting users:', error);
        res.status(500).json({ message: 'Failed to load users' });
    }
};

// Ban a user
exports.banUser = async (req, res) => {
    try {
        const { userId } = req.params;
        const adminId = req.user._id;
        
        console.log('Attempting to ban user:', userId);
        
        // Validate user ID format
        if (!userId || userId.length < 10) {
            return res.status(400).json({ message: 'Invalid user ID format' });
        }
        
        const user = await User.findById(userId);
        if (!user) {
            console.log('User not found:', userId);
            return res.status(404).json({ message: 'User not found' });
        }

        // Prevent admin from banning themselves
        if (user._id.toString() === adminId.toString()) {
            return res.status(400).json({ message: 'You cannot ban yourself' });
        }

        // Prevent admin from banning other admins
        if (user.type === 'admin') {
            return res.status(400).json({ message: 'You cannot ban other admin users' });
        }

        console.log('Found user:', user.name, 'Current banned status:', user.banned);
        
        // Update user ban status
        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { 
                banned: true,
                bannedAt: new Date(),
            },
            { new: true, runValidators: false }
        );

        console.log('User banned successfully:', userId);

        res.json({ 
            message: 'User banned successfully', 
            user: {
                id: updatedUser._id,
                name: updatedUser.name,
                email: updatedUser.email,
                banned: updatedUser.banned,
                bannedAt: updatedUser.bannedAt
            }
        });
    } catch (error) {
        console.error('Error banning user:', error);
        
        if (error.name === 'CastError') {
            return res.status(400).json({ message: 'Invalid user ID format' });
        }
        
        res.status(500).json({ message: 'Failed to ban user. Please try again.' });
    }
};

// Unban a user
exports.unbanUser = async (req, res) => {
    try {
        const { userId } = req.params;
        
        console.log('Attempting to unban user:', userId);
        
        // Validate user ID format
        if (!userId || userId.length < 10) {
            return res.status(400).json({ message: 'Invalid user ID format' });
        }
        
        const user = await User.findById(userId);
        if (!user) {
            console.log('User not found:', userId);
            return res.status(404).json({ message: 'User not found' });
        }

        console.log('Found user:', user.name, 'Current banned status:', user.banned);
        
        // Update user ban status
        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { 
                banned: false,
                bannedAt: null,
            },
            { new: true, runValidators: false }
        );

        console.log('User unbanned successfully:', userId);

        res.json({ 
            message: 'User unbanned successfully', 
            user: {
                id: updatedUser._id,
                name: updatedUser.name,
                email: updatedUser.email,
                banned: updatedUser.banned
            }
        });
    } catch (error) {
        console.error('Error unbanning user:', error);
        
        if (error.name === 'CastError') {
            return res.status(400).json({ message: 'Invalid user ID format' });
        }
        
        res.status(500).json({ message: 'Failed to unban user. Please try again.' });
    }
};

// Get all recipes for admin review
exports.getPendingRecipes = async (req, res) => {
    try {
        const recipes = await Recipe.find()
            .populate('userId', 'name email')
            .sort({ createdAt: -1 });

        console.log(`Found ${recipes.length} recipes for admin review`);
        
        // Debug: Log recipe data to check for missing fields
        recipes.forEach((recipe, index) => {
            console.log(`Recipe ${index + 1}:`, {
                id: recipe._id,
                name: recipe.recipeName,
                totalTime: recipe.totalTime,
                hasTotalTime: recipe.totalTime !== undefined && recipe.totalTime !== null,
                status: recipe.status
            });
        });
        
        res.json(recipes);
    } catch (error) {
        console.error('Error getting recipes:', error);
        res.status(500).json({ message: 'Failed to load recipes' });
    }
};

// Accept recipe
exports.acceptRecipe = async (req, res) => {
    try {
        const { recipeId } = req.params;
        
        console.log('Attempting to accept recipe:', recipeId);
        
        // Validate recipe ID format
        if (!recipeId || recipeId.length < 10) {
            return res.status(400).json({ message: 'Invalid recipe ID format' });
        }
        
        const recipe = await Recipe.findById(recipeId);
        if (!recipe) {
            console.log('Recipe not found:', recipeId);
            return res.status(404).json({ message: 'Recipe not found' });
        }

        console.log('Found recipe:', recipe.recipeName, 'Current status:', recipe.status);
        
        // Update only the status field without triggering full validation
        const updatedRecipe = await Recipe.findByIdAndUpdate(
            recipeId,
            { status: 'approved' },
            { new: true, runValidators: false }
        );

        console.log('Recipe approved successfully:', recipeId);

        res.json({ 
            message: 'Recipe approved successfully', 
            recipe: {
                id: updatedRecipe._id,
                recipeName: updatedRecipe.recipeName,
                status: updatedRecipe.status
            }
        });
    } catch (error) {
        console.error('Error accepting recipe:', error);
        
        if (error.name === 'CastError') {
            return res.status(400).json({ message: 'Invalid recipe ID format' });
        }
        
        res.status(500).json({ message: 'Failed to accept recipe. Please try again.' });
    }
};

// Reject recipe
exports.rejectRecipe = async (req, res) => {
    try {
        const { recipeId } = req.params;
        
        console.log('Attempting to reject recipe:', recipeId);
        
        // Validate recipe ID format
        if (!recipeId || recipeId.length < 10) {
            return res.status(400).json({ message: 'Invalid recipe ID format' });
        }
        
        const recipe = await Recipe.findById(recipeId);
        if (!recipe) {
            console.log('Recipe not found:', recipeId);
            return res.status(404).json({ message: 'Recipe not found' });
        }

        console.log('Found recipe:', recipe.recipeName, 'Current status:', recipe.status);
        
        // Update only the status field without triggering full validation
        const updatedRecipe = await Recipe.findByIdAndUpdate(
            recipeId,
            { status: 'rejected' },
            { new: true, runValidators: false }
        );

        console.log('Recipe rejected successfully:', recipeId);

        res.json({ 
            message: 'Recipe rejected successfully', 
            recipe: {
                id: updatedRecipe._id,
                recipeName: updatedRecipe.recipeName,
                status: updatedRecipe.status
            }
        });
    } catch (error) {
        console.error('Error rejecting recipe:', error);
        
        if (error.name === 'CastError') {
            return res.status(400).json({ message: 'Invalid recipe ID format' });
        }
        
        res.status(500).json({ message: 'Failed to reject recipe. Please try again.' });
    }
};

// Get a specific user by ID for admin management
exports.getUserById = async (req, res) => {
    try {
        const { userId } = req.params;
        
        const user = await User.findById(userId).select('-password');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        
        res.json(user);
    } catch (error) {
        console.error('Error getting user:', error);
        res.status(500).json({ message: 'Failed to load user' });
    }
}; 