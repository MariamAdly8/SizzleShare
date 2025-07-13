// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:sizzle_share/models/recipe.dart';
// // import 'package:sizzle_share/services/api_service.dart';

// // class InPageSearch extends StatefulWidget {
// //   const InPageSearch({super.key});

// //   @override
// //   State<InPageSearch> createState() => _InPageSearchState();
// // }

// // class _InPageSearchState extends State<InPageSearch> {
// //   final TextEditingController _searchController = TextEditingController();
// //   final FocusNode _searchFocusNode = FocusNode();
// //   List<Recipe> _searchResults = [];
// //   bool _showSearch = false;
// //   bool _showFilters = false;
// //   bool _isLoading = false;
// //   Timer? _debounce;

// //   // Filter variables
// //   double? _minRate;
// //   double? _maxRate;
// //   int? _maxCookingTime;

// //   // Colors
// //   final Color _backgroundColor = const Color(0xFFFFFDF9);
// //   final Color _iconAndButtonColor = const Color(0xFFFD5D69);

// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     _searchFocusNode.dispose();
// //     _debounce?.cancel();
// //     super.dispose();
// //   }

// //   void _onSearchChanged() {
// //     if (_debounce?.isActive ?? false) _debounce?.cancel();
// //     _debounce = Timer(const Duration(milliseconds: 500), () {
// //       _performSearch();
// //     });
// //   }

// //   Future<void> _performSearch() async {
// //     setState(() => _isLoading = true);

// //     try {
// //       final results = await ApiService.staticSearchRecipes(
// //         query: _searchController.text,
// //         minRate: _minRate,
// //         maxRate: _maxRate,
// //         maxCookingTime: _maxCookingTime,
// //       );

// //       setState(() => _searchResults = results);
// //     } catch (e) {
// //       // This shouldn't happen now since we're handling all errors in staticSearchRecipes
// //       setState(() => _searchResults = []);
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   // Future<void> _performSearch() async {
// //   //   setState(() => _isLoading = true);

// //   //   try {
// //   //     final results = await ApiService.staticSearchRecipes(
// //   //       query: _searchController.text,
// //   //       minRate: _minRate,
// //   //       maxRate: _maxRate,
// //   //       maxCookingTime: _maxCookingTime,
// //   //     );

// //   //     setState(() => _searchResults = results);
// //   //   } catch (e) {
// //   //     if (mounted) {
// //   //       ScaffoldMessenger.of(context).showSnackBar(
// //   //         SnackBar(content: Text('Search error: ${e.toString()}')),
// //   //       );
// //   //       setState(() => _searchResults = []);
// //   //     }
// //   //   } finally {
// //   //     if (mounted) {
// //   //       setState(() => _isLoading = false);
// //   //     }
// //   //   }
// //   // }

// //   void _clearFilters() {
// //     setState(() {
// //       _minRate = null;
// //       _maxRate = null;
// //       _maxCookingTime = null;
// //     });
// //     _performSearch();
// //   }

// //   void _toggleSearch() {
// //     setState(() {
// //       _showSearch = !_showSearch;
// //       if (_showSearch) {
// //         counter++;
// //         print('ffffffffffd');
// //         print(counter);
// //         _searchFocusNode.requestFocus();

// //       } else {
// //         counter = 0;
// //         _searchController.clear();
// //         _searchResults = [];
// //         _showFilters = false;
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Material(
// //       color: Colors.transparent,
// //       child: Stack(
// //         children: [
// //           // Click catcher to close search when tapping outside
// //           if (_showSearch)
// //             GestureDetector(
// //               onTap: () {
// //                 setState(() {
// //                   _showSearch = false;
// //                   _searchController.clear();
// //                   _searchResults = [];
// //                   _showFilters = false;
// //                 });
// //               },
// //               child: Container(
// //                 color: Colors.black.withOpacity(0.3),
// //               ),
// //             ),

// //           // Search content
// //           Column(
// //             children: [
// //               // Search bar with constrained width
// //               Center(
// //                 child: GestureDetector(
// //                   onTap: _toggleSearch,
// //                   child: AnimatedContainer(
// //                     duration: const Duration(milliseconds: 300),
// //                     curve: Curves.easeInOut,
// //                     width: _showSearch
// //                         ? MediaQuery.of(context).size.width * 0.9
// //                         : 200,
// //                     height: 50,
// //                     decoration: BoxDecoration(
// //                       color: _backgroundColor,
// //                       borderRadius: BorderRadius.circular(25),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.1),
// //                           blurRadius: 10,
// //                           spreadRadius: 2,
// //                         ),
// //                       ],
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         IconButton(
// //                           icon: Icon(
// //                             _showSearch ? Icons.arrow_back : Icons.search,
// //                             color: _iconAndButtonColor,
// //                           ),
// //                           onPressed: _toggleSearch,
// //                         ),
// //                         if (_showSearch) ...[
// //                           Expanded(
// //                             child: TextField(
// //                               controller: _searchController,
// //                               focusNode: _searchFocusNode,
// //                               decoration: InputDecoration(
// //                                 hintText: 'Search recipes...',
// //                                 border: InputBorder.none,
// //                                 suffixIcon: IconButton(
// //                                   icon: Icon(Icons.filter_list,
// //                                       color: _iconAndButtonColor),
// //                                   onPressed: () {
// //                                     setState(
// //                                         () => _showFilters = !_showFilters);
// //                                   },
// //                                 ),
// //                               ),
// //                               onChanged: (_) => _onSearchChanged(),
// //                             ),
// //                           ),
// //                         ] else ...[
// //                           const Expanded(
// //                             child: Padding(
// //                               padding: EdgeInsets.symmetric(horizontal: 8),
// //                               child: Text(
// //                                 'Search recipes...',
// //                                 style: TextStyle(color: Colors.grey),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),

// //               // Search results panel
// //               if (_showSearch)
// //                 Center(
// //                   child: Container(
// //                     margin: const EdgeInsets.only(top: 10),
// //                     width: MediaQuery.of(context).size.width * 0.9,
// //                     constraints: BoxConstraints(
// //                       maxHeight: MediaQuery.of(context).size.height * 0.6,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: _backgroundColor,
// //                       borderRadius: BorderRadius.circular(12),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.2),
// //                           blurRadius: 15,
// //                           spreadRadius: 5,
// //                         ),
// //                       ],
// //                     ),
// //                     child: Column(
// //                       children: [
// //                         if (_isLoading) const LinearProgressIndicator(),
// //                         if (_showFilters) _buildFiltersSection(),
// //                         if (_searchResults.isNotEmpty)
// //                           Expanded(
// //                             child: _buildSearchResults(),
// //                           ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildFiltersSection() {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: _backgroundColor,
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Column(
// //         children: [
// //           const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold)),
// //           const SizedBox(height: 16),
// //           const Text('Rating:'),
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: TextField(
// //                   decoration:
// //                       const InputDecoration(hintText: 'Min', prefixText: '★ '),
// //                   keyboardType: TextInputType.number,
// //                   onChanged: (value) => _minRate = double.tryParse(value),
// //                 ),
// //               ),
// //               const SizedBox(width: 16),
// //               Expanded(
// //                 child: TextField(
// //                   decoration:
// //                       const InputDecoration(hintText: 'Max', prefixText: '★ '),
// //                   keyboardType: TextInputType.number,
// //                   onChanged: (value) => _maxRate = double.tryParse(value),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 16),
// //           const Text('Max Cooking Time (minutes):'),
// //           TextField(
// //             decoration: const InputDecoration(hintText: 'e.g. 30'),
// //             keyboardType: TextInputType.number,
// //             onChanged: (value) => _maxCookingTime = int.tryParse(value),
// //           ),
// //           const SizedBox(height: 16),
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.grey[300]),
// //                   onPressed: _clearFilters,
// //                   child: const Text('Clear Filters'),
// //                 ),
// //               ),
// //               const SizedBox(width: 16),
// //               Expanded(
// //                 child: ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: _iconAndButtonColor,
// //                   ),
// //                   onPressed: () {
// //                     setState(() => _showFilters = false);
// //                     _performSearch();
// //                   },
// //                   child: const Text('Apply Filters',
// //                       style: TextStyle(color: Colors.white)),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSearchResults() {
// //     if (_searchResults.isEmpty) {
// //       return const Center(
// //         child: Padding(
// //           padding: EdgeInsets.all(16.0),
// //           child: Text('No recipes found', style: TextStyle(fontSize: 16)),
// //         ),
// //       );
// //     }

// //     return ListView.builder(
// //       shrinkWrap: true,
// //       itemCount: _searchResults.length,
// //       itemBuilder: (context, index) {
// //         final recipe = _searchResults[index];
// //         return ListTile(
// //           leading: recipe.imageURL != null
// //               ? Image.network(recipe.imageURL!,
// //                   width: 50, height: 50, fit: BoxFit.cover)
// //               : const Icon(Icons.fastfood, size: 50),
// //           title: Text(recipe.recipeName),
// //           subtitle: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               if (recipe.averageRate != null)
// //                 Row(
// //                   children: [
// //                     const Icon(Icons.star, color: Colors.amber, size: 16),
// //                     Text(' ${recipe.averageRate!.toStringAsFixed(1)}'),
// //                   ],
// //                 ),
// //               Text('${recipe.totalTime} min'),
// //               if (recipe.cuisine != null) Text(recipe.cuisine!),
// //             ],
// //           ),
// //           onTap: () {
// //             // Handle recipe selection
// //           },
// //         );
// //       },
// //     );
// //   }
// // }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:sizzle_share/models/recipe.dart';
// import 'package:sizzle_share/pages/RecipeScreen.dart';
// import 'package:sizzle_share/services/api_service.dart';

// class InPageSearch extends StatefulWidget {
//   const InPageSearch({super.key});

//   @override
//   State<InPageSearch> createState() => _InPageSearchState();
// }

// class _InPageSearchState extends State<InPageSearch> {
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();
//   List<Recipe> _searchResults = [];
//   bool _showSearch = false;
//   bool _showFilters = false;
//   bool _isLoading = false;
//   Timer? _debounce;

//   // Filter variables
//   double? _minRate;
//   double? _maxRate;
//   int? _maxCookingTime;
//   bool _hasSearchRun = false;

//   // Colors
//   final Color _backgroundColor = const Color(0xFFFFFDF9);
//   final Color _iconAndButtonColor = const Color(0xFFFD5D69);

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       _performSearch();
//     });
//   }

//   Future<void> _performSearch() async {
//     setState(() {
//       _isLoading = true;
//       _hasSearchRun = true; // Track that a search has been attempted
//     });

//     try {
//       final results = await ApiService.staticSearchRecipes(
//         query: _searchController.text,
//         minRate: _minRate,
//         maxRate: _maxRate,
//         maxCookingTime: _maxCookingTime,
//       );

//       setState(() => _searchResults = results);
//     } catch (e) {
//       // This shouldn't happen now since we're handling all errors in staticSearchRecipes
//       setState(() => _searchResults = []);
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   // Future<void> _performSearch() async {
//   //   setState(() => _isLoading = true);

//   //   try {
//   //     final results = await ApiService.staticSearchRecipes(
//   //       query: _searchController.text,
//   //       minRate: _minRate,
//   //       maxRate: _maxRate,
//   //       maxCookingTime: _maxCookingTime,
//   //     );

//   //     setState(() => _searchResults = results);
//   //   } catch (e) {
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('Search error: ${e.toString()}')),
//   //       );
//   //       setState(() => _searchResults = []);
//   //     }
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() => _isLoading = false);
//   //     }
//   //   }
//   // }

//   void _clearFilters() {
//     setState(() {
//       _minRate = null;
//       _maxRate = null;
//       _maxCookingTime = null;
//       _hasSearchRun = false; // Reset search run flag
//     });
//     _performSearch();
//   }

//   void _closeSearchPanel() {
//     setState(() {
//       _showSearch = false;
//       _searchController.clear();
//       _searchResults = [];
//       _showFilters = false;
//     });
//   }

//   // void _toggleSearch() {
//   //   setState(() {
//   //     _showSearch = !_showSearch;
//   //     if (_showSearch) {
//   //       counter++;
//   //       print('ffffffffffd');
//   //       print(counter);
//   //       _searchFocusNode.requestFocus();
//   //     } else {
//   //       counter = 0;
//   //       _searchController.clear();
//   //       _searchResults = [];
//   //       _showFilters = false;
//   //     }
//   //   });
//   // }

//   void _toggleSearch() {
//     setState(() {
//       _showSearch = !_showSearch;
//       if (_showSearch) {
//         counter++;
//         print('ffffffffffd');
//         print(counter);
//         _searchFocusNode.requestFocus();
//       } else {
//         _closeSearchPanel(); // Use the method instead of manual reset
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: Stack(
//         children: [
//           // Click catcher to close search when tapping outside
//           if (_showSearch)
//             GestureDetector(
//               onTap: _closeSearchPanel,
//               child: Container(
//                 color: Colors.black.withOpacity(0.3),
//               ),
//             ),

//           // GestureDetector(
//           //   onTap: () {
//           //     setState(() {
//           //       _showSearch = false;
//           //       _searchController.clear();
//           //       _searchResults = [];
//           //       _showFilters = false;
//           //     });
//           //   },
//           //   child: Container(
//           //     color: Colors.black.withOpacity(0.3),
//           //   ),
//           // ),

//           // Search content
//           Column(
//             children: [
//               // Search bar with constrained width
//               Center(
//                 child: GestureDetector(
//                   onTap: _toggleSearch,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                     width: _showSearch
//                         ? MediaQuery.of(context).size.width * 0.9
//                         : 200,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: _backgroundColor,
//                       borderRadius: BorderRadius.circular(25),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           icon: Icon(
//                             _showSearch ? Icons.arrow_back : Icons.search,
//                             color: _iconAndButtonColor,
//                           ),
//                           onPressed: _toggleSearch,
//                         ),
//                         if (_showSearch) ...[
//                           Expanded(
//                             child: TextField(
//                               controller: _searchController,
//                               focusNode: _searchFocusNode,
//                               decoration: InputDecoration(
//                                 hintText: 'Search recipes...',
//                                 border: InputBorder.none,
//                                 suffixIcon: IconButton(
//                                   icon: Icon(Icons.filter_list,
//                                       color: _iconAndButtonColor),
//                                   onPressed: () {
//                                     setState(
//                                         () => _showFilters = !_showFilters);
//                                   },
//                                 ),
//                               ),
//                               onChanged: (_) => _onSearchChanged(),
//                             ),
//                           ),
//                         ] else ...[
//                           const Expanded(
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 8),
//                               child: Text(
//                                 'Search recipes...',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               // Search results panel
//               if (_showSearch)
//                 Center(
//                   child: Container(
//                     margin: const EdgeInsets.only(top: 10),
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     constraints: BoxConstraints(
//                       maxHeight: MediaQuery.of(context).size.height * 0.6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _backgroundColor,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 15,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         if (_isLoading) const LinearProgressIndicator(),
//                         if (_showFilters) _buildFiltersSection(),
//                         if (_searchResults.isNotEmpty)
//                           Expanded(
//                             child: _buildSearchResults(),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFiltersSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 16),
//           const Text('Rating:'),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   decoration:
//                       const InputDecoration(hintText: 'Min', prefixText: '★ '),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) => _minRate = double.tryParse(value),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: TextField(
//                   decoration:
//                       const InputDecoration(hintText: 'Max', prefixText: '★ '),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) => _maxRate = double.tryParse(value),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Text('Max Cooking Time (minutes):'),
//           TextField(
//             decoration: const InputDecoration(hintText: 'e.g. 30'),
//             keyboardType: TextInputType.number,
//             onChanged: (value) => _maxCookingTime = int.tryParse(value),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[300]),
//                   onPressed: _clearFilters,
//                   child: const Text('Clear Filters'),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _iconAndButtonColor,
//                   ),
//                   onPressed: () {
//                     setState(() => _showFilters = false);
//                     _performSearch();
//                   },
//                   child: const Text('Apply Filters',
//                       style: TextStyle(color: Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

// //   Widget _buildSearchResults() {
// //     if (_searchResults.isEmpty) {
// //       return const Center(
// //         child: Padding(
// //           padding: EdgeInsets.all(16.0),
// //           child: Text('No recipes found', style: TextStyle(fontSize: 16)),
// //         ),
// //       );
// //     }

// //     return ListView.builder(
// //       shrinkWrap: true,
// //       itemCount: _searchResults.length,
// //       itemBuilder: (context, index) {
// //         final recipe = _searchResults[index];
// //         return ListTile(
// //           leading: recipe.imageURL != null
// //               ? Image.network(recipe.imageURL!,
// //                   width: 50, height: 50, fit: BoxFit.cover)
// //               : const Icon(Icons.fastfood, size: 50),
// //           title: Text(recipe.recipeName),
// //           subtitle: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               if (recipe.averageRate != null)
// //                 Row(
// //                   children: [
// //                     const Icon(Icons.star, color: Colors.amber, size: 16),
// //                     Text(' ${recipe.averageRate!.toStringAsFixed(1)}'),
// //                   ],
// //                 ),
// //               Text('${recipe.totalTime} min'),
// //               if (recipe.cuisine != null) Text(recipe.cuisine!),
// //             ],
// //           ),
// //           onTap: () {
// //             // Handle recipe selection
// //           },
// //         );
// //       },
// //     );
// //   }
// // }

// // b7awel ash8l el search youm el 7d
//   Widget _buildSearchResults() {
//     // Show loading indicator while searching
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(
//           color: Color(0xFFFD5D69),
//         ),
//       );
//     }

//     // Show message when no results after search
//     if (_hasSearchRun && _searchResults.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.search_off, size: 50, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(
//               'No recipes found',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (_minRate != null || _maxRate != null || _maxCookingTime != null)
//               TextButton(
//                 onPressed: _clearFilters,
//                 child: const Text(
//                   'Clear filters',
//                   style: TextStyle(color: Color(0xFFFD5D69)),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }

//     // Show actual results
//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: _searchResults.length,
//       itemBuilder: (context, index) {
//         final recipe = _searchResults[index];
//         return ListTile(
//           leading: recipe.imageURL != null
//               ? Image.network(recipe.imageURL!,
//                   width: 50, height: 50, fit: BoxFit.cover)
//               : const Icon(Icons.fastfood, size: 50),
//           title: Text(recipe.recipeName),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (recipe.averageRate != null)
//                 Row(
//                   children: [
//                     const Icon(Icons.star, color: Colors.amber, size: 16),
//                     Text(' ${recipe.averageRate!.toStringAsFixed(1)}'),
//                   ],
//                 ),
//               Text('${recipe.totalTime} min'),
//               if (recipe.cuisine != null) Text(recipe.cuisine!),
//             ],
//           ),
//           onTap: () {
//             _closeSearchPanel(); // Close the search panel

//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => RecipeDetailPage(
//                   recipeId: recipe.id,
//                   recipeItem: recipe,
//                   onRatingChanged: (newRating) {
//                     // Optional: Update rating in search results if needed
//                     setState(() {
//                       recipe.averageRate = newRating;
//                     });
//                   },
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
//           // onTap: () {
//           //   // Close the search panel
//           //   setState(() {
//           //     _showSearch = false;
//           //     _searchController.clear();
//           //   });

//           //   // Navigate to RecipeDetailPage
//           //   Navigator.push(
//           //     context,
//           //     MaterialPageRoute(
//           //       builder: (context) => RecipeDetailPage(
//           //         recipeId: recipe.id,
//           //         recipeItem: recipe,
//           //         onRatingChanged: (newRating) {
//           //           // Update the rating in search results if needed
//           //           setState(() {
//           //             recipe.averageRate = newRating;
//           //           });
//           //         },
//           //       ),
//           //     ),
//           //   );
//           // },

//           // riiiiskkkkkkk

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizzle_share/models/recipe.dart';
import 'package:sizzle_share/pages/RecipeScreen.dart';
import 'package:sizzle_share/services/api_service.dart';

class InPageSearch extends StatefulWidget {
  const InPageSearch({super.key});

  @override
  State<InPageSearch> createState() => _InPageSearchState();
}

class _InPageSearchState extends State<InPageSearch> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Recipe> _searchResults = [];
  bool _showSearch = false;
  bool _showFilters = false;
  bool _isLoading = false;
  bool _hasSearchRun = false;
  Timer? _debounce;
  double? _minRate;
  double? _maxRate;
  int? _maxCookingTime;
  final Color _backgroundColor = const Color(0xFFFFFDF9);
  final Color _iconAndButtonColor = const Color(0xFFFD5D69);

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _hasSearchRun = true;
    });

    try {
      final results = await ApiService.staticSearchRecipes(
        query: _searchController.text,
        minRate: _minRate,
        maxRate: _maxRate,
        maxCookingTime: _maxCookingTime,
      );
      setState(() => _searchResults = results);
    } catch (e) {
      setState(() => _searchResults = []);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _minRate = null;
      _maxRate = null;
      _maxCookingTime = null;
      _hasSearchRun = false;
    });
    _performSearch();
  }

  void _closeSearchPanel() {
    setState(() {
      _showSearch = false;
      _searchController.clear();
      _searchResults = [];
      _showFilters = false;
    });
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (_showSearch) {
        _searchFocusNode.requestFocus();
      } else {
        _closeSearchPanel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          if (_showSearch)
            GestureDetector(
              onTap: _closeSearchPanel,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _toggleSearch,
                  // child: AnimatedContainer(
                  //   duration: const Duration(milliseconds: 300),
                  //   curve: Curves.easeInOut,
                  //   width: _showSearch
                  //       ? MediaQuery.of(context).size.width * 0.9
                  //       : 200,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: _showSearch
                        ? MediaQuery.of(context).size.width // Full width
                        : MediaQuery.of(context).size.width * 0.8,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showSearch ? Icons.arrow_back : Icons.search,
                            color: _iconAndButtonColor,
                          ),
                          onPressed: _toggleSearch,
                        ),
                        if (_showSearch) ...[
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Search recipes...',
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.filter_list,
                                      color: _iconAndButtonColor),
                                  onPressed: () {
                                    setState(
                                        () => _showFilters = !_showFilters);
                                  },
                                ),
                              ),
                              onChanged: (_) => _onSearchChanged(),
                            ),
                          ),
                        ] else ...[
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Search recipes...',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (_showSearch)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width * 0.9,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (_isLoading) const LinearProgressIndicator(),
                        if (_showFilters) _buildFiltersSection(),
                        Expanded(
                          // Always expanded container
                          child:
                              _buildSearchResults(), // This will show either results or empty state
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Rating:'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration:
                      const InputDecoration(hintText: 'Min', prefixText: '★ '),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _minRate = double.tryParse(value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration:
                      const InputDecoration(hintText: 'Max', prefixText: '★ '),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _maxRate = double.tryParse(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Max Cooking Time (minutes):'),
          TextField(
            decoration: const InputDecoration(hintText: 'e.g. 30'),
            keyboardType: TextInputType.number,
            onChanged: (value) => _maxCookingTime = int.tryParse(value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300]),
                  onPressed: _clearFilters,
                  child: const Text(
                    'Clear Filters',
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _iconAndButtonColor,
                  ),
                  onPressed: () {
                    setState(() => _showFilters = false);
                    _performSearch();
                  },
                  child: const Text('Apply Filters',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Widget _buildSearchResults() {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(
//           color: Color(0xFFFD5D69),
//         ),
//       );
//     }

//     if (_hasSearchRun && _searchResults.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.search_off, size: 50, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(
//               'No recipes found',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (_minRate != null || _maxRate != null || _maxCookingTime != null)
//               TextButton(
//                 onPressed: _clearFilters,
//                 child: const Text(
//                   'Clear filters',
//                   style: TextStyle(color: Color(0xFFFD5D69)),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: _searchResults.length,
//       itemBuilder: (context, index) {
//         final recipe = _searchResults[index];
//         return ListTile(
//           leading: recipe.imageURL != null
//               ? Image.network(recipe.imageURL!,
//                   width: 50, height: 50, fit: BoxFit.cover)
//               : const Icon(Icons.fastfood, size: 50),
//           title: Text(recipe.recipeName),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (recipe.averageRate != null)
//                 Row(
//                   children: [
//                     const Icon(Icons.star, color: Colors.amber, size: 16),
//                     Text(' ${recipe.averageRate!.toStringAsFixed(1)}'),
//                   ],
//                 ),
//               Text('${recipe.totalTime} min'),
//               if (recipe.cuisine != null) Text(recipe.cuisine!),
//             ],
//           ),
//           onTap: () {
//             _closeSearchPanel();
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => RecipeDetailPage(
//                   recipeId: recipe.id,
//                   recipeItem: recipe,
//                   onRatingChanged: (newRating) {
//                     setState(() {
//                       recipe.averageRate = newRating;
//                     });
//                   },
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFD5D69),
        ),
      );
    }

    if (_hasSearchRun && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No recipes found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_minRate != null || _maxRate != null || _maxCookingTime != null)
              TextButton(
                onPressed: _clearFilters,
                child: const Text(
                  'Clear filters',
                  style: TextStyle(color: Color(0xFFFD5D69)),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final recipe = _searchResults[index];
        return ListTile(
          leading: recipe.imageURL != null
              ? Image.network(recipe.imageURL!,
                  width: 50, height: 50, fit: BoxFit.cover)
              : const Icon(Icons.fastfood, size: 50),
          title: Text(recipe.recipeName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe.averageRate != null)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${recipe.averageRate!.toStringAsFixed(1)}'),
                  ],
                ),
              Text('${recipe.totalTime} min'),
              if (recipe.cuisine != null) Text(recipe.cuisine!),
            ],
          ),
          onTap: () {
            _closeSearchPanel();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailPage(
                  recipeId: recipe.id,
                  recipeItem: recipe,
                  onRatingChanged: (newRating) {
                    setState(() {
                      recipe.averageRate = newRating;
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
