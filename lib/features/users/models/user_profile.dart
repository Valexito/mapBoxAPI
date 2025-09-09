// lib/features/users/models/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role; // 'user' | 'provider'
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'user',
      createdAt:
          (data['createdAt'] is Timestamp)
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(
                (data['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
              ),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'name': name,
    'phone': phone,
    'role': role,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  UserProfile copyWith({String? name, String? phone, String? role}) =>
      UserProfile(
        uid: uid,
        email: email,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        createdAt: createdAt,
      );
}
