import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String? id;
  final String name;
  final int age;
  final String address;
  final String previousClass;
  final bool passedPreviousClass;
  final String mobile;
  final String photoUrl;
  final DateTime createdAt;

  Student({
    this.id,
    required this.name,
    required this.age,
    required this.address,
    required this.previousClass,
    required this.passedPreviousClass,
    required this.mobile,
    required this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'address': address,
      'previousClass': previousClass,
      'passedPreviousClass': passedPreviousClass,
      'mobile': mobile,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map, String docId) {
    return Student(
      id: docId,
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      address: map['address'] ?? '',
      previousClass: map['previousClass'] ?? '',
      passedPreviousClass: map['passedPreviousClass'] ?? false,
      mobile: map['mobile'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
