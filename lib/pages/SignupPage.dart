// daa daaa7 bs scrollable
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:sizzle_share/pages/LoginPage.dart';
import 'package:sizzle_share/pages/OtpVerificationPage.dart';
import 'package:sizzle_share/services/api_service.dart';
import 'package:sizzle_share/widgets/CustomTextField.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  int _currentSubStep = 0; // 0 for preferences, 1 for allergies
  String? _selectedAvatar;

  final List<String> _avatarOptions = [
    'avatar1.jpg',
    'avatar2.jpg',
    'avatar3.jpg',
    'avatar4.jpg',
    'avatar5.jpg',
    'avatar6.jpg',
  ];

  final List<String> allergyOptions = [
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
  ];

  final List<String> preferenceOptions = [
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
    'Diabeic-Friendly',
    'Heart-Healthy',
    'Weight-Loss',
  ];

  final List<String> _selectedAllergies = [];
  final List<String> _selectedPreferences = [];
  final PageController _recommendationPageController = PageController();

  @override
  void initState() {
    super.initState();
    _recommendationPageController.addListener(_updateSubStep);
  }

  void _updateSubStep() {
    setState(() {
      _currentSubStep = _recommendationPageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    _recommendationPageController.removeListener(_updateSubStep);
    _recommendationPageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildSurveyPage() {
    Widget buildGrid(List<String> items, List<String> selectedList) {
      return GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        children: items.map((item) {
          final selected = selectedList.contains(item);
          return GestureDetector(
            onTap: () => setState(() =>
                selected ? selectedList.remove(item) : selectedList.add(item)),
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFD5D69) : Colors.white,
                border: Border.all(color: const Color(0xFFFD5D69)),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                item,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFFFD5D69),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 50),
        Row(
          children: [
            const SizedBox(width: 48),
            Expanded(
              child: LinearProgressIndicator(
                value: _currentSubStep == 0 ? 0.5 : 1.0,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFD5D69)),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: PageView(
            controller: _recommendationPageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Preferences Page
              SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Select Your Preferences",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Choose your favorite cuisines for better recommendations",
                      textAlign: TextAlign.center,
                    ),
                    buildGrid(preferenceOptions, _selectedPreferences),
                  ],
                ),
              ),
              // Allergies Page
              SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Any Allergies?",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Select any allergies to avoid in recommendations",
                      textAlign: TextAlign.center,
                    ),
                    buildGrid(allergyOptions, _selectedAllergies),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Back button (only visible on allergies page)
              if (_currentSubStep == 1)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _recommendationPageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Color(0xFFFD5D69)),
                    ),
                  ),
                ),
              // Skip button (only visible on preferences page)
              if (_currentSubStep == 0)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Color(0xFFFD5D69)),
                    ),
                  ),
                ),
              // Continue/Done button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentSubStep == 0) {
                      // Move to Allergies page
                      _recommendationPageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Move to Signup Form
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFD5D69),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _currentSubStep == 0 ? "Continue" : "Done",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFFD5D69)),
                  onPressed: () {
                    // Go back to Survey page showing Allergies (sub-page 1)
                    _pageController
                        .animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                        .then((_) {
                      // After animation completes, show Allergies page
                      _recommendationPageController.jumpToPage(1);
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFD5D69),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Name Field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Name',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            CustomTextField(
              controller: _nameController,
              hintText: 'Enter your Name',
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Name is required' : null,
            ),

            // Email Field
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            CustomTextField(
              controller: _emailController,
              hintText: 'Enter your Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) return 'Email is required';
                if (!EmailValidator.validate(value!.trim()))
                  return 'Invalid email format';
                return null;
              },
            ),

            // Password Field
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Enter your Password',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true)
                  return 'Password is required';
                if (value!.length < 8) return 'Minimum 8 characters';
                if (!RegExp(r'[A-Z]').hasMatch(value))
                  return 'Include uppercase';
                if (!RegExp(r'[a-z]').hasMatch(value))
                  return 'Include lowercase';
                if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include number';
                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value))
                  return 'Include special character';
                return null;
              },
            ),

            // Confirm Password
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Confirm Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm your Password',
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (value) => value != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
            ),

            // Avatar Selection
            const SizedBox(height: 16),
            const Text('Choose an Avatar:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _avatarOptions.map((filename) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = filename),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/images/$filename'),
                        radius: 30,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      if (_selectedAvatar == filename)
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),

            // Sign Up Button
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD5D69),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _isLoading ? null : _submitSignup,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ),
            ),

            // Login Link
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              child: const Text(
                'Already have an account? Log In',
                style: TextStyle(color: Color(0xFFFD5D69)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // First validate the email format locally
      if (!EmailValidator.validate(_emailController.text.trim())) {
        throw Exception('Please enter a valid email address');
      }

      // Then call the API to initiate signup
      await ApiService().initiateSignup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        userAvatar: _selectedAvatar,
        allergyOptions: _selectedAllergies,
        preferenceOptions: _selectedPreferences,
      );

      // Only navigate to OTP page if everything succeeds
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationPage(
              email: _emailController.text.trim(),
              name: _nameController.text.trim(),
              password: _passwordController.text.trim(),
              userAvatar: _selectedAvatar,
              allergyOptions: _selectedAllergies,
              preferenceOptions: _selectedPreferences,
            ),
          ),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Signup failed. Please try again.';

      // Handle specific error cases from backend
      if (e.response?.data != null) {
        final responseMessage = e.response!.data['message']?.toString() ?? '';

        if (responseMessage.toLowerCase().contains('not valid') ||
            responseMessage.toLowerCase().contains('invalid email')) {
          errorMessage = 'Please use a valid email address';
        } else if (responseMessage
            .toLowerCase()
            .contains('already registered')) {
          errorMessage = 'This email is already registered. Please log in.';
        } else if (responseMessage
            .toLowerCase()
            .contains('already been sent')) {
          // Only proceed to OTP page if the email exists and OTP was already sent
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationPage(
                  email: _emailController.text.trim(),
                  name: _nameController.text.trim(),
                  password: _passwordController.text.trim(),
                  userAvatar: _selectedAvatar,
                  allergyOptions: _selectedAllergies,
                  preferenceOptions: _selectedPreferences,
                ),
              ),
            );
          }
          return;
        } else {
          errorMessage = responseMessage;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [_buildSurveyPage(), _buildSignupForm()],
        ),
      ),
    );
  }
}
