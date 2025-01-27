import 'package:flutter/material.dart';
import 'package:sizzle_share/HomePage.dart';

//widget for all section titles
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
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  bool isFavorite = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //arrow back
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: const Color.fromRGBO(253, 93, 105, 1),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                  ),

                  // title of the screen
                  Expanded(
                    child: Center(child: SectionTitle(txt: "Recipe Details")),
                  ),

                  // favorite button
                  Container(
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pink.shade100,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
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
              //recipe name and rate
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color.fromRGBO(253, 93, 105, 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: const Text(
                        'Salami And Cheese Pizza',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                        softWrap: true,
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.white, size: 30),
                    const SizedBox(width: 4),
                    const Text(
                      '5',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Details Section
              Row(
                children: [
                  SectionTitle(txt: "Description"),
                  SizedBox(width: 8),
                  Icon(
                    Icons.alarm,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '45 minutes',
                    style: TextStyle(fontSize: 14),
                    softWrap: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'This is a quick overview of the ingredients you’ll need for this Salami Pizza recipe. Specific measurements and full recipe instructions are in the printable recipe card below.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              //cuisine section
              SectionTitle(txt: "Cuisine"),
              const SizedBox(height: 8),
              const Text(
                'Egyptian',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Ingredients Section
              SectionTitle(txt: "Ingredients"),
              const SizedBox(height: 8),
              Column(
                children: [
                  IngredientRow(quantity: '1', name: 'pre-made pizza dough'),
                  IngredientRow(quantity: '1/2 cup', name: 'pizza sauce'),
                  IngredientRow(
                      quantity: '1/2 cup', name: 'shredded mozzarella cheese'),
                  IngredientRow(quantity: '1/2 cup', name: 'sliced salami'),
                  IngredientRow(
                      quantity: '1/4 cup',
                      name: 'sliced black olives (optional)'),
                  IngredientRow(
                      quantity: '1/4 cup', name: 'fresh basil leaves'),
                ],
              ),
              const SizedBox(height: 20),
              // Comments Section
              SectionTitle(txt: "Comments"),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromRGBO(253, 93, 105, 1),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: const TextField(
                        decoration: InputDecoration(
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
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
