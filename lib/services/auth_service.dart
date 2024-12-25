import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum UserRole { Admin, ProjectOwner, Bidder }

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserRole role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      await _db.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': role.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc =
          await _db.collection('users').doc(currentUser!.uid).get();

      if (!userDoc.exists ||
          userDoc['phoneNumber'] == null ||
          userDoc['phoneNumber'].toString().isEmpty) {
        return 'MISSING_PHONE_NUMBER';
      }

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> updatePhoneNumber(String phoneNumber) async {
    if (currentUser == null) return;
    await _db.collection('users').doc(currentUser!.uid).update({
      'phoneNumber': phoneNumber,
    });
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<String?> getUserRole() async {
    if (currentUser == null) return null;
    DocumentSnapshot doc =
        await _db.collection('users').doc(currentUser!.uid).get();
    if (!doc.exists) return null;
    return doc['role'];
  }

  Future<String?> getUserPhoneNumber() async {
    if (currentUser == null) return null;
    DocumentSnapshot doc =
        await _db.collection('users').doc(currentUser!.uid).get();
    if (!doc.exists) return null;
    return doc['phoneNumber'];
  }

  Future<String?> getUserName() async {
    if (currentUser == null) return 'Unknown';
    DocumentSnapshot doc =
        await _db.collection('users').doc(currentUser!.uid).get();
    if (!doc.exists) return 'Unknown';
    return doc['name'];
  }
}
