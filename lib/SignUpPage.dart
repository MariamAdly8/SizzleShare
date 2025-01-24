import 'package:flutter/material.dart'; 
import 'package:sizzle_share/widgets/custom_text_field.dart';
import 'package:sizzle_share/LoginPage.dart'; 

class Signuppage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? selectedType; // لتحديد القيمة المختارة من القائمة المنسدلة

    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
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
                      hintText: 'Joe Doe',
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
                      hintText: 'JoeDoe55',
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
                      hintText: 'JoeDoe@example.com',
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Type',
                      style: TextStyle(
                        color: Color.fromARGB(255, 22, 22, 22),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      items: [
                        DropdownMenuItem(
                          value: "Male",
                          child: Text("Male"),
                        ),
                        DropdownMenuItem(
                          value: "Female",
                          child: Text("Female"),
                        ),
                      ],
                      onChanged: (value) {
                        selectedType = value; // تحديث القيمة المختارة
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFFFC6C9),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                          borderSide: BorderSide(
                            color: Color(0xFFFFC6C9),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                          borderSide: BorderSide(
                            color: Color(0xFFFD5D69),
                          ),
                        ),
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
                      hintText: '● ● ● ● ● ● ● ●',
                      suffixIcon: const Icon(Icons.visibility_off),
                    ),
                    const SizedBox(height: 10.0),
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
                      hintText: '● ● ● ● ● ● ● ●',
                      suffixIcon: const Icon(Icons.visibility_off),
                    ),
                    const SizedBox(height: 40.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return LoginPage();
                                },
                              ),
                            );
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
        ),
      ),
    );
  }
}
