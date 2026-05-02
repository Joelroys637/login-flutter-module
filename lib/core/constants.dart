import 'package:flutter/material.dart';

class AppColors {
  // Deep luxurious space aesthetic
  static const Color primaryColor = Color(0xFF8A2BE2); // Vivid Purple
  static const Color accentColor = Color(0xFF00E5FF);  // Cyan Neon
  static const Color secondaryColor = Color(0xFF2A2D43);
  static const Color backgroundColor = Color(0xFF0F0F16); // True deep black/blue
  static const Color errorColor = Color(0xFFFF4C4C);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8A2BE2), Color(0xFFB066FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0B0B11), Color(0xFF1E1B32)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassBorderGradient = LinearGradient(
    colors: [
      Color(0x80FFFFFF),
      Color(0x10FFFFFF),
      Color(0x808A2BE2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
