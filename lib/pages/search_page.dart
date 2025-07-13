import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizzle_share/models/recipe.dart';
import 'package:sizzle_share/services/api_service.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({Key? key, this.initialQuery}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _showFilters = false;
  String _searchMessage = '';

  // Filter variables
  double? _minRate;
  double? _maxRate;
  int? _maxCookingTime;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch();
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      _performSearch();
    } else {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), _performSearch);
    }
  }

  Timer? _debounceTimer;

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty &&
        _minRate == null &&
        _maxRate == null &&
        _maxCookingTime == null) {
      setState(() {
        _recipes = [];
        _searchMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final recipes = await ApiService.staticSearchRecipes(
        query: _searchController.text,
        minRate: _minRate,
        maxRate: _maxRate,
        maxCookingTime: _maxCookingTime,
      );

      setState(() {
        _recipes = recipes;
        _isLoading = false;
        _searchMessage =
            recipes.isEmpty ? 'No recipes found matching your search' : '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchMessage = 'Error searching recipes: $e';
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _minRate = null;
      _maxRate = null;
      _maxCookingTime = null;
      _searchController.clear();
      _recipes = [];
      _searchMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search bar with pink background
          Container(
            color: const Color(0xFFFFC6C9),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: widget.initialQuery == null,
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters section
          if (_showFilters) ...[
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filters',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Rating filter
                  const Text('Rating:'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Min',
                            prefixText: '★ ',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _minRate = double.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Max',
                            prefixText: '★ ',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _maxRate = double.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Cooking time filter
                  const Text('Max Cooking Time (minutes):'),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'e.g. 30',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _maxCookingTime = int.tryParse(value);
                    },
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                          ),
                          onPressed: _clearFilters,
                          child: const Text('Clear Filters'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showFilters = false;
                            });
                            _performSearch();
                          },
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Search results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchMessage.isNotEmpty
                    ? Center(child: Text(_searchMessage))
                    : _recipes.isEmpty
                        ? const Center(
                            child: Text(
                              'Search for recipes or apply filters',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _recipes[index];
                              return _buildRecipeCard(recipe);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: recipe.imageURL != null
            ? Image.network(recipe.imageURL!,
                width: 60, height: 60, fit: BoxFit.cover)
            : const Icon(Icons.fastfood, size: 60),
        title: Text(recipe.recipeName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.averageRate != null)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(' ${recipe.averageRate!.toStringAsFixed(1)}'),
                ],
              ),
            Text('${recipe.totalTime} min'),
            if (recipe.cuisine != null) Text(recipe.cuisine!),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to recipe details
        },
      ),
    );
  }
}
