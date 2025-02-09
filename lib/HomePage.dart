import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizzle_share/CategoriesPage.dart';
import 'package:sizzle_share/RecipeScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String firstName = "User";
  List<Map<String, dynamic>> suggestedRecipes = [];
  Map<String, dynamic> trendingRecipe = {};
  bool isLoading = true;
  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserFirstName();
    _getSuggestedRecipes();
    fetchTrendingRecipe();
  }

  Future<void> fetchTrendingRecipe() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .orderBy('average rate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        setState(() {
          trendingRecipe = doc.data(); // Store recipe data
          trendingRecipe!['id'] = doc.id; // Store Firestore document ID
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("No trending recipe found.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching trending recipe: $e");
    }
  }

  Future<void> _getUserFirstName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // Replace with your Firestore collection name
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        String fullName = userDoc['name']; // Assuming the field is named 'name'
        List<String> nameParts = fullName.split(" ");
        setState(() {
          firstName = nameParts.first; // Get only the first name
        });
      }
    }
  }

  Future<void> _getSuggestedRecipes() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .where('average rate', isGreaterThan: 4.0) // ✅ Correct field name
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("No recipes found with rating > 4.0");
      }

      setState(() {
        suggestedRecipes = querySnapshot.docs.map((doc) {
          var recipeData = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'title':
                recipeData['recipe name'] ?? 'Unknown', // ✅ Correct field name
            'image': recipeData['imageURL'] ?? '',
            'rating': recipeData['average rate']?.toDouble() ??
                0.0, // ✅ Correct field name
            'time': recipeData['total time'] ?? 'N/A', // ✅ Correct field name
          };
        }).toList();
      });

      print("Recipes fetched: ${suggestedRecipes.length}");
    } catch (e) {
      print("Error fetching recipes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC6C9),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFFEC888D),
              size: 20,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC6C9),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(
              Icons.search,
              color: Color(0xFFEC888D),
              size: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi! $firstName",
                style: TextStyle(
                    color: Color(0xFFFD5D69),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "What are you cooking today",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    CategoryChip(label: "Breakfast"),
                    CategoryChip(label: "Lunch"),
                    CategoryChip(label: "Dinner"),
                    CategoryChip(label: "Vegan"),
                    CategoryChip(label: "Keto Diet"),
                    CategoryChip(label: "High-Cholesterol"),
                    CategoryChip(label: "Low-Carb"),
                    CategoryChip(label: "Desserts"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Trending Recipe",
                style: TextStyle(
                    color: Color(0xFFFD5D69),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                      child: Image.network(
                    trendingRecipe?['imageURL'] ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 80),
                  )),
                  // Dark overlay for better text visibility
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  // Top-right favorite button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color:
                            _selectedIndex == 1 ? Colors.white : Colors.white70,
                      ),
                      onPressed: () {
                        _onBottomNavTap(1);
                      },
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            trendingRecipe!['recipe name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.timer, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                trendingRecipe!['total time'] ?? 'N/A',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.yellow),
                              const SizedBox(width: 5),
                              Text(
                                (trendingRecipe!['average rate']?.toDouble() ??
                                        0.0)
                                    .toStringAsFixed(1),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              final recipeId = trendingRecipe!['id'];
                              if (recipeId != null && recipeId.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeScreen(recipeId: recipeId),
                                  ),
                                );
                              } else {
                                print("Error: Recipe ID is missing or empty!");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Error: Recipe not found.")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFD5D69),
                            ),
                            child: const Text(
                              "View Recipe",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                color: const Color(0xFFFD5D69),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Suggested Recipes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                          height: 180,
                          child: suggestedRecipes.isEmpty
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: suggestedRecipes.length,
                                  itemBuilder: (context, index) {
                                    var recipe = suggestedRecipes[index];

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: RecipeCard(
                                        recipeId: recipe['id'],
                                        title: recipe['title'],
                                        image: recipe['image'],
                                        totalTime: recipe['time'],
                                        averageRate: recipe['rating'],
                                      ),
                                    );
                                  },
                                )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFD5D69),
          borderRadius: BorderRadius.circular(36),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? Colors.white : Colors.white70,
              ),
              onPressed: () {
                _onBottomNavTap(0);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: _selectedIndex == 1 ? Colors.white : Colors.white70,
              ),
              onPressed: () {
                _onBottomNavTap(1);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: _selectedIndex == 2 ? Colors.white : Colors.white70,
              ),
              onPressed: () {
                _onBottomNavTap(2);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// class RecipeCard extends StatefulWidget {
//   final String image;
//   final String title;

//   const RecipeCard({super.key, required this.image, required this.title});

//   @override
//   State<RecipeCard> createState() => _RecipeCardState();
// }

// class _RecipeCardState extends State<RecipeCard> {
//   bool _isFavorited = false;

//   void _toggleFavorite() {
//     setState(() {
//       _isFavorited = !_isFavorited;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DetailPage(title: widget.title),
//           ),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(16)),
//                   child: Image.asset(
//                     widget.image,
//                     height: 100,
//                     width: 150,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: GestureDetector(
//                     onTap: _toggleFavorite,
//                     child: Container(
//                       padding: const EdgeInsets.all(3),
//                       decoration: const BoxDecoration(
//                         color: Color(0xFFFFC6C9),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         _isFavorited ? Icons.favorite : Icons.favorite_border,
//                         color: const Color(0xFFEC888D),
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 widget.title,
//                 style:
//                     const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Row(
//                 children: const [
//                   Icon(Icons.alarm, color: Color(0xFFEC888D), size: 16),
//                   SizedBox(width: 4),
//                   Text(
//                     "30min",
//                     style: TextStyle(color: Color(0xFFEC888D)),
//                   ),
//                   SizedBox(width: 10),
//                   Icon(Icons.star_rate_rounded,
//                       color: Color(0xFFEC888D), size: 16),
//                   SizedBox(width: 4),
//                   Text("5", style: TextStyle(color: Color(0xFFEC888D))),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class RecipeCard extends StatefulWidget {
  final String recipeId;
  final String image;
  final String title;
  final String totalTime;
  final double averageRate;

  const RecipeCard({
    super.key,
    required this.recipeId,
    required this.image,
    required this.title,
    required this.totalTime,
    required this.averageRate,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _isFavorited = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final recipeId = widget.recipeId;
        if (recipeId != null && recipeId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeScreen(recipeId: recipeId),
            ),
          );
        } else {
          print("Error: Recipe ID is missing or empty!");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Recipe not found.")),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    widget.image,
                    height: 100,
                    width: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC6C9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: const Color(0xFFEC888D),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.alarm, color: Color(0xFFEC888D), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    widget.totalTime,
                    style: const TextStyle(color: Color(0xFFEC888D)),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.star_rate_rounded,
                      color: Color(0xFFEC888D), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    widget.averageRate.toStringAsFixed(1),
                    style: const TextStyle(color: Color(0xFFEC888D)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryChip extends StatefulWidget {
  final String label;

  const CategoryChip({super.key, required this.label});

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: GestureDetector(
          onTap: () {
            // Navigate to VeganRecipesPage with the selected category
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CategoriesPage(categoryName: widget.label),
              ),
            );
          },
          child: Chip(
            label: Text(
              widget.label,
              style: TextStyle(
                color: _isHovered ? Colors.white : const Color(0xFFFD5D69),
              ),
            ),
            backgroundColor:
                _isHovered ? const Color(0xFFFD5D69) : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            side: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class FavoriteIcon extends StatefulWidget {
  const FavoriteIcon({super.key});

  @override
  _FavoriteIconState createState() => _FavoriteIconState();
}

class _FavoriteIconState extends State<FavoriteIcon> {
  bool _isFavorited = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleFavorite,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: Color(0xFFFFC6C9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isFavorited ? Icons.favorite : Icons.favorite_border,
          color: const Color(0xFFEC888D),
          size: 24,
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String recipeId;
  final String title;

  const DetailPage({super.key, required this.recipeId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFFD5D69),
      ),
      body: Center(
        child: Text(
          "Recipe ID: $recipeId\nDetails for $title",
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
