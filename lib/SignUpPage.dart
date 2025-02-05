import 'package:flutter/material.dart';
import 'package:sizzle_share/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  _SignuppageState createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Error messages for each field
  String? _nameError;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // default user type is 'user'
  final String _userType = 'user';

  // sign up function
  Future<void> _signUp() async {
    // clear previous error messages
    setState(() {
      _nameError = null;
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // validate fields
    bool isValid = true;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = "Passwords do not match. Please check!";
      });
      isValid = false;
    }

    // Password validation
    if (_passwordController.text.length < 8) {
      setState(() {
        _passwordError = "Password must be at least 8 characters.";
      });
      isValid = false;
    }

    // check if username already exists in Firestore
    String username = _usernameController.text.trim();
    bool usernameExists = await _checkUsernameExists(username);
    if (usernameExists) {
      setState(() {
        _usernameError = "Username already exists. Please choose another one.";
      });
      isValid = false;
    }

    // Email validation
    String email = _emailController.text.trim();
    if (!EmailValidator.validate(email)) {
      setState(() {
        _emailError = "Please enter a valid email (e.g., user@example.com).";
      });
      isValid = false;
    }

    if (!isValid) return;

    try {
      // create a user using Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      // create a user document in Firestore with user_id and user_type
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
          // get the next user ID
      await userRef.set({
        'name': _nameController.text.trim(),
        'username': username,
        'email': email,
        'user_type': _userType,
      });

      Navigator.pop(context); // go back to login page after successful signup
    } catch (e) {
      setState(() {
        _emailError = 'Error: $e';
      });
    }
  }

  // function to check if the username already exists in Firestore
  Future<bool> _checkUsernameExists(String username) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final snapshot =
        await usersCollection.where('username', isEqualTo: username).get();
    return snapshot.docs.isNotEmpty;
  }


  // Username Validation
  void _validateUsername() async {
    setState(() {
      if (_usernameController.text.isEmpty) {
        _usernameError = 'Username cannot be empty';
      } else if (_usernameController.text.length < 5) {
        _usernameError = 'Username must be at least 5 characters';
      } else {
        _usernameError = null;
      }
    });

    // Check if the username is unique while typing
    String username = _usernameController.text.trim();
    if (username.isNotEmpty) 
    {
      bool usernameExists = await _checkUsernameExists(username);
        if (usernameExists)
            {
              setState(()
                {
                      _usernameError = 'Username is already taken';
               });
      
            } 
      else
            {
              setState(()
               {
                       _usernameError = null; // clear error if unique
                });
            }
    }
  }

  // Email Validation
  void _validateEmail() {
    setState(() {
      if (!EmailValidator.validate(_emailController.text)) {
        _emailError = "Please enter a valid email (e.g., user@example.com).";
      } else {
        _emailError = null;
      }
    });
  }

  // Password Validation
  void _validatePassword() {
    setState(() {
      if (_passwordController.text.length < 8) {
        _passwordError = "Password must be at least 8 characters.";
      } else {
        _passwordError = null;
      }
    });
  }

  // Confirm Password Validation
  void _validateConfirmPassword() {
    setState(() {
      if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordError = "Passwords do not match.";
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color(0xFFFD5D69),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 40.0),
                Text(
                  'Name',
                  style: TextStyle(
                    color: Color.fromARGB(255, 22, 22, 22),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.0),
                CustomTextField(
                  hintText: "Enter your name",
                  controller: _nameController,
                ),
                SizedBox(height: 10.0),
                Text(
                  'Username',
                  style: TextStyle(
                    color: Color.fromARGB(255, 22, 22, 22),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.0),
                CustomTextField(
                  hintText: 'Enter your username',
                  controller: _usernameController,
                  onChanged: (value) {
                    _validateUsername();
                  },
                ),
                if (_usernameError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      _usernameError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                SizedBox(height: 10.0),
                Text(
                  'Email',
                  style: TextStyle(
                    color: Color.fromARGB(255, 22, 22, 22),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.0),
                CustomTextField(
                  hintText: 'Enter your Email',
                  controller: _emailController,
                  onChanged: (value) {
                    _validateEmail();
                  },
                ),
                if (_emailError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      _emailError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                SizedBox(height: 10.0),
                Text(
                  'Password',
                  style: TextStyle(
                    color: Color.fromARGB(255, 22, 22, 22),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.0),
                CustomTextField(
                  obscureText: true,
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  onChanged: (value) {
                    _validatePassword();
                  },
                ),
                if (_passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      _passwordError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                SizedBox(height: 10.0),
                Text(
                  'Confirm Password',
                  style: TextStyle(
                    color: Color.fromARGB(255, 22, 22, 22),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.0),
                CustomTextField(
                  obscureText: true,
                  hintText: 'Confirm your password',
                  controller: _confirmPasswordController,
                  onChanged: (value) {
                    _validateConfirmPassword();
                  },
                ),
                if (_confirmPasswordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      _confirmPasswordError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 40.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFD5D69),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 20,
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 254, 254),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Log In",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
