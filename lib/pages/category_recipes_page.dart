import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizzle_share/models/recipe.dart';
import 'package:sizzle_share/pages/RecipeScreen.dart';
import 'package:sizzle_share/services/api_service.dart';
import 'package:sizzle_share/widgets/custom_recipecard.dart';
import 'package:sizzle_share/providers/recipe_status_provider/recipe_status_provider.dart';

class CategoryRecipesPage extends StatefulWidget {
  final String categoryName;

  const CategoryRecipesPage({super.key, required this.categoryName});

  @override
  State<CategoryRecipesPage> createState() => _CategoryRecipesPageState();
}

class _CategoryRecipesPageState extends State<CategoryRecipesPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      setState(() => _isLoading = true);
      final recipes =
          await _apiService.getRecipesByCategory(widget.categoryName);

      if (mounted) {
        setState(() {
          _recipes = recipes;
          _isLoading = false;
        });

        // Fetch status for all recipes after loading
        final provider =
            Provider.of<RecipeStatusProvider>(context, listen: false);
        for (var recipe in recipes) {
          provider.fetchStatus(recipe.id);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recipes: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFDF9), // Same color as background
          ),
        ),
        title: Text(
          widget.categoryName,
          style: TextStyle(
            color: Color(0xFFFD5D69),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFD5D69)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
              ? const Center(child: Text('No recipes found in this category'))
              : RefreshIndicator(
                  onRefresh: _loadRecipes,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return CustomRecipeCard(recipe: recipe);
                      },
                    ),
                  ),
                ),
    );
  }
}
