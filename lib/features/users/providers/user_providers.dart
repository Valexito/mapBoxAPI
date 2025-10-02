import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mapbox_api/features/core/providers/firebase_providers.dart'
    show firestoreProvider, currentUserProvider;

import 'package:mapbox_api/features/users/models/user_role.dart';

// ---------- Refs ----------
final userDocRefProvider =
    Provider.family<DocumentReference<Map<String, dynamic>>, String>(
      (ref, uid) => ref.watch(firestoreProvider).collection('users').doc(uid),
    );

// ---------- Perfil completo ----------
final isProfileCompleteProvider = FutureProvider.family<bool, String>((
  ref,
  uid,
) async {
  try {
    await FirebaseAuth.instance.currentUser?.reload();
  } catch (_) {}
  final snap = await ref.read(userDocRefProvider(uid)).get();
  if (!snap.exists) return false;
  final d = snap.data() ?? <String, dynamic>{};
  String s(dynamic v) => (v as String? ?? '').trim();
  final hasName = s(d['name']).isNotEmpty || s(d['displayName']).isNotEmpty;
  final hasPhone = s(d['phone']).isNotEmpty;
  final hasRole = s(d['role']).isNotEmpty;
  final completed = d['profileCompleted'] == true;
  return (hasName && hasPhone && hasRole) || completed;
});

// ---------- Guardado de perfil ----------
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
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) throw StateError('No hay usuario autenticado.');
    final doc = ref.read(userDocRefProvider(u.uid));
    await doc.set({
      'uid': u.uid,
      'email': u.email,
      'name': name.trim(),
      'displayName': name.trim(),
      'phone': phone.trim(),
      'role': role.trim(),
      'profileCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  };
});

// ---------- Stream de mi perfil ----------
final myProfileStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(userDocRefProvider(uid)).snapshots().map((s) => s.data());
});

// ---------- ¿tengo al menos un parking? ----------
final iOwnAtLeastOneParkingProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return false;
  final db = ref.watch(firestoreProvider);
  try {
    final q =
        await db
            .collection('parkings')
            .where('ownerID', isEqualTo: uid)
            .limit(1)
            .get();
    return q.docs.isNotEmpty;
  } catch (_) {
    return false;
  }
});

// ---------- Rol efectivo ----------
final myRoleStreamProvider = StreamProvider<UserRole>((ref) {
  final profileAsync = ref.watch(myProfileStreamProvider);
  return profileAsync.when(
    data: (data) async* {
      final r = parseRole(data?['role'] as String?);
      if (r != UserRole.unknown) {
        yield r;
        return;
      }
      final owns = await ref.read(iOwnAtLeastOneParkingProvider.future);
      yield owns ? UserRole.provider : UserRole.user;
    },
    loading: () => const Stream<UserRole>.empty(),
    error: (_, __) async* {
      final owns = await ref.read(iOwnAtLeastOneParkingProvider.future);
      yield owns ? UserRole.provider : UserRole.user;
    },
  );
});

// ---------- ¿puede entrar a la app? ----------
final canEnterAppProvider = FutureProvider.family<bool, String>((
  ref,
  uid,
) async {
  final db = ref.watch(firestoreProvider);
  try {
    final doc = await db.collection('users').doc(uid).get();
    if (!doc.exists) return false;

    final data = doc.data() ?? <String, dynamic>{};
    final roleStr = ((data['role'] as String?) ?? '').trim();
    final role = parseRole(roleStr);
    if (role == UserRole.provider || role == UserRole.admin) return true;

    String s(dynamic v) => (v as String? ?? '').trim();
    final hasName =
        s(data['name']).isNotEmpty || s(data['displayName']).isNotEmpty;
    final hasPhone = s(data['phone']).isNotEmpty;
    final hasRole = roleStr.isNotEmpty;
    if ((hasName && hasPhone && hasRole) || data['profileCompleted'] == true) {
      return true;
    }

    final owns =
        await db
            .collection('parkings')
            .where('ownerID', isEqualTo: uid)
            .limit(1)
            .get();
    return owns.docs.isNotEmpty;
  } catch (_) {
    return true; // no bloquear por errores transitorios
  }
});

// ---------- Notification Settings ----------
final notificationSettingsDocProvider =
    Provider.family<DocumentReference<Map<String, dynamic>>, String>(
      (ref, uid) => ref
          .watch(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('notifications'),
    );

final notificationSettingsStreamFamilyProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, uid) {
      return ref
          .watch(notificationSettingsDocProvider(uid))
          .snapshots()
          .map((s) => s.data());
    });

final myNotificationSettingsStreamProvider =
    StreamProvider<Map<String, dynamic>?>((ref) {
      final uid = ref.watch(currentUserProvider)?.uid;
      if (uid == null) return const Stream.empty();
      return ref
          .watch(notificationSettingsDocProvider(uid))
          .snapshots()
          .map((s) => s.data());
    });

final saveNotificationSettingsProvider =
    Provider<Future<void> Function(String uid, Map<String, dynamic> settings)>((
      ref,
    ) {
      return (String uid, Map<String, dynamic> settings) async {
        await ref.read(notificationSettingsDocProvider(uid)).set({
          ...settings,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      };
    });
