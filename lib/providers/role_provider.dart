import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/role_model.dart';

class RoleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<RoleModel> _roles = [];
  bool _isLoading = false;

  List<RoleModel> get roles => _roles;
  bool get isLoading => _isLoading;

  RoleProvider() {
    _fetchRoles();
  }

  void _fetchRoles() {
    _firestore.collection('roles').snapshots().listen(
      (snapshot) async {
        if (snapshot.docs.isEmpty) {
          await _initializeDefaults();
          return;
        }
        
        List<RoleModel> loadedRoles = [];
        for (var doc in snapshot.docs) {
          try {
            loadedRoles.add(RoleModel.fromMap(doc.data(), doc.id));
          } catch (e) {
            debugPrint("Critical failure parsing role ${doc.id}: $e");
          }
        }
        
        _roles = loadedRoles;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Firestore Roles Stream Error: $error");
      }
    );
  }

  Future<void> _initializeDefaults() async {
    final superAdmin = RoleModel(
      name: 'Super Admin',
      description: 'Full system access',
      isActive: true,
      permissions: {
        'Dashboard': ModulePermissions(read: true, write: true, update: true, delete: true),
        'User': ModulePermissions(read: true, write: true, update: true, delete: true),
        'Role & Permissions': ModulePermissions(read: true, write: true, update: true, delete: true),
      },
    );
    await _firestore.collection('roles').add(superAdmin.toMap());
  }

  Future<bool> addRole(RoleModel role) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('roles').add(role.toMap());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error adding role: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRole(RoleModel role) async {
    if (role.id == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('roles').doc(role.id).update(role.toMap());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error updating role: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRole(String roleId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('roles').doc(roleId).delete();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting role: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  RoleModel? getRoleByName(String name) {
    try {
      return _roles.firstWhere((role) => role.name == name);
    } catch (e) {
      return null;
    }
  }
}
