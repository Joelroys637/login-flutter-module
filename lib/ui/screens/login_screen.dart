import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username or password')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_person_outlined, size: 80, color: AppColors.primaryColor)
                        .animate()
                        .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack)
                        .fadeIn(),
                    const SizedBox(height: 20),
                    const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: _usernameController,
                      hintText: 'Username',
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty ? 'Enter username' : null,
                    ).animate().fade(delay: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: !_isPasswordVisible,
                      validator: (value) => value == null || value.isEmpty ? 'Enter password' : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black45,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ).animate().fade(delay: 500.ms).slideX(begin: -0.1),
                    const SizedBox(height: 30),
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return CustomButton(
                          text: 'LOGIN',
                          isLoading: auth.isLoading,
                          onPressed: _login,
                        );
                      },
                    ).animate().fade(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
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
