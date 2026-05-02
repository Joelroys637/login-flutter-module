import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../main.dart'; // To access AuthWrapper

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // After 3 seconds, navigate to AuthWrapper which handles state
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_person,
              size: 120,
              color: Colors.white,
            )
            .animate()
            .scale(duration: 800.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 600.ms)
            .shimmer(delay: 1000.ms, duration: 1500.ms, color: AppColors.accentColor.withOpacity(0.5)),
            
            const SizedBox(height: 20),
            
            const Text(
              'Secure App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: 0.5, curve: Curves.easeOut),
            
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: AppColors.accentColor)
            .animate()
            .fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
