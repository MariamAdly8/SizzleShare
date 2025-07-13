import 'package:flutter/material.dart';
import 'package:sizzle_share/models/user.dart';
import 'package:sizzle_share/services/api_service.dart';
import 'package:sizzle_share/widgets/CustomTextField.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late List<String> _selectedPreferences;
  late List<String> _selectedAllergies;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _selectedAvatar;
  User? _user;

  final List<String> _avatarOptions = [
    'avatar1.jpg',
    'avatar2.jpg',
    'avatar3.jpg',
    'avatar4.jpg',
    'avatar5.jpg',
    'avatar6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _selectedPreferences = [];
    _selectedAllergies = [];
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final apiService = ApiService();
      await apiService.init();

      final user = await apiService.getCurrentUser();

      setState(() {
        _user = user;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _selectedPreferences = List.from(user.preferenceOptions);
        _selectedAllergies = List.from(user.allergyOptions);
        _selectedAvatar = user.userAvatar;
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      await apiService.init();

      final updates = {
        'name': _nameController.text,
        'userAvatar': _selectedAvatar,
        'preferenceOptions': _selectedPreferences,
        'allergyOptions': _selectedAllergies,
      };

      final updatedUser = await apiService.updateUser(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFD5D69),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFD5D69)),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title:
              const Text('Edit Profile', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: const Color(0xFFFD5D69),
          elevation: 0,
        ),
        body: const Center(
          child: Text('Failed to load user data',
              style: TextStyle(color: Colors.black)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Edit Profile',
            style: TextStyle(color: Color(0xFFFD5D69))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFD5D69)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFFFFFDF9),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _saveProfile,
        backgroundColor: const Color(0xFFFD5D69),
        label: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar Section with corrected image paths
            _buildSection(
              'Choose Your Avatar',
              Column(
                children: [
                  if (_selectedAvatar != null && _selectedAvatar!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          const Text(
                            'Current Selection:',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                AssetImage('assets/images/$_selectedAvatar'),
                            backgroundColor: Colors.grey.shade300,
                            child: _selectedAvatar == null ||
                                    _selectedAvatar!.isEmpty
                                ? const Icon(Icons.person,
                                    size: 40, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _avatarOptions.length,
                      itemBuilder: (context, index) {
                        final avatar = _avatarOptions[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedAvatar = avatar),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      AssetImage('assets/images/$avatar'),
                                  backgroundColor: Colors.grey.shade300,
                                  child: avatar.isEmpty
                                      ? const Icon(Icons.person,
                                          size: 30, color: Colors.white)
                                      : null,
                                ),
                                if (_selectedAvatar == avatar)
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    child: const Icon(Icons.check,
                                        color: Colors.white),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Rest of your existing sections...
            _buildSection(
              'Personal Information',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      'Name:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Enter your name',
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      'Email:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC6C9),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Text(
                      _emailController.text,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildSection(
              'Preferences',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Quick & Easy',
                  'Breakfast',
                  'Lunch',
                  'Dinner',
                  'Desserts',
                  'Snacks',
                  'Vegan',
                  'Keto',
                  'Low Carb',
                  'Gluten-Free',
                  'Diabetic-Friendly',
                  'Heart-Healthy',
                  'Weight-Loss',
                ].map((preference) {
                  final isSelected = _selectedPreferences.contains(preference);
                  return FilterChip(
                    label: Text(preference),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPreferences.add(preference);
                        } else {
                          _selectedPreferences.remove(preference);
                        }
                      });
                    },
                    selectedColor: const Color(0xFFFD5D69),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
            ),

            _buildSection(
              'Allergies',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'milk',
                  'banana',
                  'meat',
                  'kiwi',
                  'eggs',
                  'fish',
                  'Almonds',
                  'Peanuts',
                  'Shrimp',
                  'Shellfish',
                  'Tree Nuts',
                ].map((allergy) {
                  final isSelected = _selectedAllergies.contains(allergy);
                  return FilterChip(
                    label: Text(allergy),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAllergies.add(allergy);
                        } else {
                          _selectedAllergies.remove(allergy);
                        }
                      });
                    },
                    selectedColor: const Color(0xFFFD5D69),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
