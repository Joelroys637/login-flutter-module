import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up
  Future<UserModel?> signUp(String email, String password, String name, String age) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        UserModel userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          name: name,
          age: age,
          createdAt: DateTime.now(),
        );

        // Store user in Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toMap());

        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    } catch (e) {
      throw 'An error occurred during sign up';
    }
    return null;
  }

  // Sign in
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await getUserDetails(credential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    } catch (e) {
      throw 'An error occurred during sign in';
    }
    return null;
  }

  // Get user details
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
    } catch (e) {
      print('Error getting user details: $e');
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
