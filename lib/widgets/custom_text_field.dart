import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;

  CustomTextField({
    this.hintText,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
  }) ;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType, 
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Color(0xFF1C0F0D),
        ),
        filled: true,
        fillColor: Color(0xFFFFC6C9),
        suffixIcon: suffixIcon,
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
    );
  }
}
