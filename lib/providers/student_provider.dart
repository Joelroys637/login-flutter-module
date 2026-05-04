import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/student_model.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> registerStudent(Student student, XFile? imageFile) async {
    _setLoading(true);
    _setError(null);
    try {
      String photoUrl = '';

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        photoUrl = base64Encode(bytes);
      }

      Student newStudent = Student(
        name: student.name,
        age: student.age,
        address: student.address,
        previousClass: student.previousClass,
        passedPreviousClass: student.passedPreviousClass,
        mobile: student.mobile,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('students').add(newStudent.toMap());
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateStudent(String docId, Student updatedStudent, XFile? newImage) async {
    _setLoading(true);
    _setError(null);
    try {
      Map<String, dynamic> updateData = {
        'name': updatedStudent.name,
        'age': updatedStudent.age,
        'address': updatedStudent.address,
        'previousClass': updatedStudent.previousClass,
        'passedPreviousClass': updatedStudent.passedPreviousClass,
        'mobile': updatedStudent.mobile,
      };

      if (newImage != null) {
        final bytes = await newImage.readAsBytes();
        updateData['photoUrl'] = base64Encode(bytes);
      }

      await _firestore.collection('students').doc(docId).update(updateData);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteStudent(String docId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _firestore.collection('students').doc(docId).delete();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Stream<List<Student>> getStudents() {
    return _firestore.collection('students').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Student.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
