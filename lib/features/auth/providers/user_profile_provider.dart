import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Indica si el usuario **ya tiene** documento de perfil en `users/{uid}`.
final hasUserProfileProvider = FutureProvider<bool>((ref) async {
  final u = FirebaseAuth.instance.currentUser;
  if (u == null) return false;
  final snap =
      await FirebaseFirestore.instance.collection('users').doc(u.uid).get();
  return snap.exists;
});
