// lib/features/users/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_api/features/users/models/user_profile.dart';
import 'package:mapbox_api/features/users/models/notification_settings.dart';

class UserService {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  UserService(this.auth, this.db);

  // ---- Profile ----
  Future<void> saveProfile({
    required String name,
    required String phone,
    required String role,
  }) async {
    final u = auth.currentUser;
    if (u == null) throw StateError('No authenticated user');
    final doc = db.collection('users').doc(u.uid);

    final profile = UserProfile(
      uid: u.uid,
      email: u.email ?? '',
      name: name.trim(),
      phone: phone.trim(),
      role: role,
      createdAt: DateTime.now(),
    );
    await doc.set(profile.toMap(), SetOptions(merge: true));
  }

  Stream<UserProfile?> watchProfile() {
    final u = auth.currentUser;
    if (u == null) return const Stream.empty();
    return db
        .collection('users')
        .doc(u.uid)
        .snapshots()
        .map((d) => d.exists ? UserProfile.fromDoc(d) : null);
  }

  // ---- Notification settings ----
  DocumentReference<Map<String, dynamic>> _notifRef(String uid) => db
      .collection('users')
      .doc(uid)
      .collection('settings')
      .doc('notifications');

  Future<NotificationSettings> getNotificationSettings() async {
    final u = auth.currentUser;
    if (u == null) throw StateError('No authenticated user');
    final doc = await _notifRef(u.uid).get();
    return doc.exists
        ? NotificationSettings.fromDoc(doc)
        : NotificationSettings.defaults();
  }

  Stream<NotificationSettings> watchNotificationSettings() {
    final u = auth.currentUser;
    if (u == null) return Stream.value(NotificationSettings.defaults());
    return _notifRef(u.uid).snapshots().map((d) {
      if (!d.exists) return NotificationSettings.defaults();
      return NotificationSettings.fromDoc(d);
    });
  }

  Future<void> saveNotificationSettings(NotificationSettings s) async {
    final u = auth.currentUser;
    if (u == null) throw StateError('No authenticated user');
    await _notifRef(u.uid).set(s.toMap(), SetOptions(merge: true));
  }
}
