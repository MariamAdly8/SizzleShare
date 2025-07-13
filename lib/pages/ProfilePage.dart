import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizzle_share/models/recipe.dart';
import 'package:sizzle_share/models/user.dart';
import 'package:sizzle_share/pages/CreateRecipePage.dart';
import 'package:sizzle_share/pages/CreateRecipePage.dart';
import 'package:sizzle_share/pages/EditRecipePage.dart';
import 'package:sizzle_share/pages/EditRecipePage.dart';
import 'package:sizzle_share/pages/HomePage.dart';
import 'package:sizzle_share/pages/LoginPage.dart';
import 'package:sizzle_share/pages/RecipeScreen.dart';
import 'package:sizzle_share/pages/ShoppingListPage.dart';
import 'package:sizzle_share/pages/SignupPage.dart';
import 'package:sizzle_share/pages/edit_profile_screen.dart';
import 'package:sizzle_share/pages/meal_prep_screen.dart';
import 'package:sizzle_share/providers/recipe_status_provider/recipe_status_provider.dart';
import 'package:sizzle_share/services/api_service.dart';
import 'package:sizzle_share/widgets/RecipeCard.dart';
import 'package:sizzle_share/widgets/custom_bottom_navbar.dart';
// import 'package:sizzle_share/widgets/custom_recipecard.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _user;
  List<Recipe> _userRecipes = [];
  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = true;
  int _currentIndex = 4;
  bool _initialLoad = true;

  // List<Recipe> _pendingApprovalRecipes = [];
  // int _notificationCount = 0;
  List<Recipe> _statusChangedRecipes = []; // Add this declaration

  static List<Recipe> _pendingApprovalRecipes = []; // Made static
  static int _notificationCount = 0; // Made static
  bool _hasNewNotifications = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _loadData();

    _setupStatusCheckTimer();
  }

  void _showDeleteRecipeConfirmation(Recipe recipe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Delete Recipe",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: const Text(
          "Are you sure you want to permanently delete this recipe?",
          style: TextStyle(color: Color(0xFF333333)),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 214, 210, 210),
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel",
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteRecipe(recipe);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFD5D69),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    try {
      final apiService = ApiService();
      await apiService.init();
      await apiService.deleteRecipe(recipe.id);

      if (mounted) {
        setState(() {
          _userRecipes.removeWhere((r) => r.id == recipe.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete recipe: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _setupStatusCheckTimer() {
    // Check every 2 seconds for status changes
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted) {
        _checkForStatusChanges();
      }
    });
  }

  Future<void> _checkForStatusChanges() async {
    try {
      final apiService = ApiService();
      await apiService.init();
      final currentRecipes = await apiService.getRecipesByUser();

      // Find recipes with status changes
      final changedRecipes = currentRecipes.where((recipe) {
        final oldRecipe = _userRecipes.firstWhere(
          (r) => r.id == recipe.id,
          orElse: () => recipe,
        );
        return oldRecipe.status != recipe.status &&
            oldRecipe.status == 'pending';
      }).toList();

      if (changedRecipes.isNotEmpty) {
        setState(() {
          // Only add if not already in the list
          for (var recipe in changedRecipes) {
            if (!_pendingApprovalRecipes.any((r) => r.id == recipe.id)) {
              _pendingApprovalRecipes.add(recipe);
              _notificationCount++;
              _hasNewNotifications = true;
            }
          }
          _userRecipes = currentRecipes;
        });
      }
    } catch (e) {
      print('Error checking status changes: $e');
    }
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: Color(0xFFFD5D69)),
          onPressed: () {
            setState(() {
              _hasNewNotifications = false; // Reset when clicked
            });
            _showStatusChanges();
          },
        ),
        if (_hasNewNotifications && _notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.red,
              child: Text(
                _notificationCount.toString(),
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  void _showStatusChanges() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Recipe Status Updates'),
              content: _pendingApprovalRecipes.isEmpty
                  ? Text('No new status updates')
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _pendingApprovalRecipes.map((recipe) {
                          return ListTile(
                            title: Text(recipe.recipeName),
                            subtitle: Text('Status: ${recipe.status}'),
                            leading: Icon(
                              recipe.status == 'approved'
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: recipe.status == 'approved'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.close, size: 20),
                              onPressed: () {
                                setState(() {
                                  _pendingApprovalRecipes
                                      .removeWhere((r) => r.id == recipe.id);
                                  _notificationCount =
                                      _pendingApprovalRecipes.length;
                                  _hasNewNotifications = _notificationCount > 0;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pendingApprovalRecipes.clear();
                      _notificationCount = 0;
                      _hasNewNotifications = false;
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Update the parent state when dialog closes
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      await apiService.init();

      final user = await apiService.getCurrentUser();
      final favorites = await apiService.getFavoriteRecipes();
      final userRecipes = await apiService.getRecipesByUser();

      if (mounted) {
        setState(() {
          _user = user;
          _favoriteRecipes = favorites;
          _userRecipes = userRecipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load profile data: ${e.toString()}')),
        );
      }
      print('Error loading profile data: $e');
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Close any open drawers/dialogs
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MealPrepScreen()),
        );
        break;
      case 4:
        break;
    }
  }

// In ProfilePage.dart, inside _ProfileScreenState class
  void _navigateToEditRecipeScreen(Recipe recipe) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipePage(recipe: recipe),
      ),
    );

    if (mounted) {
      if (result == true) {
        // Recipe was deleted - refresh data
        _loadData();
        // Optionally show a snackbar message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (result == null) {
        // Recipe was updated - refresh data
        _loadData();
        // Optionally show a snackbar message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      // If result is false, it means user just canceled - no action needed
    }
  }

  void _showSettingsMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.topRight(Offset.zero)),
        button.localToGlobal(button.size.bottomRight(Offset.zero)) +
            const Offset(0, 10),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit, color: Color(0xFFFD5D69)),
              SizedBox(width: 8),
              Text('Edit Profile'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: Color(0xFFFD5D69)),
              SizedBox(width: 8),
              Text('Log Out'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Account', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null && mounted) {
        _handleSettingsSelection(value);
      }
    });
  }

  void _handleSettingsSelection(String value) async {
    final apiService = ApiService();
    await apiService.init();

    switch (value) {
      case 'edit':
        if (_user != null) {
          final updatedUser = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditProfileScreen(),
            ),
          );
          if (updatedUser != null && mounted) {
            setState(() => _user = updatedUser);
          }
        }
        break;
      case 'logout':
        // await apiService.logout();
        final recipeStatusProvider =
            Provider.of<RecipeStatusProvider>(context, listen: false);
        await apiService.logout(context);
        recipeStatusProvider.clearStatuses();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
        break;
      case 'delete':
        _showDeleteAccountDialog();
        break;
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final apiService = ApiService();
                  await apiService.init();
                  await apiService.deleteCurrentUser();
                  await apiService.logout(context);
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupPage()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Failed to delete account: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    final creationYear = _user?.createdAt.year.toString() ?? 'Unknown';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDF9),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFDF9), // Same color as background
          ),
        ),
        title: const Text('Your Profile',
            style: TextStyle(
              color: Color(0xFFFD5D69),
              fontWeight: FontWeight.bold,
            )),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Color(0xFFFD5D69)),
        //   onPressed: () => Navigator.pop(context),
        // ),
        actions: [
          _buildNotificationIcon(), // Add this

          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFFFD5D69)),
            onPressed: () => _showSettingsMenu(context),
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFD5D69)))
          : _user == null
              ? const Center(
                  child: Text("User not found",
                      style: TextStyle(color: Colors.black)))
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFFD5D69).withOpacity(0.2),
                      backgroundImage: (_user!.userAvatar != null &&
                              _user!.userAvatar!.isNotEmpty)
                          ? AssetImage('assets/images/${_user!.userAvatar!}')
                          : null,
                      child: (_user!.userAvatar == null ||
                              _user!.userAvatar!.isEmpty ||
                              _user!.userAvatar == "default-avatar")
                          ? Text(
                              _user!.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 50,
                                color: Color(0xFFFD5D69),
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _user!.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user!.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since $creationYear',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStat('${_userRecipes.length}', 'Recipes'),
                          _buildStat('${_favoriteRecipes.length}', 'Favorites'),
                          _buildStat(
                              '${_user?.ratedRecipes.length ?? 0}', 'Rated'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFFFD5D69),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFFFD5D69),
                      tabs: const [
                        Tab(text: 'My Recipes'),
                        Tab(text: 'Favorites'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRecipeList(_userRecipes, isUserRecipes: true),
                          _buildRecipeList(
                            _favoriteRecipes
                                .where((recipe) => recipe.status == 'approved')
                                .toList(),
                            isUserRecipes: false,
                          ),
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

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFD5D69)),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecipeList(List<Recipe> recipes, {bool isUserRecipes = false}) {
    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isUserRecipes
                  ? "You haven't created any recipes yet"
                  : "No favorite recipes yet",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final recipeStatusProvider = Provider.of<RecipeStatusProvider>(context);
        recipeStatusProvider.fetchStatus(recipe.id);
        return RecipeCard(
          recipeId: recipe.id,
          title: recipe.recipeName,
          image: recipe.imageURL ?? '',
          totalTime: recipe.totalTime.toString(),
          averageRate: recipe.averageRate ?? 0.0,
          showEditButton: isUserRecipes,
          status: recipe.status ?? 'approved',
          showStatus: isUserRecipes,
          onEditPressed: isUserRecipes && recipe.status == 'pending'
              ? () => _navigateToEditRecipeScreen(recipe)
              : null,
          onDeletePressed: isUserRecipes && recipe.status == 'approved'
              ? () => _showDeleteRecipeConfirmation(recipe)
              : null,
          onTap: recipe.status == 'approved'
              ? () async {
                  final updatedRecipe = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailPage(
                        recipeId: recipe.id,
                        recipeItem: recipe,
                        onRatingChanged: (newRating) {
                          setState(() {
                            recipe.averageRate = newRating;
                          });
                        },
                      ),
                    ),
                  );
                  if (updatedRecipe != null) {
                    setState(() {
                      recipe.averageRate = updatedRecipe.averageRate;
                    });
                  }
                }
              : null,
          onFavoriteToggled: () => _loadData(),
        );
      },
    );
  }
}
