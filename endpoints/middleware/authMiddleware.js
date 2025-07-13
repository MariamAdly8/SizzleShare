const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const authMiddleware = async (req, res, next) => {
    try {
        // Get token from header
        const token = req.header('Authorization')?.replace('Bearer ', '');
        if (!token) {
            return res.status(401).json({ message: 'No authentication token, access denied' });
        }
        // Verify token
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
        // Get user from database
        const user = await User.findById(decoded.userId).select('-password -__v');
        if (!user) {
            return res.status(401).json({ message: 'User not found' });
        }

        // Check if user is banned
        if (user.banned) {
            return res.status(403).json({ 
                message: 'Your account has been banned',
                bannedAt: user.bannedAt
            });
        }

        // Add user to request object
        req.user = user;
        next();
    } catch (err) {
        res.status(401).json({ message: 'Token is invalid or expired' });
    }
};

// Optional middleware to check if user is banned (for public routes)
const optionalBanCheck = async (req, res, next) => {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');
        if (token) {
            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
            const user = await User.findById(decoded.userId).select('-password -__v');
            if (user && user.banned) {
                return res.status(403).json({ 
                    message: 'Your account has been banned',
                    bannedAt: user.bannedAt
                });
            }
            req.user = user;
        }
        next();
    } catch (err) {
        // If token is invalid, just continue without user
        next();
    }
};

// Middleware to check if user is admin
const adminMiddleware = async (req, res, next) => {
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Authentication required' });
        }
        
        if (req.user.type !== 'admin') {
            return res.status(403).json({ message: 'Admin access required' });
        }
        
        next();
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
};

module.exports = { authMiddleware, adminMiddleware, optionalBanCheck }; 