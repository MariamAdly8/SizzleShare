import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomePage.dart';
import 'SignUpPage.dart';
import 'widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorMessage('Please enter both email and password.');
      return;
    }

    try {
      // تسجيل الدخول مباشرة
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // نجاح تسجيل الدخول → الانتقال للصفحة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showErrorMessage('No account found with this email.');
      } else if (e.code == 'wrong-password') {
        _showErrorMessage('Incorrect password. Please try again.');
      } else if (e.code == 'invalid-credential') {
        _showErrorMessage('No account found or incorrect password.');
      } else {
        _showErrorMessage('Error: ${e.message}');
      }
    } catch (e) {
      _showErrorMessage('An unexpected error occurred. Please try again.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Color(0xFFFD5D69),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 90.0),
              Text('Email',
                  style: TextStyle(
                    color: Color.fromARGB(255, 22, 22, 22),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
              SizedBox(height: 9.0),
              CustomTextField(
                controller: _emailController,
                hintText: 'Enter your Email',
              ),
              SizedBox(height: 10.0),
              Text('Password',
                  style: TextStyle(
                    color: Color.fromARGB(255, 22, 22, 22),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
              SizedBox(height: 10.0),
              CustomTextField(
                controller: _passwordController,
                obscureText: true,
                hintText: 'Enter your password',
                suffixIcon: const Icon(Icons.visibility_off),
              ),
              const SizedBox(height: 60.0),
              Center(
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFC6C9),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 20),
                  ),
                  child: Text(
                    'Log In',
                    style: TextStyle(
                        color: Color(0xffEC888D), fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signuppage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFC6C9),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 20),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                        color: Color(0xffEC888D), fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
