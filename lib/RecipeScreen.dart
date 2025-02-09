import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget for all section titles
class SectionTitle extends StatelessWidget {
  final String txt; // The parameter to hold the text to display
  const SectionTitle({super.key, required this.txt});
  @override
  Widget build(BuildContext context) {
    return Text(
      txt, // Display the provided text
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(253, 93, 105, 1),
      ),
      softWrap: true, // Allow text to wrap to the next line if needed
    );
  }
}

class RecipeScreen extends StatefulWidget {
  final String recipeId;
  const RecipeScreen({super.key, required this.recipeId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  bool isFavorite = false;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Return recipe data for this recipeId
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .snapshots(),
      builder: (context, snapshot) {
        // If there is no data
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // Recipe data stored in recipeData variable
        var recipeData = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> ingredients = recipeData['ingredients'] ?? [];

        return Scaffold(
          body: SafeArea( // Wrap the body content with SafeArea
            child: SingleChildScrollView( // Ensure scrollview is inside SafeArea
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Arrow back
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: const Color.fromRGBO(253, 93, 105, 1),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),

                        // Title of the screen
                        Expanded(
                          child: Center(child: SectionTitle(txt: "Recipe Details")),
                        ),

                        // Favorite button
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.pink.shade100,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: const Color.fromRGBO(253, 93, 105, 1),
                            ),
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Recipe name and rate
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color.fromRGBO(253, 93, 105, 1),
                      ),
                      child: Column(
                        children: [
                          Image.network(
                            Uri.parse(recipeData['imageURL']).toString(),
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.fill,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 80),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    recipeData['recipe name'],
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  recipeData['average rate'].toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Cuisine section
                    SectionTitle(txt: "Cuisine"),
                    const SizedBox(height: 8),
                    Text(
                      recipeData['cuisine'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Ingredients Section
                    SectionTitle(txt: "Ingredients"),
                    const SizedBox(height: 8),
                    Column(
                      children: ingredients.map((ingredient) {
                        return IngredientRow(
                          quantity: ingredient['quantity'] ?? '',
                          name: ingredient['name'] ?? '',
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Details Section
                    Row(
                      children: [
                        SectionTitle(txt: "Description"),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.alarm,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipeData['total time'],
                          style: const TextStyle(fontSize: 14),
                          softWrap: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipeData['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Comments Section
                    SectionTitle(txt: "Comments"),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(253, 93, 105, 1),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: 'Add a comment...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Color.fromRGBO(253, 93, 105, 1),
                            ),
                            onPressed: () {
                              controller.clear();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class IngredientRow extends StatelessWidget {
  final String quantity;
  final String name;

  const IngredientRow({super.key, required this.quantity, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            quantity,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(253, 93, 105, 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}