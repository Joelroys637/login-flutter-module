import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      if (_emailController.text.trim() == 'joelroys637@gmail.com' &&
          _passwordController.text.trim() == '12345678') {
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GlassContainer(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 80, color: Colors.white)
                          .animate()
                          .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack)
                          .fadeIn(),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ).animate().fade(delay: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: !_isPasswordVisible,
                        validator: Validators.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ).animate().fade(delay: 500.ms).slideX(begin: -0.1),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: 'LOGIN',
                        isLoading: false,
                        onPressed: _login,
                      ).animate().fade(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                    ],
                  ),
                ),
              ).animate().fade(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
            ),
          ),
        ),
      ),
    );
  }
}
