import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  final String? id;
  final String name;
  final String password;
  final int age;
  final String address;
  final String photoUrl; // Base64
  final String role;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.password,
    required this.age,
    required this.address,
    required this.photoUrl,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'password': password,
      'age': age,
      'address': address,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime createdAt;
    try {
      final ts = map['createdAt'];
      if (ts is Timestamp) {
        createdAt = ts.toDate();
      } else {
        createdAt = DateTime.now();
      }
    } catch (_) {
      createdAt = DateTime.now();
    }

    return UserModel(
      id: docId,
      name: map['name'] ?? 'Unnamed User',
      password: map['password'] ?? '',
      age: int.tryParse(map['age']?.toString() ?? '0') ?? 0,
      address: map['address'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      role: map['role'] ?? 'User',
      createdAt: createdAt,
    );
  }
}
