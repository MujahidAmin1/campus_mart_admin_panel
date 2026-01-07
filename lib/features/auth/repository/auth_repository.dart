import 'dart:developer';

import 'package:campus_mart_admin/core/providers.dart';
import 'package:campus_mart_admin/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepoProvider = Provider((ref) {
  return AuthRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firebasefire: ref.watch(firestoreProvider),
  );
});
FirebaseFirestore _fire = FirebaseFirestore.instance;

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebasefire;
  AuthRepository({required this.firebaseAuth, required this.firebasefire});

  //login
  Future<User?> login(String email, String password) async {
    try {
      final creds = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userDoc = await firebasefire
          .collection('users')
          .doc(creds.user!.uid)
          .get();
      final userdata = userDoc.data()!;
      final user = User.fromMap(userdata);
      if (user.userType != UserType.admin) {
        await firebaseAuth.signOut();
        throw Exception('Access Denied: Only accounts with admin privileges can access the Admin Panel. Your account does not have admin access.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}
