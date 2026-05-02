import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  UserModel? _userModel;
  bool _isLoading = false;
  bool _isInitializing = true;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    // 1. Check local session for instant load
    await _loadSessionLocally();
    if (_userModel != null) {
      _isInitializing = false;
      notifyListeners();
    }

    // 2. Wait for Firebase Auth to confirm session state (prevents login screen flash)
    final initialUser = await _firebaseService.authStateChanges.first;
    if (initialUser != null) {
      if (_userModel == null || _userModel!.uid != initialUser.uid) {
        final updatedUser = await _firebaseService.getUserDetails(initialUser.uid);
        if (updatedUser != null) {
          _userModel = updatedUser;
          await _saveSessionLocally(updatedUser);
        }
      }
    } else {
      if (_userModel != null) {
        _userModel = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_session');
      }
    }
    
    _isInitializing = false;
    notifyListeners();

    // 3. Keep listening for future changes (e.g. logout in another tab)
    _listenToAuthState();
  }

  void _listenToAuthState() {
    // Skip the first event since we already handled it in _initAuth
    _firebaseService.authStateChanges.skip(1).listen((User? user) async {
      if (user != null) {
        if (_userModel == null || _userModel!.uid != user.uid) {
          final updatedUser = await _firebaseService.getUserDetails(user.uid);
          if (updatedUser != null) {
            _userModel = updatedUser;
            await _saveSessionLocally(updatedUser);
            notifyListeners();
          }
        }
      } else {
        if (_userModel != null) {
          _userModel = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('user_session');
          notifyListeners();
        }
      }
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _saveSessionLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_session', json.encode(user.toMap()));
  }

  Future<void> _loadSessionLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString('user_session');
    if (sessionData != null) {
      try {
        final Map<String, dynamic> data = json.decode(sessionData);
        _userModel = UserModel.fromMap(data, data['uid'] ?? '');
        notifyListeners();
      } catch (e) {
        print('Error parsing local session: $e');
      }
    }
  }

  Future<void> signUp(String email, String password, String name, String age, BuildContext context) async {
    _setLoading(true);
    try {
      _userModel = await _firebaseService.signUp(email, password, name, age);
      if (_userModel != null) {
        await _saveSessionLocally(_userModel!);
        notifyListeners();
      }
      // Navigation is handled by authStateChanges stream in main or splash
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn(String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      _userModel = await _firebaseService.signIn(email, password);
      if (_userModel != null) {
        await _saveSessionLocally(_userModel!);
        notifyListeners();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _firebaseService.signOut();
    _userModel = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    _setLoading(false);
    notifyListeners();
  }
}
