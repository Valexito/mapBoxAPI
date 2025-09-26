import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mapbox_api/features/core/providers/firebase_providers.dart'
    show firestoreProvider, currentUserProvider;

import 'package:mapbox_api/features/users/models/user_role.dart';

/// ------------------------------
/// Doc ref /users/{uid}
/// ------------------------------
final userDocRefProvider =
    Provider.family<DocumentReference<Map<String, dynamic>>, String>((
      ref,
      uid,
    ) {
      return ref.watch(firestoreProvider).collection('users').doc(uid);
    });

/// ------------------------------
/// Perfil completo (name/phone/role)
/// ------------------------------
final isProfileCompleteProvider = FutureProvider.family<bool, String>((
  ref,
  uid,
) async {
  final snap = await ref.watch(userDocRefProvider(uid)).get();
  if (!snap.exists) return false;

  final data = snap.data() ?? <String, dynamic>{};
  final hasName = (data['name'] as String?)?.trim().isNotEmpty == true;
  final hasPhone = (data['phone'] as String?)?.trim().isNotEmpty == true;
  final hasRole = (data['role'] as String?)?.trim().isNotEmpty == true;

  return hasName && hasPhone && hasRole;
});

/// ------------------------------
/// Guardar perfil autenticado
/// ------------------------------
final saveProfileProvider = Provider<
  Future<void> Function({
    required String name,
    required String phone,
    required String role,
  })
>((ref) {
  return ({
    required String name,
    required String phone,
    required String role,
  }) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) throw StateError('No hay usuario autenticado.');

    final doc = ref.read(userDocRefProvider(uid));
    await doc.set({
      'name': name.trim(),
      'phone': phone.trim(),
      'role': role.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  };
});

/// ------------------------------
/// Stream de perfil /users/{uid}
/// ------------------------------
final userProfileStreamProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, uid) {
      return ref
          .watch(userDocRefProvider(uid))
          .snapshots()
          .map((s) => s.data());
    });

/// Perfil del usuario autenticado
final myProfileStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) {
    return const Stream<Map<String, dynamic>?>.empty();
  }
  return ref.watch(userDocRefProvider(uid)).snapshots().map((s) => s.data());
});

/// ------------------------------
/// Stream SOLO del rol actual
/// ------------------------------
final myRoleStreamProvider = StreamProvider<UserRole>((ref) {
  final profileAsync = ref.watch(myProfileStreamProvider);
  return profileAsync.when(
    data: (data) async* {
      yield parseRole(data?['role'] as String?);
    },
    loading: () => const Stream<UserRole>.empty(),
    error: (_, __) => const Stream<UserRole>.empty(),
  );
});

/// ------------------------------
/// Notificaciones (subcolección)
/// ------------------------------
final notificationSettingsStreamFamilyProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, uid) {
      final doc = ref
          .watch(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('notifications');
      return doc.snapshots().map((s) => s.data());
    });

final myNotificationSettingsStreamProvider =
    StreamProvider<Map<String, dynamic>?>((ref) {
      final uid = ref.watch(currentUserProvider)?.uid;
      if (uid == null) {
        return const Stream<Map<String, dynamic>?>.empty();
      }
      final doc = ref
          .watch(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('notifications');
      return doc.snapshots().map((s) => s.data());
    });

final saveNotificationSettingsProvider =
    Provider<Future<void> Function(String uid, Map<String, dynamic> settings)>((
      ref,
    ) {
      return (String uid, Map<String, dynamic> settings) async {
        final doc = ref
            .read(firestoreProvider)
            .collection('users')
            .doc(uid)
            .collection('settings')
            .doc('notifications');
        await doc.set({
          ...settings,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      };
    });
