import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ModulePermissions {
  bool read;
  bool write;
  bool update;
  bool delete;

  ModulePermissions({
    this.read = false,
    this.write = false,
    this.update = false,
    this.delete = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'read': read,
      'write': write,
      'update': update,
      'delete': delete,
    };
  }

  factory ModulePermissions.fromMap(Map<String, dynamic> map) {
    return ModulePermissions(
      read: map['read'] ?? false,
      write: map['write'] ?? false,
      update: map['update'] ?? false,
      delete: map['delete'] ?? false,
    );
  }
}

class RoleModel {
  final String? id;
  final String name;
  final String description;
  final bool isActive;
  final Map<String, ModulePermissions> permissions;

  RoleModel({
    this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.permissions,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
      'permissions': permissions.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory RoleModel.fromMap(Map<String, dynamic> map, String docId) {
    Map<String, ModulePermissions> permissions = {};
    try {
      final permissionsMap = (map['permissions'] as Map?) ?? {};
      permissionsMap.forEach((key, value) {
        if (value is Map) {
          permissions[key.toString()] = ModulePermissions.fromMap(Map<String, dynamic>.from(value));
        }
      });
    } catch (e) {
      debugPrint("Error parsing permissions for role $docId: $e");
    }

    // Ensure default modules exist if missing
    for (var module in ['Dashboard', 'User', 'Role & Permissions']) {
      permissions.putIfAbsent(module, () => ModulePermissions());
    }

    return RoleModel(
      id: docId,
      name: map['name'] ?? 'Unnamed Role',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
      permissions: permissions,
    );
  }

  static RoleModel empty() {
    return RoleModel(
      name: '',
      description: '',
      isActive: true,
      permissions: {
        'Dashboard': ModulePermissions(),
        'User': ModulePermissions(),
        'Role & Permissions': ModulePermissions(),
      },
    );
  }
}
