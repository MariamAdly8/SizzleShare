const Recipe = require('../models/recipeModel');
const Comments = require('../models/commentModel');
const User = require('../models/userModel');
 
// Get all recipes
exports.getAllRecipes = async (req, res) => {
    try {
        const recipes = await Recipe.find({"status":"approved"});
        res.json(recipes);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Get a single recipe by recipeId
exports.getRecipeById = async (req, res) => {
    try {
        const recipe = await Recipe.findById(req.params.recipeId).populate('userId', 'name email');
        if (!recipe) {
            return res.status(404).json({ message: 'Recipe not found' });
        }
        const comments = await Comments.find({ recipeId: req.params.recipeId });
        const recipeWithComments = recipe.toObject();
        recipeWithComments.comments = comments;

        // Track view if user is authenticated
        if (req.user) {
            // Remove any previous view of this recipe in the last 20 views
            req.user.viewedRecipes = (req.user.viewedRecipes || []).filter(v => v.recipeId.toString() !== recipe._id.toString());
            // Add this view to the start
            req.user.viewedRecipes.push({ recipeId: recipe._id, viewedAt: new Date() });
            // Keep only the last 20 views
            if (req.user.viewedRecipes.length > 20) {
                req.user.viewedRecipes = req.user.viewedRecipes.slice(-20);
            }
            await req.user.save();
        }

        res.json(recipeWithComments);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};



// Create a new recipe
exports.createRecipe = async (req, res) => {
    const {recipeName, description, totalTime, cuisine, ingredients, category } = req.body;
    const userId = req.user._id;
    
    // parse ingredients if it's a string
    const parsedIngredients = typeof ingredients === 'string' ? JSON.parse(ingredients) : ingredients;
    const parsedCategory = typeof category === 'string' ? JSON.parse(category) : category;
    const parsedDescription = typeof description === 'string' ? JSON.parse(description) : description;
    const imageURL = req.file && req.file.path ? req.file.path : null;
    const recipe = new Recipe({
        recipeName,
        description: parsedDescription,
        totalTime,
        cuisine,
        imageURL,
        ingredients: parsedIngredients,
        category: parsedCategory,
        userId
    });

    try {
        const newRecipe = await recipe.save();
        res.status(201).json(newRecipe);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};


// Update a recipe by id
// exports.updateRecipe = async (req, res) => {
//     try {
//         // Prevent userId from being updated
//         if (req.body.userId) {
//             delete req.body.userId;
//         } 
//         // Only allow the owner to update
//         const recipe = await Recipe.findById(req.params.recipeId);
//         if (!recipe) {
//             return res.status(404).json({ message: 'Recipe not found' });
//         }
//         if (recipe.userId.toString() !== req.user._id.toString()) {
//             return res.status(403).json({ message: 'You are not authorized to update this recipe' });
//         }
//         if (req.file && req.file.path) {
//             recipe.imageURL = req.file.path;
//         }
//         else{
//             recipe.imageURL = null;
//         }
//         // Parse fields if they are strings
//         if (req.body.description) {
//             req.body.description = typeof req.body.description === 'string' ? JSON.parse(req.body.description) : req.body.description;
//         }
//         if (req.body.ingredients) {
//             req.body.ingredients = typeof req.body.ingredients === 'string' ? JSON.parse(req.body.ingredients) : req.body.ingredients;
//         }
//         if (req.body.category) {
//             req.body.category = typeof req.body.category === 'string' ? JSON.parse(req.body.category) : req.body.category;
//         }
        
//         Object.assign(recipe, req.body);
//         await recipe.save();
//         res.json(recipe);
//     } catch (err) {
//         res.status(400).json({ message: err.message });
//     }
// };

// Update a recipe by id
exports.updateRecipe = async (req, res) => {
    try {
        // Prevent userId from being updated
        if (req.body.userId) {
            delete req.body.userId;
        } 
        // Only allow the owner to update
        const recipe = await Recipe.findById(req.params.recipeId);
        if (!recipe) {
            return res.status(404).json({ message: 'Recipe not found' });
        }
        if (recipe.userId.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: 'You are not authorized to update this recipe' });
        }

        // Handle image update
        if (req.body.removeImage === 'true') {
            recipe.imageURL = null; // Explicit image removal
        } else if (req.file && req.file.path) {
            recipe.imageURL = req.file.path; // New image upload
        }
        // If neither condition is true, keep the existing image

        // Parse other fields
        if (req.body.description) {
            req.body.description = typeof req.body.description === 'string' ? JSON.parse(req.body.description) : req.body.description;
        }
        if (req.body.ingredients) {
            req.body.ingredients = typeof req.body.ingredients === 'string' ? JSON.parse(req.body.ingredients) : req.body.ingredients;
        }
        if (req.body.category) {
            req.body.category = typeof req.body.category === 'string' ? JSON.parse(req.body.category) : req.body.category;
        }
        
        Object.assign(recipe, req.body);
        await recipe.save();
        res.json(recipe);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};


// Delete a recipe by id
exports.deleteRecipe = async (req, res) => {
    try {
        const recipe = await Recipe.findById(req.params.recipeId);
        if (!recipe) {
            return res.status(404).json({ message: 'Recipe not found' });
        }
        if (recipe.userId.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: 'You are not authorized to delete this recipe' });
        }
        await recipe.deleteOne();
        res.json({ message: 'Recipe deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Get recipes greater than specific rate
exports.getRecipesByMinRate=async(req,res)=>{
    let rate= +req.params.minRate
    try{
        const recipes= await Recipe.find({
            averageRate:{$gt:rate},
            status: "approved"
        }).populate('userId', 'name email');
        res.json(recipes);
    }
    catch(err){
        res.status(500).json({error:err.message});
    }
}

// Rate a recipe
exports.rateRecipe = async (req, res) => {
    try {
        const { recipeId } = req.params;
        const { rate } = req.body;

        // Validate rate
        if (rate === undefined || rate < 0 || rate > 5) {
            return res.status(400).json({ message: 'Rate must be between 0 and 5' });
        }

        // Use authenticated user from req.user
        const user = req.user;
        const recipe = await Recipe.findById(recipeId);

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        if (!recipe) {
            return res.status(404).json({ message: 'Recipe not found' });
        }

        // Check if user has already rated this recipe
        const existingRatingIndex = user.ratedRecipes.findIndex(
            r => r.recipeId.toString() === recipe._id.toString()
        );

        if (existingRatingIndex !== -1) {
            // Update existing rating
            user.ratedRecipes[existingRatingIndex].rate = rate;
        } else {
            // Add new rating
            user.ratedRecipes.push({
                recipeId: recipe._id,
                rate: rate
            });
        }

        // Save user with updated ratings
        await user.save();

        // Calculate new average rate for recipe
        const result = await User.aggregate([
            { $unwind: "$ratedRecipes" },
            { $match: { "ratedRecipes.recipeId": recipe._id } },
            {
                $group: {
                    _id: "$ratedRecipes.recipeId",
                    averageRate: { $avg: "$ratedRecipes.rate" }
                }
            }
        ]);

        const averageRate = result.length > 0 ? result[0].averageRate : rate;

        // Update recipe with new average rate
        recipe.averageRate = averageRate;
        await recipe.save();

        res.json({
            message: 'Recipe rated successfully',
            averageRate: recipe.averageRate
        });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Get recipes by category
exports.getRecipesByCategory = async (req, res) => {
    try {
        const { category } = req.params;
        const categoryEnum = Recipe.schema.path('category').options.enum;

        if (!categoryEnum.includes(category)) {
            return res.status(400).json({
                message: `Category '${category}' does not exist.`,
                availableCategories: categoryEnum
            });
        }

        const recipes = await Recipe.find({ category, status: "approved" }).populate('userId', 'name email');
        if (recipes.length === 0) {
            return res.status(404).json({
                message: `No recipes found in category: ${category}`
            });
        }
        res.json(recipes);
    } catch (err) {
        res.status(500).json({
            message: 'Failed to retrieve recipes by category',
            error: err.message
        });
    }
};

// Search recipes by multiple parameters
// exports.searchRecipes = async (req, res) => {
//     try {
//         const {
//             q,
//             minRate, 
//             maxRate, 
//             maxCookingTime, 
//         } = req.query;

//         // Track search query if user is authenticated and q is provided
//         if (req.user && q && q.trim()) {
//             req.user.searchHistory = (req.user.searchHistory || []);
//             req.user.searchHistory.push({ query: q.trim(), searchedAt: new Date() });
//             // Keep only the last 10 searches
//             if (req.user.searchHistory.length > 10) {
//                 req.user.searchHistory = req.user.searchHistory.slice(-10);
//             }
//             await req.user.save();
//             console.log('Updated searchHistory:', req.user.searchHistory);
//         }

//         // Build search criteria
//         let searchCriteria = { status: "approved" };

//         if (q && q.trim()) {
//             searchCriteria.$or = [
//                 { recipeName: { $regex: q.trim(), $options: 'i' } },
//                 { cuisine: { $regex: q.trim(), $options: 'i' } },
//                 { category: { $regex: q.trim(), $options: 'i' } },
//                 { 'ingredients.name': q.trim().toLowerCase()}
//             ];
//         }

//         // Rating range filter
//         if (minRate || maxRate) {
//             searchCriteria.averageRate = {};
//             if (minRate) {
//                 searchCriteria.averageRate = { $gte: parseFloat(minRate)};
//             }
//             if (maxRate) {
//                 searchCriteria.averageRate = { $lte: parseFloat(maxRate)};
//             }
//         }

//         // Cooking time filter
//         if (maxCookingTime) {
//             searchCriteria.totalTime = { $lte: parseInt(maxCookingTime)};
//         }

//         const recipes = await Recipe.find(searchCriteria);
//         res.json(recipes);
//     } catch (err) {
//         res.status(500).json({ message: err.message });
//     }
// };

//akher search alfred
// Search recipes by multiple parameters
exports.searchRecipes = async (req, res) => {
    try {
        const {
            q,
            minRate, 
            maxRate, 
            maxCookingTime, 
        } = req.query;

        // Track search query if user is authenticated and q is provided
        if (req.user && q && q.trim()) {
            req.user.searchHistory = (req.user.searchHistory || []);
            req.user.searchHistory.push({ query: q.trim(), searchedAt: new Date() });
            // Keep only the last 10 searches
            if (req.user.searchHistory.length > 10) {
                req.user.searchHistory = req.user.searchHistory.slice(-10);
            }
            await req.user.save();
        }

        let recipes = [];

        if (q && q.trim()) {
            const searchTerm = q.trim();
            
            // Build base filter criteria
            let baseFilter = { status: "approved" };
            
            // Add rating filter
            if (minRate || maxRate) {
                baseFilter.averageRate = {};
                if (minRate) {
                    baseFilter.averageRate.$gte = parseFloat(minRate);
                }
                if (maxRate) {
                    baseFilter.averageRate.$lte = parseFloat(maxRate);
                }
            }

            // Add cooking time filter
            if (maxCookingTime) {
                baseFilter.totalTime = { $lte: parseInt(maxCookingTime) };
            }

            // Search by recipeName (highest priority)
            const recipeNameResults = await Recipe.find({
                ...baseFilter,
                recipeName: { $regex: searchTerm, $options: 'i' }
            });

            // Search by cuisine (second priority)
            const cuisineResults = await Recipe.find({
                ...baseFilter,
                cuisine: { $regex: searchTerm, $options: 'i' }
            });

            // Search by category (third priority)
            const categoryResults = await Recipe.find({
                ...baseFilter,
                category: { $regex: searchTerm, $options: 'i' }
            });

            // Search by ingredients.name (lowest priority)
            const ingredientsResults = await Recipe.find({
                ...baseFilter,
                'ingredients.name': { $regex: searchTerm, $options: 'i' }
            });

            // Combine and sort results based on priority
            const recipeMap = new Map();

            // Add recipeName matches with priority 1 and sub-priority based on first letter match
            recipeNameResults.forEach(recipe => {
                const recipeName = recipe.recipeName.toLowerCase();
                const searchTermLower = searchTerm.toLowerCase();
                
                // Calculate sub-priority based on position of first occurrence
                let subPriority = 0;
                
                // Exact match at start gets highest priority
                if (recipeName.startsWith(searchTermLower)) {
                    subPriority = 0;
                }
                // Find the position of the first occurrence
                else {
                    const firstOccurrenceIndex = recipeName.indexOf(searchTermLower);
                    if (firstOccurrenceIndex !== -1) {
                        // Use the position as sub-priority (lower position = higher priority)
                        subPriority = firstOccurrenceIndex + 1;
                    } else {
                        // Fallback for regex matches that don't contain the exact term
                        subPriority = 999;
                    }
                }
                
                recipeMap.set(recipe._id.toString(), { 
                    recipe, 
                    priority: 1, 
                    subPriority,
                    recipeName: recipeName // for sorting
                });
            });

            // Add cuisine matches with priority 2 (only if not already added)
            cuisineResults.forEach(recipe => {if (!recipeMap.has(recipe._id.toString())) {
                    recipeMap.set(recipe._id.toString(), { recipe, priority: 2, subPriority: 0 });
                }
            });

            // Add category matches with priority 3 (only if not already added)
            categoryResults.forEach(recipe => {
                if (!recipeMap.has(recipe._id.toString())) {
                    recipeMap.set(recipe._id.toString(), { recipe, priority: 3, subPriority: 0 });
                }
            });

            // Add ingredients matches with priority 4 (only if not already added)
            ingredientsResults.forEach(recipe => {
                if (!recipeMap.has(recipe._id.toString())) {
                    recipeMap.set(recipe._id.toString(), { recipe, priority: 4, subPriority: 0 });
                }
            });

            // Convert map to array and sort by priority, then sub-priority, then alphabetically
            recipes = Array.from(recipeMap.values())
                .sort((a, b) => {
                    // First sort by main priority
                    if (a.priority !== b.priority) {
                        return a.priority - b.priority;
                    }
                    
                    // For recipe name matches (priority 1), sort by sub-priority
                    if (a.priority === 1 && b.priority === 1) {
                        if (a.subPriority !== b.subPriority) {
                            return a.subPriority - b.subPriority;
                        }
                        // If sub-priority is the same, sort alphabetically
                        return a.recipeName.localeCompare(b.recipeName);
                    }
                    
                    // For other priorities, maintain original order
                    return 0;
                })
                .map(item => item.recipe);

        } else {
            // If no search query, just apply filters
            let searchCriteria = { status: "approved" };

            // Rating range filter
            if (minRate || maxRate) {
                searchCriteria.averageRate = {};
                if (minRate) {
                    searchCriteria.averageRate.$gte = parseFloat(minRate);
                }
                if (maxRate) {
                    searchCriteria.averageRate.$lte = parseFloat(maxRate);
                }
            }

            // Cooking time filter
            if (maxCookingTime) {
                searchCriteria.totalTime = { $lte: parseInt(maxCookingTime) };
            }

            recipes = await Recipe.find(searchCriteria);
        }

        res.json(recipes);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};