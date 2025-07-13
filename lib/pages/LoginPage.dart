import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sizzle_share/pages/CreateRecipePage.dart';
import 'package:sizzle_share/pages/HomePage.dart';
import 'package:sizzle_share/pages/ProfilePage.dart';
import 'package:sizzle_share/pages/ShoppingListPage.dart';
import 'package:sizzle_share/pages/SignupPage.dart';
import 'package:sizzle_share/pages/meal_prep_screen.dart';
import 'package:sizzle_share/providers/recipe_status_provider/recipe_status_provider.dart';
import 'package:sizzle_share/services/api_service.dart';
import 'package:sizzle_share/widgets/CustomTextField.dart';
//

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_validateFields()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final recipeStatusProvider =
          Provider.of<RecipeStatusProvider>(context, listen: false);
      final (user, token) = await ApiService().loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      recipeStatusProvider.clearStatuses(); // clears any previous user data
      // Check if user is banned
      if (user.banned) {
        _showErrorMessage(
            'Your account has been banned. Please contact support.');
        return;
      }

      await _storage.write(key: 'jwt_token', value: token);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          // MaterialPageRoute(builder: (context) => HomePage()),
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      String errorMessage = 'Login failed';
      if (e.toString().contains('Incorrect password')) {
        errorMessage = 'The password you entered is incorrect';
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'No account found with this email address';
      } else if (e.toString().contains('banned')) {
        errorMessage = 'Your account has been banned. Please contact support.';
      } else {
        errorMessage = 'Login failed. Please try again later.';
      }
      _showErrorMessage(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateFields() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    var isValid = true;

    if (_emailController.text.isEmpty) {
      _emailError = 'Email cannot be empty';
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) {
      _emailError = 'Please enter a valid email address';
      isValid = false;
    } else {
      // Check for common email domains
      final validDomains = [
        'gmail.com',
        'yahoo.com',
        'outlook.com',
        'hotmail.com',
        'icloud.com'
      ];
      final domain = _emailController.text.split('@').last.toLowerCase();
      if (!validDomains.contains(domain)) {
        _emailError = 'Please use a valid email domain';
        isValid = false;
      }
    }

    if (_passwordController.text.isEmpty) {
      _passwordError = 'Password cannot be empty';
      isValid = false;
    }

    return isValid;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const _LoginHeader(),
              const SizedBox(height: 40),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 40),
              _buildLoginButton(),
              const SizedBox(height: 20),
              _buildSignupLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        CustomTextField(
          controller: _emailController,
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email cannot be empty';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                .hasMatch(value.trim())) {
              return 'Please enter a valid email address';
            }
            final domain = value.trim().split('@').last.toLowerCase();
            final validDomains = [
              'gmail.com',
              'yahoo.com',
              'outlook.com',
              'hotmail.com',
              'icloud.com'
            ];
            if (!validDomains.contains(domain)) {
              return 'Please use a valid email domain';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Enter your password',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password cannot be empty';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator(color: Color(0xFFFD5D69))
          : ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD5D69),
                minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Log In',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
    );
  }

  Widget _buildSignupLink() {
    return TextButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SignupPage()));
      },
      child: const Text(
        "Don't have an account? Sign Up",
        style: TextStyle(color: Color(0xFFFD5D69)),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Login',
        style: TextStyle(
          color: Color(0xFFFD5D69),
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
