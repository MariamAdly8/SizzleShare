import 'package:flutter/material.dart';
import 'package:sizzle_share/pages/CreateRecipePage.dart';
import 'package:sizzle_share/pages/HomePage.dart';
import 'package:sizzle_share/pages/LoginPage.dart';
import 'package:sizzle_share/pages/ProfilePage.dart';
import 'package:sizzle_share/pages/meal_prep_screen.dart';
import 'package:sizzle_share/services/api_service.dart';
import 'package:sizzle_share/models/user.dart';
import 'package:sizzle_share/widgets/custom_bottom_navbar.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  late Future<List<ShoppingItem>> _shoppingListFuture;
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _refreshShoppingList();
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

  void _refreshShoppingList() {
    setState(() {
      _shoppingListFuture = ApiService().getShoppingList();
    });
  }

  Future<void> _toggleCheckOptimistic(ShoppingItem item, int index) async {
    final updatedItem = ShoppingItem(
      name: item.name,
      checked: !item.checked,
    );

    final currentList = await _shoppingListFuture;
    final newList = [...currentList];
    newList[index] = updatedItem;

    setState(() {
      _shoppingListFuture = Future.value(newList);
    });

    try {
      await ApiService().updateShoppingListItem(item.name);
    } catch (e) {
      _showErrorDialog('Failed to update item: $e');
      _refreshShoppingList(); // fallback in case of error
    }
  }

  Future<void> _removeIngredientOptimistic(String name, int index) async {
    final currentList = await _shoppingListFuture;
    final newList = [...currentList]..removeAt(index);

    setState(() {
      _shoppingListFuture = Future.value(newList);
    });

    try {
      await ApiService().removeFromShoppingList(name);
    } catch (e) {
      _showErrorDialog(e.toString());
      _refreshShoppingList(); // fallback
    }
  }

  Future<void> _addIngredient() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    try {
      await ApiService().addToShoppingList(name);
      _controller.clear();
      _refreshShoppingList(); // triggers UI update via FutureBuilder
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _removeIngredient(String name) async {
    try {
      await ApiService().removeFromShoppingList(name);
      _refreshShoppingList(); // Triggers FutureBuilder to reload list
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _toggleCheck(String name) async {
    try {
      await ApiService().updateShoppingListItem(name);
      _refreshShoppingList(); // Triggers FutureBuilder to reload list
    } catch (e) {
      _showErrorDialog('Failed to update item: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _ingredientBox(ShoppingItem item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFD5D69), width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.checked,
            onChanged: (_) => _toggleCheckOptimistic(item, index),
            activeColor: const Color(0xFFFD5D69),
          ),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                decoration: item.checked ? TextDecoration.lineThrough : null,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFFD5D69)),
            onPressed: () => _removeIngredientOptimistic(item.name, index),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFFDF9),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFDF9), // Same color as background
          ),
        ),
        title: const Text(
          'Shopping List',
          style: TextStyle(
            color: Color(0xFFFD5D69),
            fontWeight: FontWeight.bold,
          ),
        ),
        // iconTheme: const IconThemeData(color: Color(0xFFFD5D69)),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ShoppingItem>>(
              future: _shoppingListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Your shopping list is empty.'));
                }

                final list = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshShoppingList();
                  },
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (ctx, index) {
                      return _ingredientBox(list[index], index);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter ingredient',
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addIngredient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFD5D69),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Add',
                      style:
                          TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                ),
              ],
            ),
          )
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
}
