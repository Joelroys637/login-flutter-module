import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPermissions {
  bool read;
  bool write;
  bool delete;

  AdminPermissions({
    this.read = true,
    this.write = false,
    this.delete = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'read': read,
      'write': write,
      'delete': delete,
    };
  }

  factory AdminPermissions.fromMap(Map<String, dynamic> map) {
    return AdminPermissions(
      read: map['read'] ?? true,
      write: map['write'] ?? false,
      delete: map['delete'] ?? false,
    );
  }
}

class AdminPermissionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final Map<String, AdminPermissions> _permissions = {
    'Basic Admin': AdminPermissions(read: true, write: false, delete: false),
    'Intermediate Admin': AdminPermissions(read: true, write: true, delete: false),
    'Super Admin': AdminPermissions(read: true, write: true, delete: true),
  };

  AdminPermissionProvider() {
    _initPermissions();
  }

  Map<String, AdminPermissions> get permissions => _permissions;

  // Initialize by listening to Firestore updates
  void _initPermissions() {
    _firestore.collection('permissions').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (_permissions.containsKey(doc.id)) {
          _permissions[doc.id] = AdminPermissions.fromMap(doc.data());
        }
      }
      notifyListeners();
    });
  }

  Future<void> updatePermission(String adminType, {bool? read, bool? write, bool? delete, bool? all}) async {
    if (!_permissions.containsKey(adminType)) return;

    final current = _permissions[adminType]!;
    bool newRead = current.read;
    bool newWrite = current.write;
    bool newDelete = current.delete;

    if (all != null) {
      newRead = all;
      newWrite = all;
      newDelete = all;
    } else {
      if (read != null) newRead = read;
      if (write != null) newWrite = write;
      if (delete != null) newDelete = delete;
    }

    try {
      await _firestore.collection('permissions').doc(adminType).set({
        'read': newRead,
        'write': newWrite,
        'delete': newDelete,
      });
      // Local state is updated via the snapshot listener
    } catch (e) {
      print("Error updating permissions: $e");
    }
  }

  AdminPermissions getPermissionsFor(String adminType) {
    return _permissions[adminType] ?? AdminPermissions();
  }
}
