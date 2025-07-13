// import 'package:flutter/material.dart';
// import 'package:sizzle_share/pages/RecipeScreen.dart';

// class RecipeCard extends StatelessWidget {
//   final String recipeId;
//   final String title;
//   final String? image; // Changed to match your usage
//   final String totalTime; // Changed back to String to match your usage
//   final double averageRate; // Changed back to non-nullable to match your usage
//   final bool isFavorite;
//   final String status; // Add this line for status

// //edit
//   final bool showEditButton; // Add this

//   final VoidCallback? onFavoritePressed;
//   final VoidCallback? onTap;
// //edit
//   final VoidCallback? onEditPressed; // Add this

//   const RecipeCard({
//     super.key,
//     required this.recipeId,
//     required this.title,
//     required this.image,
//     required this.totalTime,
//     required this.averageRate,
//     this.isFavorite = false,
// //edit
//     this.showEditButton = false, // Default to false

//     this.onFavoritePressed,
//     this.onTap,

//     //edit
//     this.onEditPressed, // Add this

//     this.status = 'pending', // Default to approved

//   });

//   Widget _buildImage(String? image) {
//     if (image == null || image.isEmpty) {
//       return Container(
//         color: Colors.grey[200],
//         child: const Center(
//           child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
//         ),
//       );
//     }

//     return Image.network(
//       image,
//       fit: BoxFit.cover,
//       width: double.infinity,
//       height: double.infinity,
//       loadingBuilder: (context, child, loadingProgress) {
//         if (loadingProgress == null) return child;
//         return Center(
//           child: CircularProgressIndicator(
//             value: loadingProgress.expectedTotalBytes != null
//                 ? loadingProgress.cumulativeBytesLoaded /
//                     loadingProgress.expectedTotalBytes!
//                 : null,
//           ),
//         );
//       },
//       errorBuilder: (_, __, ___) => const Center(
//         child: Icon(Icons.broken_image, size: 40),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//       final isDisabled = status != 'approved'; // Disable if not approved
//   final showFavorite = status == 'approved'; // Only show favorite if approved
//   final showEdit = showEditButton && status != 'rejected'; // Don't show edit if rejected

// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Card(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //         clipBehavior: Clip.antiAlias,
// //         child: SizedBox(
// //           width: 220,
// //           height: 180,
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               Container(
// //                 height: 120,
// //                 color: Colors.grey[200],
// //                 child: Stack(
// //                   children: [
// //                     _buildImage(image),
// //                     if (onFavoritePressed != null)
// //                       Positioned(
// //                         top: 8,
// //                         right: 8,
// //                         child: Container(
// //                           decoration: BoxDecoration(
// //                             color: Colors.black.withOpacity(0.3),
// //                             shape: BoxShape.circle,
// //                           ),
// //                           child: IconButton(
// //                             icon: Icon(
// //                               isFavorite
// //                                   ? Icons.favorite
// //                                   : Icons.favorite_border,
// //                               color: isFavorite ? Colors.red : Colors.white,
// //                               size: 20,
// //                             ),
// //                             onPressed: onFavoritePressed,
// //                             padding: EdgeInsets.zero,
// //                           ),
// //                         ),
// //                       ),

// //                        if (showEditButton) // Add this new condition
// //       Positioned(
// //         top: 8,
// //         left: 8,
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: Colors.black.withOpacity(0.3),
// //             shape: BoxShape.circle,
// //           ),
// //           child: IconButton(
// //             icon: const Icon(
// //               Icons.edit,
// //               color: Colors.white,
// //               size: 20,
// //             ),
// //             onPressed: onEditPressed,
// //             padding: EdgeInsets.zero,
// //           ),
// //         ),
// //       ),
// //                   ],
// //                 ),
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     SizedBox(
// //                       height: 24,
// //                       child: Text(
// //                         title,
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.w800,
// //                           height: 1.2,
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Row(
// //                       children: [
// //                         const Icon(
// //                           Icons.star,
// //                           color: Colors.amber,
// //                           size: 16,
// //                         ),
// //                         const SizedBox(width: 4),
// //                         Text(
// //                           averageRate.toStringAsFixed(1),
// //                           style: const TextStyle(
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                         const Spacer(),
// //                         const Icon(
// //                           Icons.timer_outlined,
// //                           size: 16,
// //                           color: Colors.grey,
// //                         ),
// //                         const SizedBox(width: 4),
// //                         Text(
// //                           '$totalTime min',
// //                           style: const TextStyle(
// //                             fontSize: 14,
// //                             color: Colors.grey,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

//  return GestureDetector(
//       onTap: isDisabled ? null : onTap,
//       child: Opacity(
//         opacity: isDisabled ? 0.6 : 1.0,
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: SizedBox(
//             width: 220,
//             height: 180,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Container(
//                   height: 120,
//                   color: Colors.grey[200],
//                   child: Stack(
//                     children: [
//                       _buildImage(image),
//                       if (showFavorite)
//                         Positioned(
//                           top: 8,
//                           right: 8,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.3),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               icon: Icon(
//                                 isFavorite
//                                     ? Icons.favorite
//                                     : Icons.favorite_border,
//                                 color: isFavorite ? Colors.red : Colors.white,
//                                 size: 20,
//                               ),
//                               onPressed: onFavoritePressed,
//                               padding: EdgeInsets.zero,
//                             ),
//                           ),
//                         ),
//                       if (showEdit)
//                         Positioned(
//                           top: 8,
//                           left: 8,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.3),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               icon: const Icon(
//                                 Icons.edit,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                               onPressed: onEditPressed,
//                               padding: EdgeInsets.zero,
//                             ),
//                           ),
//                         ),
//                       Positioned(
//                         bottom: 8,
//                         left: 8,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: _getStatusColor(status),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             status.toUpperCase(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: 24,
//                         child: Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                             height: 1.2,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.star,
//                             color: Colors.amber,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             averageRate.toStringAsFixed(1),
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const Spacer(),
//                           const Icon(
//                             Icons.timer_outlined,
//                             size: 16,
//                             color: Colors.grey,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '$totalTime min',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

// // Helper method to get color based on status
// Color _getStatusColor(String status) {
//   switch (status) {
//     case 'pending':
//       return Colors.orange;
//     case 'approved':
//       return Colors.green;
//     case 'rejected':
//       return Colors.red;
//     default:
//       return Colors.grey;
//   }}
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sizzle_share/pages/RecipeScreen.dart';
// import 'package:sizzle_share/providers/recipe_status_provider/recipe_status_provider.dart';

// class RecipeCard extends StatelessWidget {
//   final String recipeId;
//   final String title;
//   final String? image; // Changed to match your usage
//   final String totalTime; // Changed back to String to match your usage
//   final double averageRate; // Changed back to non-nullable to match your usage
//   final String status; // Add this line for status

// //edit
//   final bool showEditButton; // Add this

//   final VoidCallback? onTap;
// //edit
//   final VoidCallback? onEditPressed; // Add this

//   const RecipeCard({
//     super.key,
//     required this.recipeId,
//     required this.title,
//     required this.image,
//     required this.totalTime,
//     required this.averageRate,
// //edit
//     this.showEditButton = false, // Default to false

//     this.onTap,

//     //edit
//     this.onEditPressed, // Add this

//     this.status = 'pending', // Default to approved

//   });

//   Widget _buildImage(String? image) {
//     if (image == null || image.isEmpty) {
//       return Container(
//         color: Colors.grey[200],
//         child: const Center(
//           child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
//         ),
//       );
//     }

//     return Image.network(
//       image,
//       fit: BoxFit.cover,
//       width: double.infinity,
//       height: double.infinity,
//       loadingBuilder: (context, child, loadingProgress) {
//         if (loadingProgress == null) return child;
//         return Center(
//           child: CircularProgressIndicator(
//             value: loadingProgress.expectedTotalBytes != null
//                 ? loadingProgress.cumulativeBytesLoaded /
//                     loadingProgress.expectedTotalBytes!
//                 : null,
//           ),
//         );
//       },
//       errorBuilder: (_, __, ___) => const Center(
//         child: Icon(Icons.broken_image, size: 40),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final recipeStatusProvider = Provider.of<RecipeStatusProvider>(context);
// final recipeStatus = recipeStatusProvider.getStatus(recipeId);
// final isFavorite = recipeStatus?.isFavorite ?? false;

//       final isDisabled = status != 'approved'; // Disable if not approved
//   final showFavorite = status == 'approved'; // Only show favorite if approved
//   final showEdit = showEditButton && status != 'rejected'; // Don't show edit if rejected

//  return GestureDetector(
//       onTap: isDisabled ? null : onTap,
//       child: Opacity(
//         opacity: isDisabled ? 0.6 : 1.0,
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: SizedBox(
//             width: 220,
//             height: 180,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Container(
//                   height: 120,
//                   color: Colors.grey[200],
//                   child: Stack(
//                     children: [
//                       _buildImage(image),
//                       if (showFavorite)
//                         Positioned(
//                           top: 8,
//                           right: 8,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.3),
//                               shape: BoxShape.circle,
//                             ),
//                             child:
//                                IconButton(
//   icon: Icon(
//     isFavorite ? Icons.favorite : Icons.favorite_border,
//     color: isFavorite ? Colors.red : Colors.white,
//     size: 20,
//   ),
//   onPressed: () {
//     recipeStatusProvider.toggleFavorite(recipeId);
//   },

//                               padding: EdgeInsets.zero,
//                             ),
//                           ),
//                         ),
//                       if (showEdit)
//                         Positioned(
//                           top: 8,
//                           left: 8,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.3),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               icon: const Icon(
//                                 Icons.edit,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                               onPressed: onEditPressed,
//                               padding: EdgeInsets.zero,
//                             ),
//                           ),
//                         ),
//                       Positioned(
//                         bottom: 8,
//                         left: 8,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: _getStatusColor(status),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             status.toUpperCase(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: 24,
//                         child: Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                             height: 1.2,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.star,
//                             color: Colors.amber,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             averageRate.toStringAsFixed(1),
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const Spacer(),
//                           const Icon(
//                             Icons.timer_outlined,
//                             size: 16,
//                             color: Colors.grey,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '$totalTime min',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

// // Helper method to get color based on status
// Color _getStatusColor(String status) {
//   switch (status) {
//     case 'pending':
//       return Colors.orange;
//     case 'approved':
//       return Colors.green;
//     case 'rejected':
//       return Colors.red;
//     default:
//       return Colors.grey;
//   }}
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sizzle_share/pages/RecipeScreen.dart';
// import 'package:sizzle_share/providers/recipe_status_provider/recipe_status_provider.dart'; // Correct import

// class RecipeCard extends StatelessWidget {
//   final String recipeId;
//   final String title;
//   final String? image;
//   final String totalTime;
//   final double averageRate;
//   final String status;

//   final bool showEditButton;
//   final VoidCallback? onTap;
//   final VoidCallback? onEditPressed;

//   const RecipeCard({
//     super.key,
//     required this.recipeId,
//     required this.title,
//     required this.image,
//     required this.totalTime,
//     required this.averageRate,
//     this.showEditButton = false,
//     this.onTap,
//     this.onEditPressed,
//     this.status = 'pending',
//   });

//   Widget _buildImage(String? image) {
//     if (image == null || image.isEmpty) {
//       return Container(
//         color: Colors.grey[200],
//         child: const Center(
//           child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
//         ),
//       );
//     }

//     return Image.network(
//       image,
//       fit: BoxFit.cover,
//       width: double.infinity,
//       height: double.infinity,
//       loadingBuilder: (context, child, loadingProgress) {
//         if (loadingProgress == null) return child;
//         return Center(
//           child: CircularProgressIndicator(
//             value: loadingProgress.expectedTotalBytes != null
//                 ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                 : null,
//           ),
//         );
//       },
//       errorBuilder: (_, __, ___) => const Center(
//         child: Icon(Icons.broken_image, size: 40),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final recipeStatusProvider = Provider.of<RecipeStatusProvider>(context);
//     final recipeStatus = recipeStatusProvider.getStatus(recipeId);
//     final isFavorite = recipeStatus?.isFavorite ?? false;

//     final isDisabled = status != 'approved';
//     final showFavorite = status == 'approved';
//     final showEdit = showEditButton && status != 'rejected';

//     return GestureDetector(
//       onTap: isDisabled ? null : onTap,
//       child: Opacity(
//         opacity: isDisabled ? 0.6 : 1.0,
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: SizedBox(
//             width: 220,
//             height: 180,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Container(
//                   height: 120,
//                   color: Colors.grey[200],
//                   child: Stack(
//                     children: [
//                       _buildImage(image),
//                       if (showFavorite)
//                         Positioned(
//                           top: 8,
//                           right: 8,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.3),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               icon: Icon(
//                                 isFavorite ? Icons.favorite : Icons.favorite_border,
//                                 color: isFavorite ? Colors.red : Colors.white,
//                                 size: 20,
//                               ),
//                               onPressed: () {
//                                 recipeStatusProvider.toggleFavorite(recipeId);
//                               },
//                               padding: EdgeInsets.zero,
//                             ),
//                           ),
//                         ),
//                       if (showEdit)
//                         Positioned(
//                           top: 8,
//                           left: 8,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.3),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               icon: const Icon(
//                                 Icons.edit,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                               onPressed: onEditPressed,
//                               padding: EdgeInsets.zero,
//                             ),
//                           ),
//                         ),
//                       Positioned(
//                         bottom: 8,
//                         left: 8,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: _getStatusColor(status),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             status.toUpperCase(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: 24,
//                         child: Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                             height: 1.2,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.star,
//                             color: Colors.amber,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             averageRate.toStringAsFixed(1),
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const Spacer(),
//                           const Icon(
//                             Icons.timer_outlined,
//                             size: 16,
//                             color: Colors.grey,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '$totalTime min',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return Colors.orange;
//       case 'approved':
//         return Colors.green;
//       case 'rejected':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizzle_share/pages/RecipeScreen.dart';
import 'package:sizzle_share/providers/recipe_status_provider/recipe_status_provider.dart';

class RecipeCard extends StatelessWidget {
  final String recipeId;
  final String title;
  final String? image;
  final String totalTime;
  final double averageRate;
  final String status;

  final bool showEditButton;
  final VoidCallback? onTap;
  final VoidCallback? onEditPressed;
  final VoidCallback? onFavoriteToggled;

  final bool showStatus; // Add this

  final VoidCallback? onDeletePressed; // Add this line

  const RecipeCard({
    super.key,
    required this.recipeId,
    required this.title,
    required this.image,
    required this.totalTime,
    required this.averageRate,
    this.showEditButton = false,
    this.onTap,
    this.onEditPressed,
    this.status = 'pending',
    this.onFavoriteToggled,
    this.showStatus = false,
    this.onDeletePressed, // Add this parameter
// Add this with default false
  });

  Widget _buildImage(String? image) {
    if (image == null || image.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image, size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeStatusProvider = Provider.of<RecipeStatusProvider>(context);
    final recipeStatus = recipeStatusProvider.getStatus(recipeId);
    final isFavorite = recipeStatus?.isFavorite ?? false;

    final isDisabled = status != 'approved';
    final showFavorite = status == 'approved';
    // final showEdit = showEditButton && status != 'rejected';
    final showEdit = showEditButton && status == 'pending'; // New line
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: 220,
            height: 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 120,
                  color: Colors.grey[200],
                  // child: Stack(
                  //   children: [
                  //     _buildImage(image),
                  //     if (showFavorite)
                  //       Positioned(
                  //         top: 8,
                  //         right: 8,
                  //         child: Container(
                  //           decoration: BoxDecoration(
                  //             color: Colors.black.withOpacity(0.3),
                  //             shape: BoxShape.circle,
                  //           ),
                  //           child: IconButton(
                  //             icon: Icon(
                  //               isFavorite
                  //                   ? Icons.favorite
                  //                   : Icons.favorite_border,
                  //               color: isFavorite
                  //                   ? Color(0xFFFD5D69)
                  //                   : Colors.white,
                  //               size: 20,
                  //             ),
                  //             // onPressed: () {
                  //             //   recipeStatusProvider.toggleFavorite(recipeId);
                  //             // },
                  //             onPressed: () {
                  //               recipeStatusProvider.toggleFavorite(recipeId,
                  //                   onStatusChanged: onFavoriteToggled);
                  //             },

                  //             padding: EdgeInsets.zero,
                  //           ),
                  //         ),
                  //       ),
                  //     if (showEdit)
                  //       Positioned(
                  //         top: 8,
                  //         left: 8,
                  //         child: Container(
                  //           decoration: BoxDecoration(
                  //             color: Colors.black.withOpacity(0.3),
                  //             shape: BoxShape.circle,
                  //           ),
                  //           child: IconButton(
                  //             icon: const Icon(
                  //               Icons.edit,
                  //               color: Colors.white,
                  //               size: 20,
                  //             ),
                  //             onPressed: onEditPressed,
                  //             padding: EdgeInsets.zero,
                  //           ),
                  //         ),
                  //       ),

                  //     if (showStatus) // This is the only line you're adding
                  //       Positioned(
                  //         bottom: 8,
                  //         left: 8,
                  //         child: Container(
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 8, vertical: 4),
                  //           decoration: BoxDecoration(
                  //             color: _getStatusColor(status),
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //           child: Text(
                  //             status.toUpperCase(),
                  //             style: const TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 10,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //   ],
                  // ),
                  child: Stack(
                    children: [
                      _buildImage(image),
                      if (showFavorite)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? Color(0xFFFD5D69)
                                    : Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                recipeStatusProvider.toggleFavorite(recipeId,
                                    onStatusChanged: onFavoriteToggled);
                              },
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      if (showEdit)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: onEditPressed,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      if (status == 'approved' &&
                          showEditButton) // Add this condition for delete button
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: onDeletePressed,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      if (showStatus)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            averageRate.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalTime min',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
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
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
