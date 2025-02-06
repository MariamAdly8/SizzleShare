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

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              const Text(
                "Hi! Dianne",
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
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecipeScreen(recipeId: 'QTOiFviFmMN5i4IzBg83'),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Color(0xFFEC888D),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Image.asset(
                              'assets/images/pizza.png',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
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
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Salami and Cheese Pizza",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "This is a quick overview of the ingredients...",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.alarm,
                                        color: Color(0xFFEC888D), size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      "30min",
                                      style:
                                          TextStyle(color: Color(0xFFEC888D)),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: const [
                                    Icon(Icons.star_rate_rounded,
                                        color: Color(0xFFEC888D), size: 16),
                                    SizedBox(width: 4),
                                    Text("5",
                                        style: TextStyle(
                                            color: Color(0xFFEC888D))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            RecipeCard(
                              image: 'assets/images/burger.png',
                              title: 'Chicken Burger',
                            ),
                            RecipeCard(
                              image: 'assets/images/tiramisu.jpg',
                              title: 'Tiramisu',
                            ),
                            RecipeCard(
                              image: 'assets/images/Caesar_Salad.jpg',
                              title: 'Caesar Salad',
                            ),
                            RecipeCard(
                              image: 'assets/images/Fresh_Sushi.jpg',
                              title: 'Sushi Platter',
                            ),
                            RecipeCard(
                              image: 'assets/images/pancakes.jpg',
                              title: 'Pancakes',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

class RecipeCard extends StatefulWidget {
  final String image;
  final String title;

  const RecipeCard({super.key, required this.image, required this.title});

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(title: widget.title),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    widget.image,
                    height: 100,
                    width: 150,
                    fit: BoxFit.cover,
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
                children: const [
                  Icon(Icons.alarm, color: Color(0xFFEC888D), size: 16),
                  SizedBox(width: 4),
                  Text(
                    "30min",
                    style: TextStyle(color: Color(0xFFEC888D)),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.star_rate_rounded,
                      color: Color(0xFFEC888D), size: 16),
                  SizedBox(width: 4),
                  Text("5", style: TextStyle(color: Color(0xFFEC888D))),
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
                builder: (context) =>CategoriesPage(categoryName: widget.label),
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
            backgroundColor: _isHovered ? const Color(0xFFFD5D69) : Colors.white,
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
  final String title;

  const DetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFFD5D69),
      ),
      body: Center(
        child: Text(
          "Details for $title",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
