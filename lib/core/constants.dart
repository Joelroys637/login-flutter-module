import 'package:flutter/material.dart';

class AppColors {
  // Premium Luxurious White Aesthetic
  static const Color primaryColor = Color(0xFF6C63FF); // Modern Indigo
  static const Color accentColor = Color(0xFF00BFA6);  // Teal Accent
  static const Color secondaryColor = Color(0xFFF0F2F5); // Soft Light Gray
  static const Color backgroundColor = Color(0xFFF8F9FD); // Premium White
  static const Color errorColor = Color(0xFFFF5252);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8E87FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9FD), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassBorderGradient = LinearGradient(
    colors: [
      Color(0xFFE0E0E0),
      Color(0xFFF5F5F5),
      Color(0xFFE0E0E0),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
