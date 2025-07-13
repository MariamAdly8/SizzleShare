// import 'dart:typed_data';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:image_picker/image_picker.dart';
// import 'package:sizzle_share/pages/HomePage.dart';
// import 'package:sizzle_share/pages/ProfilePage.dart';
// import 'package:sizzle_share/pages/ShoppingListPage.dart';
// import 'package:sizzle_share/pages/meal_prep_screen.dart';
// import 'package:sizzle_share/services/api_service.dart';
// import 'package:multi_select_flutter/multi_select_flutter.dart';
// import 'package:sizzle_share/widgets/custom_bottom_navbar.dart';

// class CreateRecipePage extends StatefulWidget {
//   const CreateRecipePage({super.key});

//   @override
//   State<CreateRecipePage> createState() => _CreateRecipePageState();
// }

// class _CreateRecipePageState extends State<CreateRecipePage> {
//   final _titleController = TextEditingController();
//   final _timeController = TextEditingController();
//   final _customCuisineController = TextEditingController();
//   int _currentIndex = 2;
//   String _capitalizeTitle(String title) {
//     if (title.isEmpty) return title;

//     // Split into words, capitalize each word, and join them back
//     return title.split(' ').map((word) {
//       if (word.isEmpty) return word;
//       return word[0].toUpperCase() + word.substring(1).toLowerCase();
//     }).join(' ');
//   }

//   final List<TextEditingController> _instructionControllers = [
//     TextEditingController()
//   ];

//   List<Map<String, String>> _ingredients = [
//     {'quantity': '', 'name': ''},
//   ];

//   final List<String> _categoryOptions = [
//     "Quick & Easy",
//     "Breakfast",
//     "Lunch",
//     "Dinner",
//     "Desserts",
//     "Snacks",
//     "Vegan",
//     "Keto",
//     "Low Carb",
//     "Gluten-Free",
//     "Diabeic-Friendly",
//     "Heart-Healthy",
//     "Weight-Loss"
//   ];

//   final List<String> _cuisineOptions = [
//     'Egyptian',
//     'Italian',
//     'Asian',
//     'American',
//     'Indian',
//     'Mexican',
//     'Other'
//   ];

//   String? _selectedCategory;
//   String? _selectedCuisine;
//   List<String> _selectedCategories = [];

//   Uint8List? _imageBytes;
//   String? _imageFileName;
//   XFile? _pickedFile;

//   void _removeImage() {
//     setState(() {
//       _imageBytes = null;
//       _imageFileName = null;
//       _pickedFile = null;
//     });
//   }

//   void _onItemTapped(int index) {
//     if (index == _currentIndex) return;

//     setState(() {
//       _currentIndex = index;
//     });

//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const HomePage()),
//         );
//         break;
//       case 1:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
//         );
//         break;
//       case 2:
//         break;
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const MealPrepScreen()),
//         );
//         break;
//       case 4:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const ProfileScreen()),
//         );
//         break;
//     }
//   }

//   void _validateBeforePublish() {
//     final title = _titleController.text.trim();
//     final timeText = _timeController.text.trim();
//     final time = int.tryParse(timeText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

//     final instructions = _instructionControllers
//         .map((controller) => controller.text.trim())
//         .where((text) => text.isNotEmpty)
//         .toList();

//     String? politeMessage;

//     if (title.isEmpty) {
//       politeMessage = "Kindly enter a recipe title before publishing.";
//     } else if (time <= 0) {
//       politeMessage = "Please provide a valid cooking time.";
//     } else if (_selectedCategories.isEmpty) {
//       politeMessage = "Please select at least one category.";
//     } else if (_selectedCuisine == null) {
//       politeMessage = "Please select a cuisine.";
//     } else if (_selectedCuisine == 'Other' &&
//         _customCuisineController.text.trim().isEmpty) {
//       politeMessage = "Please enter your custom cuisine.";
//     } else if (instructions.isEmpty) {
//       politeMessage = "Please add at least one instruction step.";
//     } else if (_ingredients
//         .where((ing) => ing['name']!.isNotEmpty && ing['quantity']!.isNotEmpty)
//         .toList()
//         .isEmpty) {
//       politeMessage = "Please add at least one ingredient.";
//     }

//     if (politeMessage != null) {
//       _showDialog(politeMessage); // Friendly message
//       return;
//     }

//     _showPublishConfirmation(); // All fields are valid, confirm publish
//   }

//   void _showPublishConfirmation() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15)), // ✅ Rounded corners
//         title: const Text(
//           "Confirm Publish",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF333333),
//           ),
//         ),
//         content: const Text(
//           "Are you sure you want to publish this recipe?",
//           style: TextStyle(color: Color(0xFF333333)),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text(
//               "No",
//               style: TextStyle(color: Colors.purple), // ✅ Same as Cancel popup
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               _createRecipe(); // ✅ Proceed to create recipe
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFD5D69), // ✅ Pink button
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20)),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//             ),
//             child: const Text(
//               "Yes, Publish",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCancelConfirmation() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Confirm Cancel"),
//         content: const Text(
//             "Are you sure you want to cancel? All changes will be lost."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text("No"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               Navigator.of(context).pop(); // Go back to previous screen
//             },
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFFD5D69)),
//             child: const Text("Yes, Cancel",
//                 style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickImage() async {
//     try {
//       if (kIsWeb) {
//         final result = await FilePicker.platform.pickFiles(
//           type: FileType.image,
//           allowMultiple: false,
//         );
//         if (result != null && result.files.isNotEmpty) {
//           final file = result.files.first;
//           setState(() {
//             _imageBytes = file.bytes;
//             _imageFileName = file.name;
//             _pickedFile = null;
//           });
//         }
//       } else {
//         final pickedFile = await ImagePicker().pickImage(
//           source: ImageSource.gallery,
//           maxWidth: 1200,
//           maxHeight: 1200,
//           imageQuality: 85,
//         );
//         if (pickedFile != null) {
//           final bytes = await pickedFile.readAsBytes();
//           setState(() {
//             _pickedFile = pickedFile;
//             _imageBytes = bytes;
//             _imageFileName = pickedFile.name;
//           });
//         }
//       }
//     } catch (e) {
//       _showDialog("Error picking image. Please try again.");
//     }
//   }

//   void _addIngredient() {
//     setState(() => _ingredients.add({'quantity': '', 'name': ''}));
//   }

//   void _removeIngredient(int index) {
//     if (_ingredients.length > 1) {
//       setState(() => _ingredients.removeAt(index));
//     }
//   }

//   void _addInstruction() {
//     setState(() {
//       _instructionControllers.add(TextEditingController());
//     });
//   }

//   void _removeInstruction(int index) {
//     setState(() {
//       _instructionControllers[index].dispose();
//       _instructionControllers.removeAt(index);
//     });
//   }

//   Future<void> _createRecipe() async {
//     // final title = _titleController.text.trim();
//     final title = _capitalizeTitle(
//         _titleController.text.trim()); // Capitalize the title here

//     final timeText = _timeController.text.trim();
//     final time = int.tryParse(timeText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

//     final instructions = _instructionControllers
//         .map((controller) => controller.text.trim())
//         .where((text) => text.isNotEmpty)
//         .toList();

//     if (title.isEmpty) {
//       _showDialog("Please enter a recipe title.");
//       return;
//     }

//     if (time <= 0) {
//       _showDialog("Please enter a valid time in minutes.");
//       return;
//     }

//     if (_selectedCategories.isEmpty) {
//       // ✅ Multi-selection check
//       _showDialog("Please select at least one category.");
//       return;
//     }

//     if (_selectedCuisine == null) {
//       _showDialog("Please select a cuisine.");
//       return;
//     }

//     String cuisine = _selectedCuisine!;
//     if (cuisine == 'Other') {
//       cuisine = _customCuisineController.text.trim();
//       if (cuisine.isEmpty) {
//         _showDialog("Please enter the custom cuisine.");
//         return;
//       }
//     }

//     if (instructions.isEmpty) {
//       _showDialog("Please add at least one instruction.");
//       return;
//     }

//     final validIngredients = _ingredients
//         .where((ing) => ing['name']!.isNotEmpty && ing['quantity']!.isNotEmpty)
//         .toList();

//     if (validIngredients.isEmpty) {
//       _showDialog("Please add at least one ingredient.");
//       return;
//     }

//     try {
//       final apiService = ApiService();
//       await apiService.init();

//       await apiService.createRecipe(
//         title: title,
//         description: instructions,
//         totalTime: time.toString(),
//         cuisine: cuisine,
//         ingredients: validIngredients,
//         category: _selectedCategories, // ✅ Correct multi-selection list
//         imageBytes: _imageBytes,
//         imageFileName: _imageFileName,
//       );

//       if (mounted) {
//         _showDialog("Recipe created successfully!", isSuccess: true);
//       }
//     } catch (e) {
//       _showDialog("Failed to create recipe: ${e.toString()}");
//     }
//   }

//   void _showDialog(String message, {bool isSuccess = false}) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: isSuccess
//             ? Text(
//                 "Success",
//                 style: TextStyle(
//                   color: Color(0xFFFD5D69),
//                   fontWeight: FontWeight.bold,
//                 ),
//               )
//             : null, // ✅ No title for polite validation messages
//         content: Text(
//           message,
//           style: TextStyle(color: Color(0xFF333333)),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               //   Navigator.of(ctx).pop();
//               //   if (isSuccess) {
//               //     Navigator.of(context).pop();
//               //   }
//               // },
//               Navigator.of(ctx).pop();
//               if (isSuccess) {
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(
//                       builder: (context) => const ProfileScreen()),
//                 );
//               }
//             },
//             child: Text(
//               "OK",
//               style: TextStyle(color: Color(0xFFFD5D69)),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _timeController.dispose();
//     _customCuisineController.dispose();
//     for (var controller in _instructionControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         title: const Text("Create Recipe",
//             style: TextStyle(
//               color: Color(0xFFFD5D69),
//               fontWeight: FontWeight.bold,
//             )),
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             color: Color(0xFFFFFDF9), // Same color as background
//           ),
//         ),
//         backgroundColor: Color(0xFFFFFDF9),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Recipe Image",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: Color(0xFFFD5D69),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   height: 200,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.4),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: _imageBytes == null
//                           ? Color.fromARGB(255, 236, 194, 194)
//                           : Color(0xFFFD5D69),
//                       width: 2,
//                     ),
//                   ),
//                   child: _imageBytes == null
//                       ? Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.camera_alt,
//                                   color: Color(0xFFBBBBBB), size: 40),
//                               const SizedBox(height: 8),
//                               ElevatedButton(
//                                 onPressed: _pickImage,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Color(0xFFFD5D69),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(20)),
//                                 ),
//                                 child: Text(
//                                   "Add Recipe Image",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : Stack(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.memory(
//                                 _imageBytes!,
//                                 width: double.infinity,
//                                 fit: BoxFit
//                                     .scaleDown, // Changed from BoxFit.cover
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 16,
//                               right: 16,
//                               child: Row(
//                                 children: [
//                                   ElevatedButton(
//                                     onPressed: _pickImage,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor:
//                                           Colors.white.withOpacity(0.9),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(20)),
//                                       padding:
//                                           EdgeInsets.symmetric(horizontal: 16),
//                                     ),
//                                     child: Text(
//                                       "Change Image",
//                                       style:
//                                           TextStyle(color: Color(0xFFFD5D69)),
//                                     ),
//                                   ),
//                                   SizedBox(width: 8),
//                                   ElevatedButton(
//                                     onPressed: _removeImage,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor:
//                                           Colors.white.withOpacity(0.9),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(20)),
//                                       padding:
//                                           EdgeInsets.symmetric(horizontal: 16),
//                                     ),
//                                     child: Text(
//                                       "Remove",
//                                       style: TextStyle(color: Colors.red),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(
//                 hintText: "Recipe title",
//                 filled: true,
//                 fillColor:
//                     Color(0xFFFFFDF9), // Soft off-white / cream background
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide:
//                       BorderSide(color: Color(0xFFDDDDDD)), // Light grey border
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(
//                       color: Color.fromARGB(
//                           255, 236, 194, 194)), // Same grey when inactive
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(
//                       color: Color(0xFFFD5D69),
//                       width: 2), // Pink border when focused
//                 ),
//                 hintStyle:
//                     TextStyle(color: Color(0xFF999999)), // Soft grey hint text
//               ),
//               style:
//                   TextStyle(color: Color(0xFF333333)), // Dark grey input text
//             ),

//             const SizedBox(height: 20),

//             TextField(
//               controller: _timeController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 hintText: "Time (e.g. 30 minutes)",
//                 filled: true,
//                 fillColor:
//                     Color(0xFFFFFDF9), // Soft off-white / cream background
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide:
//                       BorderSide(color: Color(0xFFDDDDDD)), // Light grey border
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(
//                       color: Color.fromARGB(255, 236, 194,
//                           194)), // Soft pinkish-grey border when inactive
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(
//                       color: Color(0xFFFD5D69),
//                       width: 2), // Pink border when focused
//                 ),
//                 hintStyle: TextStyle(
//                     color: Color(0xFF999999)), // Medium grey hint text
//               ),
//               style:
//                   TextStyle(color: Color(0xFF333333)), // Dark grey input text
//             ),

//             const SizedBox(height: 20),

//             MultiSelectDialogField(
//               items: _categoryOptions
//                   .map((e) => MultiSelectItem<String>(e, e))
//                   .toList(),
//               title: Text("Select Categories"),
//               selectedColor: Color(0xFFFD5D69), // Pink selection color
//               decoration: BoxDecoration(
//                 color: Color(0xFFFFFDF9), // Soft off-white background
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//                 border: Border.all(
//                   color:
//                       Color.fromARGB(255, 236, 194, 194), // Light grey border
//                   width: 1,
//                 ),
//               ),
//               buttonIcon: Icon(
//                 Icons.arrow_drop_down,
//                 color: Color(0xFFFD5D69), // Pink dropdown arrow
//               ),
//               buttonText: Text(
//                 "Select one or more categories",
//                 style: TextStyle(
//                   color: Color(0xFF999999), // Hint text color
//                   fontSize: 16,
//                 ),
//               ),
//               onConfirm: (results) {
//                 setState(() {
//                   _selectedCategories = results.cast<String>();
//                 });
//               },
//               chipDisplay: MultiSelectChipDisplay(
//                 chipColor: Color(0xFFFFFDF9), // Soft background for chips
//                 textStyle:
//                     TextStyle(color: Color(0xFF333333)), // Dark grey text
//                 onTap: (value) {
//                   setState(() {
//                     _selectedCategories.remove(value);
//                   });
//                 },
//               ),
//             ),
// // customMultiSelect(context),

//             const SizedBox(height: 20),

//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 DropdownButtonFormField<String>(
//                   value: _selectedCuisine,
//                   items: _cuisineOptions.map((e) {
//                     return DropdownMenuItem(
//                       value: e,
//                       child: Text(
//                         e,
//                         style: TextStyle(
//                           color: Color(0xFF333333), // Dark grey option text
//                           fontSize: 16,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCuisine = value;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     hintText: "Select Cuisine",
//                     hintStyle: TextStyle(
//                         color: Color(0xFF999999)), // Medium grey hint text

//                     filled: true,
//                     fillColor: Color(0xFFFFFDF9), // Soft off-white background
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(
//                           color: Color(0xFFDDDDDD)), // Light grey border
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(
//                           color: Color.fromARGB(255, 236, 194,
//                               194)), // Soft pinkish-grey when inactive
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(
//                           color: Color(0xFFFD5D69),
//                           width: 2), // Pink border when focused
//                     ),
//                   ),
//                   dropdownColor: Color(0xFFF6F0F6), // Light lavender background
//                   style: TextStyle(
//                       color: Color(0xFF333333),
//                       fontSize: 16), // Selected item text style
//                   iconEnabledColor: Color(0xFFFD5D69), // Pink dropdown arrow
//                 ),
//                 if (_selectedCuisine == 'Other') ...[
//                   const SizedBox(height: 10),
//                   TextField(
//                     controller: _customCuisineController,
//                     decoration: InputDecoration(
//                       hintText: "Enter custom cuisine",
//                       hintStyle: TextStyle(
//                           color: Color(0xFF999999)), // Medium grey hint text

//                       filled: true,
//                       fillColor: Color(0xFFFFFDF9), // Soft off-white background
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide(
//                             color: Color(0xFFDDDDDD)), // Light grey border
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide(
//                             color: Color.fromARGB(255, 236, 194,
//                                 194)), // Soft pinkish-grey when inactive
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide(
//                             color: Color(0xFFFD5D69),
//                             width: 2), // Pink border when focused
//                       ),
//                     ),
//                     style:
//                         TextStyle(color: Color(0xFF333333)), // Input text color
//                   ),
//                 ]
//               ],
//             ),

//             const SizedBox(height: 20),

//             const Text(
//               "Ingredients",
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                   color: Color(0xFFFD5D69)),
//             ),
//             const SizedBox(height: 8),

//             ..._ingredients.asMap().entries.map((entry) {
//               final index = entry.key;
//               final item = entry.value;

//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 2,
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: 'Amt',
//                           filled: true,
//                           fillColor: Color(0xFFFFFDF9),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(color: Color(0xFFDDDDDD)),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                                 color: Color.fromARGB(255, 236, 194, 194)),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide:
//                                 BorderSide(color: Color(0xFFFD5D69), width: 2),
//                           ),
//                           hintStyle: TextStyle(color: Color(0xFF999999)),
//                         ),
//                         style: TextStyle(color: Color(0xFF333333)),
//                         onChanged: (value) => item['quantity'] = value,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       flex: 4,
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: 'Ingredient...',
//                           filled: true,
//                           fillColor: Color(0xFFFFFDF9),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(color: Color(0xFFDDDDDD)),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                                 color: Color.fromARGB(255, 236, 194, 194)),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide:
//                                 BorderSide(color: Color(0xFFFD5D69), width: 2),
//                           ),
//                           hintStyle: TextStyle(color: Color(0xFF999999)),
//                         ),
//                         style: TextStyle(color: Color(0xFF333333)),
//                         onChanged: (value) => item['name'] = value,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.remove_circle,
//                           color: Color(0xFFFD5D69), size: 24), // ✅ Fixed size
//                       onPressed: () => _removeIngredient(index),
//                     ),
//                   ],
//                 ),
//               );
//             }),

//             const SizedBox(height: 12),

//             ElevatedButton(
//               onPressed: _addIngredient,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFFD5D69), // Pink button
//                 shape: RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(20)), // Match instruction button
//                 padding: EdgeInsets.symmetric(
//                     horizontal: 20, vertical: 14), // Match instruction button
//               ),
//               child: const Text(
//                 "+ Add Ingredient",
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),

//             const SizedBox(height: 20),

//             const SizedBox(height: 20),

//             const Text(
//               "Instructions",
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                   color: Color(0xFFFD5D69)),
//             ),
//             const SizedBox(height: 8),

//             ..._instructionControllers.asMap().entries.map((entry) {
//               final index = entry.key;
//               final controller = entry.value;

//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Step number display
//                     Container(
//                       width: 30,
//                       height: 30,
//                       decoration: BoxDecoration(
//                         color: Color(0xFFFD5D69),
//                         shape: BoxShape.circle,
//                       ),
//                       alignment: Alignment.center,
//                       child: Text(
//                         '${index + 1}',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextField(
//                         controller: controller,
//                         maxLines: null,
//                         decoration: InputDecoration(
//                           hintText:
//                               'Write instruction for step ${index + 1} here...',
//                           filled: true,
//                           fillColor: Color(0xFFFFFDF9),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(20),
//                             borderSide: BorderSide(color: Color(0xFFDDDDDD)),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(20),
//                             borderSide: BorderSide(
//                                 color: Color.fromARGB(255, 236, 194, 194)),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(20),
//                             borderSide:
//                                 BorderSide(color: Color(0xFFFD5D69), width: 2),
//                           ),
//                           hintStyle: TextStyle(color: Color(0xFF999999)),
//                         ),
//                         style: TextStyle(color: Color(0xFF333333)),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: const Icon(Icons.remove_circle,
//                           color: Color(0xFFFD5D69), size: 24), // ✅ Fixed size
//                       onPressed: () => _removeInstruction(index),
//                     ),
//                   ],
//                 ),
//               );
//             }),

//             const SizedBox(height: 12),

//             ElevatedButton(
//               onPressed: _addInstruction,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFFD5D69), // Pink button
//                 shape: RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(20)), // Same as ingredient button
//                 padding: EdgeInsets.symmetric(
//                     horizontal: 20, vertical: 14), // Same as ingredient button
//               ),
//               child: const Text(
//                 "+ Add Instruction",
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),

//             const SizedBox(height: 20),

//             const SizedBox(height: 30),

//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed:
//                         _showCancelConfirmation, // ✅ Show confirmation before cancel
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[200],
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                     ),
//                     child: const Text("Cancel",
//                         style: TextStyle(color: Colors.black)),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed:
//                         _validateBeforePublish, // ✅ Validate first, then confirm publish
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFFD5D69),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                     ),
//                     child: const Text("Publish",
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: isKeyboardVisible
//           ? null
//           : CustomBottomNavBar(
//               currentIndex: _currentIndex,
//               onTap: _onItemTapped,
//             ),
//     );
//   }
// }

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:sizzle_share/pages/HomePage.dart';
import 'package:sizzle_share/pages/ProfilePage.dart';
import 'package:sizzle_share/pages/ShoppingListPage.dart';
import 'package:sizzle_share/pages/meal_prep_screen.dart';
import 'package:sizzle_share/services/api_service.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sizzle_share/widgets/custom_bottom_navbar.dart';

class CreateRecipePage extends StatefulWidget {
  const CreateRecipePage({super.key});

  @override
  State<CreateRecipePage> createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _customCuisineController = TextEditingController();
  int _currentIndex = 2;
  String _capitalizeTitle(String title) {
    if (title.isEmpty) return title;

    // Split into words, capitalize each word, and join them back
    return title.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  final List<TextEditingController> _instructionControllers = [
    TextEditingController()
  ];

  List<Map<String, String>> _ingredients = [
    {'quantity': '', 'name': ''},
  ];

  final List<String> _categoryOptions = [
    "Quick & Easy",
    "Breakfast",
    "Lunch",
    "Dinner",
    "Desserts",
    "Snacks",
    "Vegan",
    "Keto",
    "Low Carb",
    "Gluten-Free",
    "Diabeic-Friendly",
    "Heart-Healthy",
    "Weight-Loss"
  ];

  final List<String> _cuisineOptions = [
    'Egyptian',
    'Italian',
    'Asian',
    'American',
    'Indian',
    'Mexican',
    'Other'
  ];

  String? _selectedCategory;
  String? _selectedCuisine;
  List<String> _selectedCategories = [];

  Uint8List? _imageBytes;
  String? _imageFileName;
  XFile? _pickedFile;

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageFileName = null;
      _pickedFile = null;
    });
  }

  bool _hasUnsavedChanges() {
    // Check if any fields have content
    return _titleController.text.isNotEmpty ||
        _timeController.text.isNotEmpty ||
        _customCuisineController.text.isNotEmpty ||
        _instructionControllers.any((c) => c.text.isNotEmpty) ||
        _ingredients
            .any((i) => i['name']!.isNotEmpty || i['quantity']!.isNotEmpty) ||
        _imageBytes != null ||
        _selectedCategories.isNotEmpty ||
        _selectedCuisine != null;
  }

  void _showNavigationConfirmation(int targetIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Unsaved Changes"),
        content: const Text(
            "You have unsaved changes. Are you sure you want to leave this page?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 214, 210, 210),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              "Continue Editing",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToPage(targetIndex);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFD5D69),
            ),
            child: const Text(
              "Discard Changes",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    if (_hasUnsavedChanges()) {
      _showNavigationConfirmation(index);
    } else {
      _navigateToPage(index);
    }
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
        );
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MealPrepScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  void _validateBeforePublish() {
    final title = _titleController.text.trim();
    final timeText = _timeController.text.trim();
    final time = int.tryParse(timeText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final instructions = _instructionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    String? politeMessage;

    if (title.isEmpty) {
      politeMessage = "Kindly enter a recipe title before publishing.";
    } else if (time <= 0) {
      politeMessage = "Please provide a valid cooking time.";
    } else if (_selectedCategories.isEmpty) {
      politeMessage = "Please select at least one category.";
    } else if (_selectedCuisine == null) {
      politeMessage = "Please select a cuisine.";
    } else if (_selectedCuisine == 'Other' &&
        _customCuisineController.text.trim().isEmpty) {
      politeMessage = "Please enter your custom cuisine.";
    } else if (instructions.isEmpty) {
      politeMessage = "Please add at least one instruction step.";
    } else if (_ingredients
        .where((ing) => ing['name']!.isNotEmpty && ing['quantity']!.isNotEmpty)
        .toList()
        .isEmpty) {
      politeMessage = "Please add at least one ingredient.";
    }

    if (politeMessage != null) {
      _showDialog(politeMessage); // Friendly message
      return;
    }

    _showPublishConfirmation(); // All fields are valid, confirm publish
  }

  void _showPublishConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)), // ✅ Rounded corners
        title: const Text(
          "Confirm Publish",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: const Text(
          "Are you sure you want to publish this recipe?",
          style: TextStyle(color: Color(0xFF333333)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              "No",
              style: TextStyle(color: Colors.purple), // ✅ Same as Cancel popup
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _createRecipe(); // ✅ Proceed to create recipe
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFD5D69), // ✅ Pink button
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text(
              "Yes, Publish",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Cancel"),
        content: const Text(
            "Are you sure you want to cancel? All changes will be lost."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD5D69)),
            child: const Text("Yes, Cancel",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          setState(() {
            _imageBytes = file.bytes;
            _imageFileName = file.name;
            _pickedFile = null;
          });
        }
      } else {
        final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _pickedFile = pickedFile;
            _imageBytes = bytes;
            _imageFileName = pickedFile.name;
          });
        }
      }
    } catch (e) {
      _showDialog("Error picking image. Please try again.");
    }
  }

  void _addIngredient() {
    setState(() => _ingredients.add({'quantity': '', 'name': ''}));
  }

  void _removeIngredient(int index) {
    if (_ingredients.length > 1) {
      setState(() => _ingredients.removeAt(index));
    }
  }

  void _addInstruction() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  Future<void> _createRecipe() async {
    // final title = _titleController.text.trim();
    final title = _capitalizeTitle(
        _titleController.text.trim()); // Capitalize the title here

    final timeText = _timeController.text.trim();
    final time = int.tryParse(timeText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final instructions = _instructionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (title.isEmpty) {
      _showDialog("Please enter a recipe title.");
      return;
    }

    if (time <= 0) {
      _showDialog("Please enter a valid time in minutes.");
      return;
    }

    if (_selectedCategories.isEmpty) {
      // ✅ Multi-selection check
      _showDialog("Please select at least one category.");
      return;
    }

    if (_selectedCuisine == null) {
      _showDialog("Please select a cuisine.");
      return;
    }

    String cuisine = _selectedCuisine!;
    if (cuisine == 'Other') {
      cuisine = _customCuisineController.text.trim();
      if (cuisine.isEmpty) {
        _showDialog("Please enter the custom cuisine.");
        return;
      }
    }

    if (instructions.isEmpty) {
      _showDialog("Please add at least one instruction.");
      return;
    }

    final validIngredients = _ingredients
        .where((ing) => ing['name']!.isNotEmpty && ing['quantity']!.isNotEmpty)
        .toList();

    if (validIngredients.isEmpty) {
      _showDialog("Please add at least one ingredient.");
      return;
    }

    try {
      final apiService = ApiService();
      await apiService.init();

      await apiService.createRecipe(
        title: title,
        description: instructions,
        totalTime: time.toString(),
        cuisine: cuisine,
        ingredients: validIngredients,
        category: _selectedCategories, // ✅ Correct multi-selection list
        imageBytes: _imageBytes,
        imageFileName: _imageFileName,
      );

      if (mounted) {
        _showDialog("Recipe created successfully!", isSuccess: true);
      }
    } catch (e) {
      _showDialog("Failed to create recipe: ${e.toString()}");
    }
  }

  void _showDialog(String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: isSuccess
            ? Text(
                "Success",
                style: TextStyle(
                  color: Color(0xFFFD5D69),
                  fontWeight: FontWeight.bold,
                ),
              )
            : null, // ✅ No title for polite validation messages
        content: Text(
          message,
          style: TextStyle(color: Color(0xFF333333)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              //   Navigator.of(ctx).pop();
              //   if (isSuccess) {
              //     Navigator.of(context).pop();
              //   }
              // },
              Navigator.of(ctx).pop();
              if (isSuccess) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              }
            },
            child: Text(
              "OK",
              style: TextStyle(color: Color(0xFFFD5D69)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _customCuisineController.dispose();
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showBackButtonConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Unsaved Changes"),
        content: const Text(
            "You have unsaved changes. Are you sure you want to leave this page?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 214, 210, 210),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              "Continue Editing",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFD5D69),
            ),
            child: const Text(
              "Discard Changes",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges()) {
          _showBackButtonConfirmation();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Create Recipe",
              style: TextStyle(
                color: Color(0xFFFD5D69),
                fontWeight: FontWeight.bold,
              )),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFFDF9), // Same color as background
            ),
          ),
          backgroundColor: Color(0xFFFFFDF9),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recipe Image",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFFFD5D69),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _imageBytes == null
                            ? Color.fromARGB(255, 236, 194, 194)
                            : Color(0xFFFD5D69),
                        width: 2,
                      ),
                    ),
                    child: _imageBytes == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt,
                                    color: Color(0xFFBBBBBB), size: 40),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFD5D69),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                  child: Text(
                                    "Add Recipe Image",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  _imageBytes!,
                                  width: double.infinity,
                                  fit: BoxFit
                                      .scaleDown, // Changed from BoxFit.cover
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: _pickImage,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.white.withOpacity(0.9),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                      ),
                                      child: Text(
                                        "Change Image",
                                        style:
                                            TextStyle(color: Color(0xFFFD5D69)),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: _removeImage,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.white.withOpacity(0.9),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                      ),
                                      child: Text(
                                        "Remove",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Recipe title",
                  filled: true,
                  fillColor:
                      Color(0xFFFFFDF9), // Soft off-white / cream background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Color(0xFFDDDDDD)), // Light grey border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 236, 194, 194)), // Same grey when inactive
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Color(0xFFFD5D69),
                        width: 2), // Pink border when focused
                  ),
                  hintStyle: TextStyle(
                      color: Color(0xFF999999)), // Soft grey hint text
                ),
                style:
                    TextStyle(color: Color(0xFF333333)), // Dark grey input text
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Time (e.g. 30 minutes)",
                  filled: true,
                  fillColor:
                      Color(0xFFFFFDF9), // Soft off-white / cream background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Color(0xFFDDDDDD)), // Light grey border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 236, 194,
                            194)), // Soft pinkish-grey border when inactive
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Color(0xFFFD5D69),
                        width: 2), // Pink border when focused
                  ),
                  hintStyle: TextStyle(
                      color: Color(0xFF999999)), // Medium grey hint text
                ),
                style:
                    TextStyle(color: Color(0xFF333333)), // Dark grey input text
              ),

              const SizedBox(height: 20),

              MultiSelectDialogField(
                items: _categoryOptions
                    .map((e) => MultiSelectItem<String>(e, e))
                    .toList(),
                title: Text("Select Categories"),
                selectedColor: Color(0xFFFD5D69), // Pink selection color
                decoration: BoxDecoration(
                  color: Color(0xFFFFFDF9), // Soft off-white background
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color:
                        Color.fromARGB(255, 236, 194, 194), // Light grey border
                    width: 1,
                  ),
                ),
                buttonIcon: Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFFFD5D69), // Pink dropdown arrow
                ),
                buttonText: Text(
                  "Select one or more categories",
                  style: TextStyle(
                    color: Color(0xFF999999), // Hint text color
                    fontSize: 16,
                  ),
                ),
                onConfirm: (results) {
                  setState(() {
                    _selectedCategories = results.cast<String>();
                  });
                },
                chipDisplay: MultiSelectChipDisplay(
                  chipColor: Color(0xFFFFFDF9), // Soft background for chips
                  textStyle:
                      TextStyle(color: Color(0xFF333333)), // Dark grey text
                  onTap: (value) {
                    setState(() {
                      _selectedCategories.remove(value);
                    });
                  },
                ),
              ),
              // customMultiSelect(context),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCuisine,
                    items: _cuisineOptions.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: TextStyle(
                            color: Color(0xFF333333), // Dark grey option text
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCuisine = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Select Cuisine",
                      hintStyle: TextStyle(
                          color: Color(0xFF999999)), // Medium grey hint text

                      filled: true,
                      fillColor: Color(0xFFFFFDF9), // Soft off-white background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Color(0xFFDDDDDD)), // Light grey border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 236, 194,
                                194)), // Soft pinkish-grey when inactive
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Color(0xFFFD5D69),
                            width: 2), // Pink border when focused
                      ),
                    ),
                    dropdownColor:
                        Color(0xFFF6F0F6), // Light lavender background
                    style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16), // Selected item text style
                    iconEnabledColor: Color(0xFFFD5D69), // Pink dropdown arrow
                  ),
                  if (_selectedCuisine == 'Other') ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customCuisineController,
                      decoration: InputDecoration(
                        hintText: "Enter custom cuisine",
                        hintStyle: TextStyle(
                            color: Color(0xFF999999)), // Medium grey hint text

                        filled: true,
                        fillColor:
                            Color(0xFFFFFDF9), // Soft off-white background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Color(0xFFDDDDDD)), // Light grey border
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 236, 194,
                                  194)), // Soft pinkish-grey when inactive
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Color(0xFFFD5D69),
                              width: 2), // Pink border when focused
                        ),
                      ),
                      style: TextStyle(
                          color: Color(0xFF333333)), // Input text color
                    ),
                  ]
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Ingredients",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFFD5D69)),
              ),
              const SizedBox(height: 8),

              ..._ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Amt',
                            filled: true,
                            fillColor: Color(0xFFFFFDF9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 236, 194, 194)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Color(0xFFFD5D69), width: 2),
                            ),
                            hintStyle: TextStyle(color: Color(0xFF999999)),
                          ),
                          style: TextStyle(color: Color(0xFF333333)),
                          onChanged: (value) => item['quantity'] = value,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Ingredient...',
                            filled: true,
                            fillColor: Color(0xFFFFFDF9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 236, 194, 194)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Color(0xFFFD5D69), width: 2),
                            ),
                            hintStyle: TextStyle(color: Color(0xFF999999)),
                          ),
                          style: TextStyle(color: Color(0xFF333333)),
                          onChanged: (value) => item['name'] = value,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Color(0xFFFD5D69), size: 24), // ✅ Fixed size
                        onPressed: () => _removeIngredient(index),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _addIngredient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD5D69), // Pink button
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20)), // Match instruction button
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14), // Match instruction button
                ),
                child: const Text(
                  "+ Add Ingredient",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              const SizedBox(height: 20),

              const Text(
                "Instructions",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFFD5D69)),
              ),
              const SizedBox(height: 8),

              ..._instructionControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Step number display
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(0xFFFD5D69),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText:
                                'Write instruction for step ${index + 1} here...',
                            filled: true,
                            fillColor: Color(0xFFFFFDF9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 236, 194, 194)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                  color: Color(0xFFFD5D69), width: 2),
                            ),
                            hintStyle: TextStyle(color: Color(0xFF999999)),
                          ),
                          style: TextStyle(color: Color(0xFF333333)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Color(0xFFFD5D69), size: 24), // ✅ Fixed size
                        onPressed: () => _removeInstruction(index),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _addInstruction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD5D69), // Pink button
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20)), // Same as ingredient button
                  padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14), // Same as ingredient button
                ),
                child: const Text(
                  "+ Add Instruction",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _showCancelConfirmation, // ✅ Show confirmation before cancel
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _validateBeforePublish, // ✅ Validate first, then confirm publish
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFD5D69),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text("Publish",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: isKeyboardVisible
            ? null
            : CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
              ),
      ),
    );
  }
}
