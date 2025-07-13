import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizzle_share/pages/RecipeScreen.dart';
import 'package:sizzle_share/providers/recipe_status_provider/recipe_status_provider.dart';
import '../models/recipe.dart';

// class CustomRecipeCard extends StatelessWidget {
//   final Recipe recipe;
//   final VoidCallback? onFavoriteToggled;

//   const CustomRecipeCard({
//     Key? key,
//     required this.recipe,
//     this.onFavoriteToggled,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final recipeId = recipe.id;

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => RecipeDetailPage(recipeId: recipe.id,recipeItem: recipe,),
//           ),
//         );
//       },
//       child: Stack(
//         alignment: Alignment.topRight,
//         children: [
//           Container(
//             width: 180,
//             margin: const EdgeInsets.symmetric(horizontal: 8),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               image: DecorationImage(
//                 image: NetworkImage(recipe.imageURL ?? ''),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Container(
//               alignment: Alignment.bottomLeft,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.7),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//               child: Text(
//                 recipe.recipeName,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     Shadow(
//                       color: Colors.black,
//                       blurRadius: 4,
//                       offset: Offset(1, 1),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Favorite icon using provider + FutureBuilder
//           Positioned(
//             top: 8,
//             right: 8,
//             child: Consumer<RecipeStatusProvider>(
//               builder: (context, provider, child) {
//                 final status = provider.getStatus(recipeId);
//                 final isFavorite = status?.isFavorite ?? false;

//                 return FutureBuilder(
//                   future: status == null
//                       ? provider.fetchStatus(recipeId)
//                       : Future.value(),
//                   builder: (context, snapshot) {
//                     final isFavorite =
//                         provider.getStatus(recipeId)?.isFavorite ?? false;

//                     return GestureDetector(
//                       onTap: () async {
//                         await provider.toggleFavorite(recipeId);
//                         onFavoriteToggled?.call();
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.3),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           isFavorite ? Icons.favorite : Icons.favorite_border,
//                           color: isFavorite
//                               ? const Color(0xFFFD5D69)
//                               : Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
class CustomRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onFavoriteToggled;

  const CustomRecipeCard({
    Key? key,
    required this.recipe,
    this.onFavoriteToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeId = recipe.id;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RecipeDetailPage(recipeId: recipe.id, recipeItem: recipe),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(recipe.imageURL ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  recipe.recipeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Consumer<RecipeStatusProvider>(
                builder: (context, provider, child) {
                  final status = provider.getStatus(recipeId);
                  final isFavorite = status?.isFavorite ?? false;

                  return FutureBuilder(
                    future: status == null
                        ? provider.fetchStatus(recipeId)
                        : Future.value(),
                    builder: (context, snapshot) {
                      final isFavorite =
                          provider.getStatus(recipeId)?.isFavorite ?? false;

                      return GestureDetector(
                        onTap: () async {
                          await provider.toggleFavorite(recipeId);
                          onFavoriteToggled?.call();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? const Color(0xFFFD5D69)
                                : Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
