import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/role_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  RoleModel? _currentRole;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  RoleModel? get currentRole => _currentRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String? userName = prefs.getString('userName');

    if (isLoggedIn && userName != null) {
      // For the sake of this requirement, we fetch the user from Firestore
      // or use the default 'leo' if that's the one logged in.
      await _loadUserData(userName);
    }
  }

  Future<void> _loadUserData(String userName) async {
    // 1. Immediate initialization for default admin 'leo'
    if (userName == 'leo') {
      _currentUser = UserModel(
        name: 'leo',
        password: '12345678',
        age: 25,
        address: 'Default Admin Address',
        photoUrl: '',
        role: 'Super Admin',
        createdAt: DateTime.now(),
      );
      await _loadUserRole('Super Admin');
      notifyListeners();
      
      // Attempt to refresh from Firestore if available, but skip if it fails
      try {
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: userName)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          _currentUser = UserModel.fromMap(query.docs.first.data(), query.docs.first.id);
          await _loadUserRole(_currentUser!.role);
          notifyListeners();
        }
      } catch (e) {
        debugPrint("Firestore fetch skipped for leo: $e");
      }
      return;
    }

    // 2. Standard flow for other users
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: userName)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        _currentUser = UserModel.fromMap(query.docs.first.data(), query.docs.first.id);
        await _loadUserRole(_currentUser!.role);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  Future<void> _loadUserRole(String roleName) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('roles')
          .where('name', isEqualTo: roleName)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        _currentRole = RoleModel.fromMap(query.docs.first.data(), query.docs.first.id);
      } else {
        // Default Super Admin permissions if role not found
        _currentRole = RoleModel(
          name: roleName,
          description: 'Full access role',
          isActive: true,
          permissions: {
            'Dashboard': ModulePermissions(read: true, write: true, update: true, delete: true),
            'User': ModulePermissions(read: true, write: true, update: true, delete: true),
            'Role & Permissions': ModulePermissions(read: true, write: true, update: true, delete: true),
          },
        );
      }
    } catch (e) {
      debugPrint("Error loading role: $e");
      // Critical fallback for Super Admin to prevent menu lockouts
      if (roleName == 'Super Admin') {
        _currentRole = RoleModel(
          name: 'Super Admin',
          description: 'Full access role (Offline Fallback)',
          isActive: true,
          permissions: {
            'Dashboard': ModulePermissions(read: true, write: true, update: true, delete: true),
            'User': ModulePermissions(read: true, write: true, update: true, delete: true),
            'Role & Permissions': ModulePermissions(read: true, write: true, update: true, delete: true),
          },
        );
      }
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Requirement: Default credentials leo / 12345678
      if (username == 'leo' && password == '12345678') {
        await _loadUserData(username);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', username);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Check Firestore for other users
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        _currentUser = UserModel.fromMap(query.docs.first.data(), query.docs.first.id);
        await _loadUserRole(_currentUser!.role);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', username);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    _currentRole = null;
    notifyListeners();
  }

  bool hasPermission(String module, String action) {
    if (_currentRole == null) return false;
    
    // If it's a Super Admin, grant access by default to ensure no lockout
    if (_currentRole!.name == 'Super Admin') return true;

    final modulePerms = _currentRole!.permissions[module];
    if (modulePerms == null) return false;

    switch (action) {
      case 'read': return modulePerms.read;
      case 'write': return modulePerms.write;
      case 'update': return modulePerms.update;
      case 'delete': return modulePerms.delete;
      default: return false;
    }
  }
}
