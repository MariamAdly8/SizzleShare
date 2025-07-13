import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:sizzle_share/services/api_service.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sizzle_share/models/recipe.dart';

class EditRecipePage extends StatefulWidget {
  final Recipe recipe;

  const EditRecipePage({super.key, required this.recipe});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _customCuisineController = TextEditingController();
  // bool _imageRemoved = false; // Add this line

  final List<TextEditingController> _instructionControllers = [];
  List<Map<String, String>> _ingredients = [];

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

  String? _selectedCuisine;
  List<String> _selectedCategories = [];

  Uint8List? _imageBytes;
  String? _imageFileName;
  XFile? _pickedFile;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    // Initialize fields with recipe data
    // _imageRemoved = false; // Initialize the flag

    _titleController.text = widget.recipe.recipeName;
    _timeController.text = widget.recipe.totalTime.toString();
    _selectedCategories = List.from(widget.recipe.category);

    // Handle cuisine
    if (_cuisineOptions.contains(widget.recipe.cuisine)) {
      _selectedCuisine = widget.recipe.cuisine;
    } else {
      _selectedCuisine = 'Other';
      _customCuisineController.text = widget.recipe.cuisine ?? '';
    }

    // Initialize instructions
    for (var instruction in widget.recipe.description) {
      _instructionControllers.add(TextEditingController(text: instruction));
    }

    // Initialize ingredients
    _ingredients = widget.recipe.ingredients
        .map((ing) => {'quantity': ing.quantity, 'name': ing.name})
        .toList();
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null; // Clear the image bytes
      _imageFileName = null; // Clear the filename
      _pickedFile = null; // Clear the picked file
      _imageChanged = true; // Mark that image was changed
      widget.recipe.imageURL = null; // Clear the existing image URL
    });
  }

  void _validateBeforeUpdate() {
    final title = _titleController.text.trim();
    final timeText = _timeController.text.trim();
    final time = int.tryParse(timeText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final instructions = _instructionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    String? politeMessage;

    if (title.isEmpty) {
      politeMessage = "Kindly enter a recipe title before updating.";
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
      _showDialog(politeMessage);
      return;
    }

    _showUpdateConfirmation();
  }

  void _showUpdateConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Confirm Update",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: const Text(
          "Are you sure you want to update this recipe?",
          style: TextStyle(color: Color(0xFF333333)),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor:
                  const Color.fromARGB(255, 214, 210, 210), // Text color
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              "No",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _updateRecipe();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFD5D69),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text(
              "Yes, Update",
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
            style: TextButton.styleFrom(
              backgroundColor:
                  const Color.fromARGB(255, 214, 210, 210), // Text color
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("No",
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))
                // style: TextStyle(color: Colors.grey),

                ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(false); // Return false for cancel
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
            _imageChanged = true;
            //  _imageRemoved = false; // Reset removal flag when picking new image
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
            _imageChanged = true;
            //  _imageRemoved = false; // Reset removal flag
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

  Future<void> _updateRecipe() async {
    final title = _titleController.text.trim();
    final timeText = _timeController.text.trim();
    final time = int.tryParse(timeText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final instructions = _instructionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    String cuisine = _selectedCuisine!;
    if (cuisine == 'Other') {
      cuisine = _customCuisineController.text.trim();
    }

    final validIngredients = _ingredients
        .where((ing) => ing['name']!.isNotEmpty && ing['quantity']!.isNotEmpty)
        .toList();

    try {
      final apiService = ApiService();
      await apiService.init();

      await apiService.updateRecipe(
        recipeId: widget.recipe.id,
        title: title,
        description: instructions,
        totalTime: time.toString(),
        cuisine: cuisine,
        ingredients: validIngredients,
        category: _selectedCategories,
        imageBytes: _imageChanged ? _imageBytes : null,
        imageFileName: _imageChanged ? _imageFileName : null,
        removeImage: _imageChanged && _imageBytes == null, // Send removal flag
      );

      if (mounted) {
        _showDialog("Recipe updated successfully!", isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        _showDialog("Failed to update recipe: ${e.toString()}");
      }
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
            : null,
        content: Text(
          message,
          style: TextStyle(color: Color(0xFF333333)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (isSuccess) {
                Navigator.of(context)
                    .pop(null); // Return null for successful update
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

// In EditRecipePage.dart, add this method to _EditRecipePageState
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Delete Recipe",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: const Text(
          "Are you sure you want to permanently delete this recipe?",
          style: TextStyle(color: Color(0xFF333333)),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor:
                  const Color.fromARGB(255, 214, 210, 210), // Text color
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel",
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))
                // style: TextStyle(color: Colors.grey),

                ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteRecipe();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFD5D69),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

// In EditRecipePage.dart, update the _deleteRecipe method:
  Future<void> _deleteRecipe() async {
    try {
      final apiService = ApiService();
      await apiService.init();
      await apiService.deleteRecipe(widget.recipe.id);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true for deletion
      }
    } catch (e) {
      if (mounted) {
        _showDialog("Failed to delete recipe: ${e.toString()}");
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Edit Recipe",
            style: TextStyle(color: Color(0xFFFD5D69))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFD5D69)),
          onPressed: () {
            // Show cancel confirmation when back button is pressed
            _showCancelConfirmation();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFFD5D69)),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Delete Recipe',
          ),
        ],
        centerTitle: true,
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
                      color: (_imageBytes == null &&
                              widget.recipe.imageURL == null)
                          ? Color.fromARGB(255, 236, 194, 194)
                          : Color(0xFFFD5D69),
                      width: 2,
                    ),
                  ),
                  child: (_imageBytes == null && widget.recipe.imageURL == null)
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
                                      borderRadius: BorderRadius.circular(20)),
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
                            _imageBytes != null
                                ? Image.memory(
                                    _imageBytes!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.scaleDown,
                                  )
                                : (widget.recipe.imageURL != null
                                    ? Image.network(
                                        widget.recipe.imageURL!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.scaleDown,
                                      )
                                    : Container()),
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
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
                fillColor: Color(0xFFFFFDF9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 236, 194, 194)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFFD5D69), width: 2),
                ),
                hintStyle: TextStyle(color: Color(0xFF999999)),
              ),
              style: TextStyle(color: Color(0xFF333333)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Time (e.g. 30 minutes)",
                filled: true,
                fillColor: Color(0xFFFFFDF9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 236, 194, 194)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFFD5D69), width: 2),
                ),
                hintStyle: TextStyle(color: Color(0xFF999999)),
              ),
              style: TextStyle(color: Color(0xFF333333)),
            ),
            const SizedBox(height: 20),
            MultiSelectDialogField(
              items: _categoryOptions
                  .map((e) => MultiSelectItem<String>(e, e))
                  .toList(),
              initialValue: _selectedCategories,
              title: Text("Select Categories"),
              selectedColor: Color(0xFFFD5D69),
              decoration: BoxDecoration(
                color: Color(0xFFFFFDF9),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                  color: Color.fromARGB(255, 236, 194, 194),
                  width: 1,
                ),
              ),
              buttonIcon: Icon(
                Icons.arrow_drop_down,
                color: Color(0xFFFD5D69),
              ),
              buttonText: Text(
                "Select one or more categories",
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                ),
              ),
              onConfirm: (results) {
                setState(() {
                  _selectedCategories = results.cast<String>();
                });
              },
              chipDisplay: MultiSelectChipDisplay(
                chipColor: Color(0xFFFFFDF9),
                textStyle: TextStyle(color: Color(0xFF333333)),
                onTap: (value) {
                  setState(() {
                    _selectedCategories.remove(value);
                  });
                },
              ),
            ),
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
                          color: Color(0xFF333333),
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
                    hintStyle: TextStyle(color: Color(0xFF999999)),
                    filled: true,
                    fillColor: Color(0xFFFFFDF9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 236, 194, 194)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color(0xFFFD5D69), width: 2),
                    ),
                  ),
                  dropdownColor: Color(0xFFF6F0F6),
                  style: TextStyle(color: Color(0xFF333333), fontSize: 16),
                  iconEnabledColor: Color(0xFFFD5D69),
                ),
                if (_selectedCuisine == 'Other') ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _customCuisineController,
                    decoration: InputDecoration(
                      hintText: "Enter custom cuisine",
                      hintStyle: TextStyle(color: Color(0xFF999999)),
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
                        borderSide:
                            BorderSide(color: Color(0xFFFD5D69), width: 2),
                      ),
                    ),
                    style: TextStyle(color: Color(0xFF333333)),
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
                            borderSide:
                                BorderSide(color: Color(0xFFFD5D69), width: 2),
                          ),
                          hintStyle: TextStyle(color: Color(0xFF999999)),
                        ),
                        style: TextStyle(color: Color(0xFF333333)),
                        controller:
                            TextEditingController(text: item['quantity']),
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
                            borderSide:
                                BorderSide(color: Color(0xFFFD5D69), width: 2),
                          ),
                          hintStyle: TextStyle(color: Color(0xFF999999)),
                        ),
                        style: TextStyle(color: Color(0xFF333333)),
                        controller: TextEditingController(text: item['name']),
                        onChanged: (value) => item['name'] = value,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle,
                          color: Color(0xFFFD5D69), size: 24),
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
                backgroundColor: const Color(0xFFFD5D69),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: const Text(
                "+ Add Ingredient",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
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
                            borderSide:
                                BorderSide(color: Color(0xFFFD5D69), width: 2),
                          ),
                          hintStyle: TextStyle(color: Color(0xFF999999)),
                        ),
                        style: TextStyle(color: Color(0xFF333333)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.remove_circle,
                          color: Color(0xFFFD5D69), size: 24),
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
                backgroundColor: const Color(0xFFFD5D69),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: const Text(
                "+ Add Instruction",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showCancelConfirmation,
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
                    onPressed: _validateBeforeUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFD5D69),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("Update",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
