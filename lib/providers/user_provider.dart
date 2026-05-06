import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
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

  Future<bool> registerUser(UserModel user, XFile? imageFile) async {
    _setLoading(true);
    _setError(null);
    try {
      String photoUrl = '';

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        photoUrl = base64Encode(bytes);
      } else {
        photoUrl = user.photoUrl;
      }

      UserModel newUser = UserModel(
        name: user.name,
        password: user.password,
        age: user.age,
        address: user.address,
        photoUrl: photoUrl,
        role: user.role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').add(newUser.toMap());
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateUser(String docId, UserModel updatedUser, XFile? newImage) async {
    _setLoading(true);
    _setError(null);
    try {
      Map<String, dynamic> updateData = updatedUser.toMap();
      updateData.remove('createdAt'); // Don't update creation time

      if (newImage != null) {
        final bytes = await newImage.readAsBytes();
        updateData['photoUrl'] = base64Encode(bytes);
      }

      await _firestore.collection('users').doc(docId).update(updateData);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteUser(String docId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _firestore.collection('users').doc(docId).delete();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      List<UserModel> users = [];
      for (var doc in snapshot.docs) {
        try {
          users.add(UserModel.fromMap(doc.data(), doc.id));
        } catch (e) {
          debugPrint("Error parsing user ${doc.id}: $e");
        }
      }
      return users;
    });
  }
}
