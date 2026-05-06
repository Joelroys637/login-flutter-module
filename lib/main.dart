import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import 'core/constants.dart';
import 'providers/user_provider.dart';
import 'providers/role_provider.dart';
import 'providers/auth_provider.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Explicitly configure Firebase to store the session persistently in the Web Browser
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }
  } catch (e) {
    print("Firebase init error: $e");
    // Ignore error if Firebase is not setup yet so app can build
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Module',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: const Color(0xFF1A1C1E),
          displayColor: const Color(0xFF1A1C1E),
        ),
      ),
      home: const SplashScreen(), // Starts with Splash Screen
    );
  }
}

