import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final VoidCallback? onEditingComplete; // إضافة `onEditingComplete`
  final Function(String)? onChanged; // إضافة `onChanged` للتحقق أثناء الكتابة
  final TextInputType? keyboardType; // تحديد نوع الإدخال
  final String? Function(String?)? validator; // إضافة التحقق باستخدام validator

  const CustomTextField({
    super.key,
    this.hintText,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.onEditingComplete, // استقباله كـ `callback`
    this.onChanged, // استقباله كـ `callback`
    this.keyboardType, // إضافة نوع الإدخال
    this.validator, // إضافة validator
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onEditingComplete: onEditingComplete, // تمريره عند الحاجة
      onChanged: onChanged, // تمريره للتحقق أثناء الكتابة
      keyboardType: keyboardType, // إضافة نوع الإدخال
      validator: validator, // التحقق باستخدام validator
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
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
