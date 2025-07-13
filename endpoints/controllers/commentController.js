const Comment = require('../models/commentModel');

// Get all comments
exports.getAllComments = async (req, res) => {
    try {
        const comments = await Comment.find();
        res.json(comments);
    }
    catch (err) {
        res.status(500).json({ message: err.message });
    }
};

//Get all comments by a recipeId
exports.getCommentsByRecipeId = async (req, res) => {
    try {
        const comments = await Comment.find({ recipeId: req.params.recipeId })
        if (!comments) {
            return res.json({ message: 'No comments on this recipe' });
        }
        res.json(comments);
    }
    catch (err) {
        res.status(500).json({ message: err.message });
    }
}

//Get all comments by userId
exports.getCommentsByUserId = async (req, res) => {
    try {
        // Use userId from token
        const userId = req.user._id;
        console.log(userId);
        const comments = await Comment.find({ userId });
        if (!comments) {
            return res.json({ message: 'No comments for this user' });
        }
        res.json(comments);
    }
    catch (err) {
        res.status(500).json({ message: err.message });
    }
}

//Create a new comment
exports.createComment = async (req, res) => {
    const { recipeId, content } = req.body;
    // userId from token
    const userId = req.user._id;
    const comment = new Comment({
        userId,
        recipeId,
        content
    });
    try {
        const newComment = await comment.save();
        res.status(201).json(newComment);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};

//Get comments by date

exports.getCommentsByDate=async(req,res)=>{  
    try{
        const comments= await Comment.find({
            date: new Date(req.params.date)
        });
        res.json(comments);
    }
    catch(err){
        res.status(500).json({error:err.message});
    }
}


// Update a comment by _id
exports.updateComment = async (req, res) => {
    try {
        // Only allow update if the comment belongs to the user
        const comment = await Comment.findOneAndUpdate(
            { _id: req.params.commentId, userId: req.user._id },
            req.body,
            { new: true }
        );
        if (!comment) {
            return res.status(404).json({ message: 'Comment not found or not authorized' });
        }
        res.json(comment);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};

// Delete a comment by _id
exports.deleteComment = async (req, res) => {
    try {
        // Only allow delete if the comment belongs to the user
        const comment = await Comment.findOneAndDelete({ _id: req.params.commentId, userId: req.user._id });
        if (!comment) {
            return res.status(404).json({ message: 'Comment not found or not authorized' });
        }
        res.json({ message: 'Comment deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
