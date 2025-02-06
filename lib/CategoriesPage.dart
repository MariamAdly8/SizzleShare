import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RecipeScreen.dart';

class CategoriesPage extends StatefulWidget {
  final String categoryName;

  CategoriesPage({required this.categoryName});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  // int _selectedIndex = 0; // To track the selected icon

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //     // Handle navigation based on index here
  //     if (index == 0) {
  //       // Home
  //       Navigator.pushNamed(context, '/home'); // Replace with your route
  //     } else if (index == 1) {
  //       // Favorites
  //       Navigator.pushNamed(context, '/favorites'); // Replace with your route
  //     } else if (index == 2) {
  //       // Profile
  //       Navigator.pushNamed(context, '/profile'); // Replace with your route
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.categoryName,
          style: TextStyle(color: Colors.pink),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.pink),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.pink),
            onPressed: () {
              // Implement search functionality here
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.pink),
            onPressed: () {
              // Implement bell functionality here
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .where('category', arrayContains: widget.categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No recipes found"));
          }

          var recipes = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8, // Adjust aspect ratio
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              var recipeDoc = recipes[index];
              var recipeData = recipeDoc.data() as Map<String, dynamic>;
              String recipeId = recipeDoc.id;

              return RecipeCard(
                recipeId: recipeId,
                title: recipeData['recipe name'] ?? 'Unknown',
                image: recipeData['imageURL'] ?? '',
                totalTime: recipeData['total time'] ?? 'N/A',
                averageRate: recipeData['average rate']?.toDouble() ?? 0.0,
              );
            },
          );
        },
      ),
      // bottomNavigationBar: BottomAppBar( // Use BottomAppBar
      //   color: Colors.white, // Background color of the bottom bar
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 8.0), // Add padding
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute icons evenly
      //       children: <Widget>[
      //         IconButton(
      //           icon: Icon(Icons.home),
      //           color: _selectedIndex == 0 ? Colors.pink : Colors.grey, // Highlight selected icon
      //           onPressed: () => _onItemTapped(0),
      //         ),
      //         IconButton(
      //           icon: Icon(Icons.favorite),
      //           color: _selectedIndex == 1 ? Colors.pink : Colors.grey,
      //           onPressed: () => _onItemTapped(1),
      //         ),
      //         IconButton(
      //           icon: Icon(Icons.person), // Profile icon
      //           color: _selectedIndex == 2 ? Colors.pink : Colors.grey,
      //           onPressed: () => _onItemTapped(2),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}

class RecipeCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeScreen(recipeId: recipeId),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    image,
                    height: 150, // Reduced image height
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 70, color: Colors.grey), // Smaller error icon
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteIcon(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column( // Added a Column to wrap title and details
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Smaller font size
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4), // Added spacing
                  Row(
                    children: [
                      Icon(Icons.alarm, color: Color(0xFFEC888D), size: 15), // Smaller icon size
                      SizedBox(width: 2),
                      Text(
                        totalTime,
                        style: TextStyle(color: Color(0xFFEC888D), fontSize: 15), // Smaller font size
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.star_rate_rounded,
                          color: Color(0xFFEC888D), size: 15), // Smaller icon size
                      SizedBox(width: 2),
                      Text(averageRate.toString(),
                          style: TextStyle(color: Color(0xFFEC888D), fontSize: 15)), // Smaller font size
                    ],
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
        padding: const EdgeInsets.all(2), // Reduced padding
        decoration: const BoxDecoration(
          color: Color(0xFFFFC6C9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isFavorited ? Icons.favorite : Icons.favorite_border,
          color: const Color(0xFFEC888D),
          size: 18, // Smaller icon size
        ),
      ),
    );
  }
}