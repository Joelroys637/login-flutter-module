import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // After 3 seconds, navigate based on login state
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 120,
              color: AppColors.primaryColor,
            )
            .animate()
            .scale(duration: 800.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 600.ms)
            .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.white.withOpacity(0.5)),
            
            const SizedBox(height: 20),
            
            const Text(
              'Admin Portal',
              style: TextStyle(
                color: Color(0xFF1A1C1E),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: 0.5, curve: Curves.easeOut),
            
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: AppColors.primaryColor)
            .animate()
            .fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
