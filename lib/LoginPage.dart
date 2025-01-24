import 'package:flutter/material.dart';
import 'package:sizzle_share/HomePage.dart';
import 'package:sizzle_share/SignUpPage.dart';
import 'package:sizzle_share/widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
              Text(
                'Email',
                style: TextStyle(
                  color: Color.fromARGB(255, 22, 22, 22),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 9.0),
              CustomTextField(
                hintText: 'Enter your Email',
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
              SizedBox(height: 10.0),
              CustomTextField(
                obscureText: true,
                hintText: 'Enter your password',
                suffixIcon: const Icon(Icons.visibility_off),
              ),
              const SizedBox(height: 60.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
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
