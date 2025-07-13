import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sizzle_share/pages/CreateRecipePage.dart';
import 'package:sizzle_share/pages/HomePage.dart';
import 'package:sizzle_share/pages/ProfilePage.dart';
import 'package:sizzle_share/pages/RecipeScreen.dart';
import 'package:sizzle_share/pages/ShoppingListPage.dart';
import 'package:sizzle_share/widgets/custom_bottom_navbar.dart';
import 'package:sizzle_share/widgets/custom_recipecard.dart';
import '../models/mealPlanner.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

class MealPrepScreen extends StatefulWidget {
  const MealPrepScreen({super.key});

  @override
  State<MealPrepScreen> createState() => _MealPrepScreenState();
}

class _MealPrepScreenState extends State<MealPrepScreen> {
  int _selectedDayIndex = 0;
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  MealPlanner? _mealPlanner;
  bool _isLoading = false;
  late ApiService _apiService;
  int _currentIndex = 3;

  final Map<String, List<String>> _subCategories = {
    'Breakfast': [
      'Quick & Easy',
      'Vegan',
      'Keto',
      'Low Carb',
      'Gluten-Free',
      'Diabetic-Friendly',
      'Heart-Healthy',
      'Weight-Loss',
      'Desserts'
    ],
    'Lunch': [
      'Quick & Easy',
      'Vegan',
      'Keto',
      'Low Carb',
      'Gluten-Free',
      'Diabetic-Friendly',
      'Heart-Healthy',
      'Weight-Loss',
      'Desserts'
    ],
    'Dinner': [
      'Quick & Easy',
      'Vegan',
      'Keto',
      'Low Carb',
      'Gluten-Free',
      'Diabetic-Friendly',
      'Heart-Healthy',
      'Weight-Loss',
      'Desserts'
    ],
    'Snacks': [
      'Quick & Easy',
      'Vegan',
      'Keto',
      'Low Carb',
      'Gluten-Free',
      'Diabetic-Friendly',
      'Heart-Healthy',
      'Weight-Loss',
      'Desserts'
    ],
  };

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _initializeAndLoad();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CreateRecipePage()),
        );
        break;
      case 3:
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Future<void> _initializeAndLoad() async {
    try {
      await _apiService.init();
      await _loadMealPlanner();
    } catch (e) {
      _showErrorSnackBar('Failed to initialize: ${_extractErrorMessage(e)}');
    }
  }

  Future<void> _loadMealPlanner() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final planner = await _apiService.getMealPlanner();
      if (!mounted) return;
      setState(() => _mealPlanner = planner);
    } catch (e) {
      if (!mounted) return;
      // Create empty planner if none exists
      setState(() {
        _mealPlanner = MealPlanner(
          id: '',
          userId: '',
          meals: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      final errorData = error.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return errorData['message'].toString();
      } else if (errorData != null) {
        return errorData.toString();
      }
      return error.message?.toString() ?? 'Network error';
    } else if (error is Exception || error is String) {
      return error.toString();
    }
    return 'An unknown error occurred';
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _showRecipeSelectionDialog(String mealType) async {
    try {
      final mainCategory = _getPrimaryCategory(mealType);

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => RecipeSearchDialog(
          mainCategory: mainCategory,
          subCategories: _subCategories[mainCategory] ?? [],
        ),
      );

      if (result == null || !mounted) return;

      final String searchQuery = result['searchQuery'] ?? '';
      final List<String> selectedSubCategories =
          result['selectedSubCategories'] ?? [];

      List<Recipe> filteredRecipes = await _getFilteredRecipes(
        mainCategory,
        searchQuery,
        selectedSubCategories,
      );

      if (!mounted) return;
      await _showRecipeListDialog(mealType, filteredRecipes);
    } catch (e) {
      _showErrorSnackBar('Failed to load recipes: ${_extractErrorMessage(e)}');
    }
  }

  Future<List<Recipe>> _getFilteredRecipes(
    String mainCategory,
    String searchQuery,
    List<String> subCategories,
  ) async {
    try {
      List<Recipe> allRecipes = await _apiService
          .getRecipesByCategoryWithSubFilters(mainCategory, []);

      // Apply search filter if query exists
      if (searchQuery.isNotEmpty) {
        allRecipes = allRecipes
            .where((recipe) => recipe.recipeName
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList();
      }

      // Apply subcategory filters if any selected
      if (subCategories.isNotEmpty) {
        allRecipes = allRecipes
            .where((recipe) =>
                recipe.category.any((cat) => subCategories.contains(cat)))
            .toList();
      }

      return allRecipes;
    } catch (e) {
      throw Exception('Failed to filter recipes: ${_extractErrorMessage(e)}');
    }
  }

  Future<void> _showRecipeListDialog(
      String mealType, List<Recipe> recipes) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Recipe'),
        content: SizedBox(
          width: double.maxFinite,
          child: recipes.isEmpty
              ? const Text('No recipes available')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return ListTile(
                      leading: recipe.imageURL != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(recipe.imageURL!),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.fastfood),
                            ),
                      title: Text(recipe.recipeName),
                      subtitle: Text('${recipe.totalTime} mins'),
                      onTap: () {
                        Navigator.pop(context);
                        _selectRecipe(mealType, recipe.id);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFFFD5D69),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPrimaryCategory(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snacks':
        return 'Snacks';
      default:
        return 'Breakfast';
    }
  }

  Future<void> _selectRecipe(String mealType, String recipeId) async {
    try {
      final now = DateTime.now();
      final selectedDate =
          now.add(Duration(days: _selectedDayIndex - now.weekday + 1));

      await _apiService.addMealToPlanner(
        date: selectedDate,
        mealType: mealType,
        recipeId: recipeId,
      );

      await _loadMealPlanner();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$mealType added successfully!'),
          backgroundColor: Color(0xFFFD5D69),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add meal: ${_extractErrorMessage(e)}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _removeMeal(Meal meal) async {
    try {
      // Optimistic UI update
      setState(() {
        _mealPlanner?.meals.removeWhere((m) =>
            m.date.toIso8601String() == meal.date.toIso8601String() &&
            m.mealType == meal.mealType);
      });

      await _apiService.deleteMeal(
        date: meal.date,
        mealType: meal.mealType,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal removed successfully!'),
          backgroundColor: Color(0xFFFD5D69),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Revert on error
      if (mounted) {
        await _loadMealPlanner();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove meal: ${_extractErrorMessage(e)}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      debugPrint('Error removing meal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Weekly Meal Planner',
            style: TextStyle(
                color: Color(0xFFFD5D69), fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFFFFDF9),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFDF9), // Same color as background
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Day Selector
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Color(0xFFFFFDF9).withOpacity(0.7),
                  child: SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ChoiceChip(
                            label: Text(_days[index]),
                            selected: _selectedDayIndex == index,
                            onSelected: (selected) {
                              setState(() => _selectedDayIndex = index);
                            },
                            selectedColor: const Color(0xFFFD5D69),
                            backgroundColor: const Color(0xFFFFFDF9),
                            labelStyle: TextStyle(
                              color: _selectedDayIndex == index
                                  ? Color(0xFFFFFDF9)
                                  : const Color(0xFFFD5D69),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Meal Cards
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildMealCard('Breakfast'),
                      _buildMealCard('Lunch'),
                      _buildMealCard('Dinner'),
                      _buildMealCard('Snacks'),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: isKeyboardVisible
          ? null
          : CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
            ),
    );
  }

  Widget _buildMealCard(String mealType) {
    final matchingMeals = _mealPlanner?.meals
        .where((m) =>
            m.mealType == mealType.toLowerCase() &&
            m.date.weekday == _selectedDayIndex + 1)
        .toList();

    final meal = (matchingMeals != null && matchingMeals.isNotEmpty)
        ? matchingMeals.first
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFFFFFDF9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mealType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFD5D69),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    meal == null ? Icons.search : Icons.close,
                    color: const Color(0xFFFD5D69),
                  ),
                  onPressed: () async {
                    if (meal == null) {
                      await _showRecipeSelectionDialog(mealType);
                    } else {
                      await _removeMeal(meal);
                    }
                  },
                ),
              ],
            ),
            const Divider(color: Colors.grey),

            // Content Area
            if (meal != null)
              FutureBuilder<Recipe>(
                future: _apiService.getRecipeById(meal.recipeId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading recipe',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final recipe = snapshot.data!;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailPage(
                              recipeId: recipe.id,
                              recipeItem: recipe,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        height: 180,
                        child: CustomRecipeCard(recipe: recipe),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No meal planned',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RecipeSearchDialog extends StatefulWidget {
  final String mainCategory;
  final List<String> subCategories;

  const RecipeSearchDialog({
    super.key,
    required this.mainCategory,
    required this.subCategories,
  });

  @override
  State<RecipeSearchDialog> createState() => _RecipeSearchDialogState();
}

class _RecipeSearchDialogState extends State<RecipeSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedSubCategories = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Search ${widget.mainCategory} Recipes'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search recipes',
                prefixIcon: Icon(Icons.search, color: Color(0xFFFD5D69)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Filter by:'),
            const Divider(),
            ...widget.subCategories.map((subCat) => CheckboxListTile(
                  title: Text(subCat),
                  value: _selectedSubCategories.contains(subCat),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedSubCategories.add(subCat);
                      } else {
                        _selectedSubCategories.remove(subCat);
                      }
                    });
                  },
                  activeColor: Color(0xFFFD5D69),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Color(0xFFFD5D69))),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'searchQuery': _searchController.text,
              'selectedSubCategories': _selectedSubCategories,
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFD5D69)),
          child: Text('Search', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
