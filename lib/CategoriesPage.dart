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
  @override
  Widget build(BuildContext context) {
    return SafeArea( // Ensures UI doesn't overlap with system bars
      child: Scaffold(
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
                // Implement notification functionality here
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

            if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No recipes found"));
            }

            var recipes = snapshot.data!.docs;

            return Padding(
              padding: EdgeInsets.all(10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75, // Adjusted ratio for better fit
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
              ),
            );
          },
        ),
      ),
    );
  }
}

// Compact and Responsive Recipe Card
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    image,
                    height: 100, // Reduced height for better balance
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: FavoriteIcon(),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Title (Responsive)
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis, // Prevent overflow
                  ),
                  SizedBox(height: 4),
                  // Time & Rating Row (Now Using Wrap to Prevent Overflow)
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(Icons.alarm, color: Color(0xFFEC888D), size: 12),
                      Text(
                        totalTime,
                        style: TextStyle(color: Color(0xFFEC888D), fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Icon(Icons.star_rate_rounded, color: Color(0xFFEC888D), size: 12),
                      Text(
                        averageRate.toStringAsFixed(1), // Limiting decimal places
                        style: TextStyle(color: Color(0xFFEC888D), fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
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

// Favorite Icon Widget
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
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Color(0xFFFFC6C9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isFavorited ? Icons.favorite : Icons.favorite_border,
          color: Color(0xFFEC888D),
          size: 14,
        ),
      ),
    );
  }
}