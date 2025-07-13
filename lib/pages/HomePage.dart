import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sizzle_share/models/recipe.dart';
import 'package:sizzle_share/models/user.dart';
import 'package:sizzle_share/pages/CreateRecipePage.dart';
import 'package:sizzle_share/pages/ProfilePage.dart';
import 'package:sizzle_share/pages/ShoppingListPage.dart';
import 'package:sizzle_share/pages/category_recipes_page.dart';
import 'package:sizzle_share/pages/loading_screen.dart';
import 'package:sizzle_share/pages/meal_prep_screen.dart';
import 'package:sizzle_share/providers/recipe_status_provider/recipe_status_provider.dart';
import 'package:sizzle_share/services/api_service.dart';
import 'package:sizzle_share/widgets/custom_bottom_navbar.dart';
import 'package:sizzle_share/widgets/custom_recipecard.dart';
import 'package:sizzle_share/widgets/inPageSearch.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  List<Recipe> _trendingRecipes = [];
  int _trendingIndex = 0;
  User? _currentUser;
  List<Recipe> _recommendedRecipes = [];
  bool _isLoadingRecommended = false;
  late PageController _pageController;
  late Timer _timer;
  int _currentIndex = 0;

  // Categories list
  final List<Map<String, dynamic>> categories = [
    {'name': 'Lunch', 'icon': Icons.lunch_dining},
    {'name': 'Dinner', 'icon': Icons.dinner_dining},
    {'name': 'Vegan', 'icon': Icons.eco},
    {'name': 'Quick & Easy', 'icon': Icons.access_time_filled},
    {'name': 'Breakfast', 'icon': Icons.breakfast_dining},
    {'name': 'Desserts', 'icon': Icons.cake},
    {'name': 'Snacks', 'icon': Icons.fastfood},
    {'name': 'Keto', 'icon': Icons.set_meal},
    {'name': 'Low Carb', 'icon': Icons.grass},
    {'name': 'Gluten-Free', 'icon': Icons.do_not_touch},
    {'name': 'Diabetic-Friendly', 'icon': Icons.monitor_heart},
    {'name': 'Heart-Healthy', 'icon': Icons.favorite},
    {'name': 'Weight-Loss', 'icon': Icons.fitness_center},
  ];

  @override
  void initState() {
    super.initState();
    counter = 0;
    _pageController = PageController();

    Future.microtask(() async {
      final recipeStatusProvider =
          Provider.of<RecipeStatusProvider>(context, listen: false);

      // ✅ Clear old user's recipe statuses
      recipeStatusProvider.clearStatuses();

      // ✅ Load everything fresh
      await _loadInitialData();

      // ✅ Fetch new statuses for the loaded recipes
      for (var recipe in _trendingRecipes) {
        await recipeStatusProvider.fetchStatus(recipe.id);
      }
      for (var recipe in _recommendedRecipes) {
        await recipeStatusProvider.fetchStatus(recipe.id);
      }

      _startAutoScroll();
    });
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Close any open drawers/dialogs

    switch (index) {
      case 0:
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MealPrepScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      // Load user data and recipes in parallel
      await Future.wait([
        _loadUserData(),
        _loadTrendingRecipes(),
        _loadRecommendedRecipes(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadRecommendedRecipes() async {
    try {
      if (mounted) {
        setState(() => _isLoadingRecommended = true);
      }

      final recipes = await _apiService.getRecommendedRecipes(limit: 6);

      if (mounted) {
        setState(() {
          _recommendedRecipes = recipes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading recommendations: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRecommended = false);
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final apiService = ApiService();
      await apiService.init();

      final user = await _apiService.getCurrentUser();

      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('No authentication token')
                ? 'Please login to continue'
                : 'Error loading user data: ${e.toString()}'),
          ),
        );
      }
      // If error occurs, try to load from storage
      final token = await _storage.read(key: 'jwt_token');
      if (token == null && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_trendingRecipes.isEmpty) return;
      final nextIndex = (_trendingIndex + 1) % _trendingRecipes.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      setState(() => _trendingIndex = nextIndex);
    });
  }

  Future<void> _loadTrendingRecipes() async {
    try {
      setState(() => _isLoading = true);
      final recipes = await _apiService.getHighRatedRecipes(4.0);

      if (mounted) {
        setState(() {
          _trendingRecipes = recipes..shuffle();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading recipes: ${e.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadTrendingRecipes,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleFavoritePressed(String recipeId) async {
    try {
      // Find the recipe index
      final recipeIndex = _trendingRecipes.indexWhere((r) => r.id == recipeId);
      if (recipeIndex == -1) return;

      // Get current favorite status
      final currentRecipe = _trendingRecipes[recipeIndex];
      final newFavoriteStatus = !currentRecipe.isFavorite;

      // Optimistically update the UI
      setState(() {
        _trendingRecipes[recipeIndex] = Recipe(
          id: currentRecipe.id,
          recipeName: currentRecipe.recipeName,
          description: currentRecipe.description,
          totalTime: currentRecipe.totalTime,
          averageRate: currentRecipe.averageRate,
          cuisine: currentRecipe.cuisine,
          imageURL: currentRecipe.imageURL,
          ingredients: currentRecipe.ingredients,
          category: currentRecipe.category,
          userId: currentRecipe.userId,
          status: currentRecipe.status,
          createdAt: currentRecipe.createdAt,
          isFavorite: newFavoriteStatus,
          userRating: currentRecipe.userRating,
        );
      });

      // Update on server
      await _apiService.toggleFavorite(recipeId);

      // Refresh user data to get updated favorites
      await _loadUserData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorite: ${e.toString()}')),
        );
        // Revert changes if error occurs
        final recipeIndex =
            _trendingRecipes.indexWhere((r) => r.id == recipeId);
        if (recipeIndex != -1) {
          final currentRecipe = _trendingRecipes[recipeIndex];
          setState(() {
            _trendingRecipes[recipeIndex] = Recipe(
              id: currentRecipe.id,
              recipeName: currentRecipe.recipeName,
              description: currentRecipe.description,
              totalTime: currentRecipe.totalTime,
              averageRate: currentRecipe.averageRate,
              cuisine: currentRecipe.cuisine,
              imageURL: currentRecipe.imageURL,
              ingredients: currentRecipe.ingredients,
              category: currentRecipe.category,
              userId: currentRecipe.userId,
              status: currentRecipe.status,
              createdAt: currentRecipe.createdAt,
              isFavorite: !currentRecipe.isFavorite, // Revert the change
              userRating: currentRecipe.userRating,
            );
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _loadInitialData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 25,
                        right: 25,
                        top: kToolbarHeight - 30,
                        bottom: 80,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hi [Name] text
                          Text(
                            "Hi! ${_currentUser?.name.split(' ').first.capitalize() ?? 'User'}",
                            maxLines: 2,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: Color(0xFFFD5D69),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // "What are you cooking today?" text
                          const Text(
                            "What are you cooking today?",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 8),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0), // Add some padding if needed
                            child: InPageSearch(),
                          ),
                          const SizedBox(height: 24),
                          _buildCategoriesSection(),
                          const SizedBox(height: 24),
                          const Text(
                            'Trending Recipe',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFD5D69),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<Recipe?>(
                              valueListenable: rateChange,
                              builder: (context, value, _) {
                                if (value != null) {
                                  print(value.averageRate!.toString());
                                  print('value.averageRate!');
                                  if (value.averageRate! > 4.0) {
                                    if (!_trendingRecipes
                                        .contains(rateChange.value!)) {
                                      _trendingRecipes.add(rateChange.value!);
                                    }
                                  } else {
                                    _trendingRecipes.remove(rateChange.value);
                                  }
                                }
                                return _buildTrendingRecipeCard();
                              }),
                          const SizedBox(height: 16),
                          _buildRecommendedRecipes(),
                        ],
                      ),
                    ),
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

  Widget _buildRecommendedRecipes() {
    if (_isLoadingRecommended && _recommendedRecipes.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFD5D69),
          ),
        ),
      );
    }

    if (_recommendedRecipes.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.recommend,
                size: 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'No recommendations available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: _loadRecommendedRecipes,
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Color(0xFFFD5D69),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recommended For You',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFD5D69),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: _recommendedRecipes.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final recipe = _recommendedRecipes[index];
              return SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.65, // 65% of screen width
                child: CustomRecipeCard(recipe: recipe),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: Color(0xFFFD5D69),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryRecipesPage(
                        categoryName: category['name'],
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFD5D69).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        category['icon'],
                        size: 30,
                        color: const Color(0xFFFD5D69),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingRecipeCard() {
    if (_isLoading && _trendingRecipes.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFD5D69),
          ),
        ),
      );
    }

    if (_trendingRecipes.isEmpty) {
      return SizedBox(
        height: 220,
        // width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fastfood,
                size: 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'No trending recipes found',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: _loadTrendingRecipes,
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Color(0xFFFD5D69),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      // width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _trendingRecipes.length,
            onPageChanged: (index) => setState(() => _trendingIndex = index),
            itemBuilder: (context, index) {
              final recipe = _trendingRecipes[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.width * 0.05, // 5% padding
                ),
                child: CustomRecipeCard(recipe: recipe),
              );
            },
          ),

          // Page indicator dots
          if (_trendingRecipes.length > 1)
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _trendingRecipes.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _trendingIndex == index
                          ? const Color(0xFFFD5D69)
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),

          // Navigation arrows
          if (_trendingRecipes.length > 1) ...[
            Positioned(
              left: 0,
              child: IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFFFD5D69),
                    size: 32,
                  ),
                ),
                onPressed: () {
                  final prevIndex =
                      (_trendingIndex - 1) % _trendingRecipes.length;
                  _pageController.animateToPage(
                    prevIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFFD5D69),
                    size: 32,
                  ),
                ),
                onPressed: () {
                  final nextIndex =
                      (_trendingIndex + 1) % _trendingRecipes.length;
                  _pageController.animateToPage(
                    nextIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }
}
