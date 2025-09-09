// lib/features/users/providers/user_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mapbox_api/features/core/providers/firebase_providers.dart';
import 'package:mapbox_api/features/users/services/user_service.dart';
import 'package:mapbox_api/features/users/models/user_profile.dart';
import 'package:mapbox_api/features/users/models/notification_settings.dart';

// DI del servicio
final userServiceProvider = Provider<UserService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final db = ref.watch(firestoreProvider);
  return UserService(auth, db);
});

// Usuario actual (FirebaseAuth)
final currentFirebaseUserProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.userChanges();
});

// Perfil de usuario (Firestore)
final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final svc = ref.watch(userServiceProvider);
  return svc.watchProfile();
});

// Acción: guardar perfil
final saveProfileProvider = Provider<
  Future<void> Function({
    required String name,
    required String phone,
    required String role,
  })
>((ref) {
  final svc = ref.watch(userServiceProvider);
  return ({
    required String name,
    required String phone,
    required String role,
  }) => svc.saveProfile(name: name, phone: phone, role: role);
});

// Notificaciones
final notificationSettingsStreamProvider = StreamProvider<NotificationSettings>(
  (ref) {
    final svc = ref.watch(userServiceProvider);
    return svc.watchNotificationSettings();
  },
);

// Acción: guardar notificaciones
final saveNotificationSettingsProvider =
    Provider<Future<void> Function(NotificationSettings)>((ref) {
      final svc = ref.watch(userServiceProvider);
      return (s) => svc.saveNotificationSettings(s);
    });
