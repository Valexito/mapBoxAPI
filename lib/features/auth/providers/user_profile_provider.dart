import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_providers.dart';

final firestoreProvider = Provider<FirebaseFirestore>((_) {
  return FirebaseFirestore.instance;
});

/// true si existe users/{uid}
final hasUserProfileProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  final db = ref.watch(firestoreProvider);
  final doc = await db.collection('users').doc(user.uid).get();
  return doc.exists;
});
