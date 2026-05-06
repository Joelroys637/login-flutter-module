import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        prefixIcon: Icon(prefixIcon, color: Colors.black45),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }
}
