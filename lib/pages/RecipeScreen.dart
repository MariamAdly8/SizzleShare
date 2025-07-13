import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizzle_share/models/comment.dart';
import 'package:sizzle_share/models/recipe.dart';
import 'package:sizzle_share/models/user.dart';
import 'package:sizzle_share/pages/LoginPage.dart';
import 'package:sizzle_share/providers/recipe_status_provider/recipe_status_provider.dart';
import 'package:sizzle_share/services/api_service.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;
  Recipe recipeItem;
  final Function(double)? onRatingChanged; // Callback for rating updates

  RecipeDetailPage({
    super.key,
    required this.recipeId,
    required this.recipeItem,
    this.onRatingChanged,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Future<Recipe> _recipeFuture;
  double? _userRating;
  Set<String> _shoppingListNames = {};
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isFetchingComments = false;
  bool _favoritesChanged = false;
  double? _averageRating; // Add this line with your other state variables

  @override
  void initState() {
    super.initState();

    // Initialize the recipe future and set average rating
    _recipeFuture = ApiService().getRecipeById(widget.recipeId).then((recipe) {
      setState(() {
        _averageRating = recipe.averageRate;
        widget.recipeItem = recipe; // Update the recipe item if needed
      });
      return recipe;
    });

    // Fetch recipe status
    Provider.of<RecipeStatusProvider>(context, listen: false)
        .fetchStatus(widget.recipeId);

    // Load other data
    _loadUserData(); // Add this

    _loadUserStatus();
    _fetchShoppingList();
    _fetchComments();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      await ApiService().getCurrentUser(); // Pre-load current user
    } catch (e) {
      debugPrint("Failed to pre-load user data: $e");
    }
  }

  Future<void> _editComment(Comment comment) async {
    final TextEditingController _editController =
        TextEditingController(text: comment.content);

    final newContent = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextField(
            controller: _editController,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, _editController.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newContent != null &&
        newContent != comment.content &&
        newContent.isNotEmpty) {
      try {
        setState(() => _isFetchingComments = true);
        await ApiService().updateComment(comment.id, newContent);
        await _fetchComments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comment updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update comment: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isFetchingComments = false);
        }
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await ApiService().deleteComment(commentId);
      setState(() {
        _comments.removeWhere((c) => c.id == commentId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete comment: ${e.toString()}')),
        );
      }
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

  void _handleSettingsSelection(String value) {
    switch (value) {
      case 'edit':
        Navigator.pushNamed(
            context, '/edit-profile'); // replace if your route is different
        break;
      case 'logout':
        ApiService().logout(context).then((_) {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        });
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
                await ApiService().logout(context); // or delete token
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showShoppingPopup(BuildContext context, bool added,
      {String? itemName}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24), // More rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IntrinsicWidth(
              // This makes the container fit its content
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    added ? Icons.check_circle : Icons.remove_circle_outline,
                    color: const Color(0xFFFD5D69),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    // This prevents text overflow
                    child: Text(
                      added
                          ? itemName != null
                              ? 'Added "$itemName"'
                              : 'Added to list'
                          : itemName != null
                              ? 'Removed "$itemName"'
                              : 'Removed from list',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14, // Slightly smaller font
                      ),
                      maxLines: 2, // Allow text to wrap if needed
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _fetchComments() async {
    setState(() => _isFetchingComments = true);
    try {
      final comments =
          await ApiService().getCommentsByRecipeId(widget.recipeId);
      debugPrint("Fetched comments: ${comments.length}");
      setState(() => _comments = comments);
    } catch (e) {
      debugPrint("Error fetching comments: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load comments: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isFetchingComments = false);
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      await ApiService().createComment(widget.recipeId, content);
      _commentController.clear();
      await _fetchComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment posted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadUserStatus() async {
    try {
      final status = await ApiService().getRecipeStatus(widget.recipeId);
      setState(() {
        _userRating = status.userRating;
      });
    } catch (e) {
      debugPrint("Failed to load user status: $e");
    }
  }

  Future<void> _fetchShoppingList() async {
    try {
      final items = await ApiService().getShoppingList();
      setState(() {
        _shoppingListNames =
            items.map((item) => item.name.toLowerCase().trim()).toSet();
      });
    } catch (e) {
      debugPrint("Failed to fetch shopping list: $e");
    }
  }

  void _showCommentsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'All Comments',
            style: TextStyle(
                color: Color(0xFFFD5D69), fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: _comments.isEmpty
                ? const Text('No comments yet.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentItem(_comments[index]);
                    },
                  ),
          ),
          actions: [
            TextButton(
              child: const Text('Close',
                  style: TextStyle(color: Color(0xFFFD5D69))),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        ApiService().getCurrentUser(),
        ApiService().getUserById(comment.userId),
      ]).then((results) => {
            'currentUser': results[0],
            'commentAuthor': results[1],
          }),
      builder: (context, snapshot) {
        // Show loading state only for the first time
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const ListTile(
            title: Text('Loading...'),
            leading: CircleAvatar(child: CircularProgressIndicator()),
          );
        }

        // Handle errors
        if (snapshot.hasError) {
          debugPrint("Error loading comment: ${snapshot.error}");
          return ListTile(
            title: const Text('Error loading comment'),
            subtitle: Text(comment.content),
            leading: const CircleAvatar(child: Icon(Icons.error)),
          );
        }

        // Default user data if fetch fails
        final data = snapshot.data ??
            {
              'currentUser': User(
                id: 'unknown',
                name: 'Unknown User',
                email: 'unknown@example.com',
                userAvatar: 'default-avatar',
                allergyOptions: [],
                preferenceOptions: [],
                type: 'user',
                banned: false,
                createdAt: DateTime.now(),
                active: true,
                favorites: [],
                ratedRecipes: [],
                shoppingList: [],
              ),
              'commentAuthor': User(
                id: 'unknown',
                name: 'Unknown User',
                email: 'unknown@example.com',
                userAvatar: 'default-avatar',
                allergyOptions: [],
                preferenceOptions: [],
                type: 'user',
                banned: false,
                createdAt: DateTime.now(),
                active: true,
                favorites: [],
                ratedRecipes: [],
                shoppingList: [],
              ),
            };

        final currentUser = data['currentUser'] as User;
        final commentAuthor = data['commentAuthor'] as User;

        return ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFD5D69).withOpacity(0.2),
            backgroundImage: (commentAuthor.userAvatar != null &&
                    commentAuthor.userAvatar!.isNotEmpty &&
                    commentAuthor.userAvatar != "default-avatar")
                ? AssetImage('assets/images/${commentAuthor.userAvatar!}')
                : null,
            child: (commentAuthor.userAvatar == null ||
                    commentAuthor.userAvatar!.isEmpty ||
                    commentAuthor.userAvatar == "default-avatar")
                ? Text(
                    commentAuthor.name.isNotEmpty
                        ? commentAuthor.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFFFD5D69),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(commentAuthor.name),
          subtitle: Text(comment.content),
          trailing: currentUser.id == comment.userId
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () => _editComment(comment),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteComment(comment.id),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _sectionBox({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFD5D69))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget buildRecipeImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(child: Text("No image available")),
      );
    }

    try {
      if (imageUrl.startsWith('/9j') || imageUrl.length > 100) {
        return Image.memory(
          base64Decode(imageUrl),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else if (Uri.tryParse(imageUrl)?.hasAbsolutePath == true) {
        return Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else {
        return Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Center(child: Text("Invalid image")),
        );
      }
    } catch (_) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(child: Text("Image error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeStatusProvider = Provider.of<RecipeStatusProvider>(context);
    final recipeStatus = recipeStatusProvider.getStatus(widget.recipeId);
    final isFavorite = recipeStatus?.isFavorite ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FutureBuilder<Recipe>(
          future: _recipeFuture,
          builder: (context, snapshot) {
            final recipeName =
                snapshot.hasData ? snapshot.data!.recipeName : '';
            return AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFFDF9), // Same color as background
                ),
              ),
              backgroundColor: Color(0xFFFFFDF9),
              elevation: 0,
              centerTitle: true,
              // leading: IconButton(
              //   icon: const Icon(Icons.arrow_back, color: Color(0xFFFD5D69)),
              //   onPressed: () => Navigator.pop(context),

              // ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFFD5D69)),
                onPressed: () {
                  Navigator.pop(
                      context, _favoritesChanged); // ✅ Send change result
                },
              ),

              title: Text(
                recipeName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFFD5D69),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Color(0xFFFD5D69) : Colors.grey,
                  ),
                  // onPressed: () {
                  //   recipeStatusProvider.toggleFavorite(widget.recipeId);
                  //   ////////7teeenaaa daaaaa//////////
                  //   /// // ✅ Pop with result when unfavorited
                  // final updatedStatus = recipeStatusProvider.getStatus(widget.recipeId);
                  // if (updatedStatus != null && updatedStatus.isFavorite == false) {
                  //   if (mounted) Navigator.pop(context, true);///////////////////////////////////////////////////////////modify???
                  // }
                  // },
                  onPressed: () async {
                    await recipeStatusProvider.toggleFavorite(widget.recipeId);

                    // ✅ Just mark that changes happened, do NOT pop here
                    _favoritesChanged = true;
                  },
                ),
                // IconButton(
                //   icon: const Icon(Icons.more_vert, color: Color(0xFFFD5D69)),
                //   onPressed: () => _showSettingsMenu(context),
                // ),
              ],
            );
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: FutureBuilder<Recipe>(
          future: _recipeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Recipe not found.'));
            }

            final recipe = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[100],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: buildRecipeImage(recipe.imageURL),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFD5D69),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    recipe.recipeName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star,
                                        size: 16, color: Colors.white),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                      width:
                                          30, // Fixed width for rating number
                                      // child: Text(
                                      //   (recipe.averageRate ?? 0.0)
                                      //       .toStringAsFixed(1),
                                      //   style: const TextStyle(
                                      //       color: Colors.white),
                                      // ),
                                      // In your recipe image section where you show the rating:
                                      child: Text(
                                        (_averageRating ?? 0.0)
                                            .toStringAsFixed(1),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Tooltip(
                                      message: 'View all comments',
                                      child: InkWell(
                                        onTap: _showCommentsDialog,
                                        child: const Icon(
                                            Icons.comment_outlined,
                                            size: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                      width:
                                          20, // Fixed width for comment count
                                      child: Text(
                                        _comments.length.toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _sectionBox(
                    title: "Instructions",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.description.asMap().entries.map((entry) {
                        final index = entry.key + 1; // Start numbering from 1
                        final step = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(fontSize: 16),
                              children: [
                                TextSpan(
                                  text: "Step $index. ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFD5D69),
                                  ),
                                ),
                                TextSpan(
                                  text: step,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _sectionBox(
                    title: "Your Rating",
                    child: RatingBar.builder(
                      initialRating: _userRating ?? 0.0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 28,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) async {
                        try {
                          setState(() {
                            _userRating = rating;
                            // Calculate a temporary average - this will be replaced by the real value from API
                            _averageRating =
                                ((_averageRating ?? 0.0) + rating) / 2;
                          });
                          final newAvg = await ApiService()
                              .rateRecipe(widget.recipeId, rating);
                          // _userRating = rating;
                          // _recipeFuture =
                          //     ApiService().getRecipeById(widget.recipeId);
                          setState(() {
                            _averageRating = newAvg;
                          });

                          var recipeFuture =
                              await ApiService().getRecipeById(widget.recipeId);
                          widget.recipeItem.averageRate =
                              recipeFuture.averageRate;
                          rateChange.value = widget.recipeItem;
                          if (widget.onRatingChanged != null) {
                            widget.onRatingChanged!(newAvg);
                          }
                        } catch (e) {
                          setState(() {
                            _userRating = null;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to submit rating: ${e.toString()}')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  _sectionBox(
                    title: "Ingredients",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.ingredients
                          .map((ing) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(
                                            color: Color(0xFFFD5D69),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    Expanded(
                                      child: Text(
                                        "${ing.quantity} ${ing.name}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _shoppingListNames.contains(
                                                ing.name.toLowerCase())
                                            ? Icons.remove_circle_outline
                                            : Icons.add_circle_outline,
                                        color: const Color(0xFFFD5D69),
                                      ),
                                      onPressed: () async {
                                        try {
                                          if (_shoppingListNames.contains(
                                              ing.name.toLowerCase())) {
                                            await ApiService()
                                                .removeFromShoppingList(
                                                    ing.name);
                                            setState(() =>
                                                _shoppingListNames.remove(
                                                    ing.name.toLowerCase()));
                                            _showShoppingPopup(context, false,
                                                itemName: ing.name);
                                          } else {
                                            await ApiService()
                                                .addToShoppingList(ing.name);
                                            setState(() => _shoppingListNames
                                                .add(ing.name.toLowerCase()));
                                            _showShoppingPopup(context, true,
                                                itemName: ing.name);
                                          }
                                          _fetchShoppingList();
                                        } catch (e) {
                                          _showShoppingPopup(context,
                                              false); // Show error state
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  _sectionBox(
                    title: "Comments",
                    child: Column(
                      children: [
                        ..._comments.take(3).map((c) => _buildCommentItem(c)),
                        if (_comments.length > 3)
                          TextButton(
                            onPressed: _showCommentsDialog,
                            child: const Text('View all comments',
                                style: TextStyle(color: Color(0xFFFD5D69))),
                          ),
                        TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send,
                                  color: Color(0xFFFD5D69)),
                              onPressed: _submitComment,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
