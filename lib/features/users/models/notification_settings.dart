// lib/features/users/models/notification_settings.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSettings {
  final bool enableAll;
  final bool emailAlerts;
  final bool reservationAlerts;
  final bool generalAlerts;

  const NotificationSettings({
    required this.enableAll,
    required this.emailAlerts,
    required this.reservationAlerts,
    required this.generalAlerts,
  });

  factory NotificationSettings.defaults() => const NotificationSettings(
    enableAll: true,
    emailAlerts: false,
    reservationAlerts: true,
    generalAlerts: true,
  );

  factory NotificationSettings.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return NotificationSettings(
      enableAll: (d['enableAll'] as bool?) ?? true,
      emailAlerts: (d['emailAlerts'] as bool?) ?? false,
      reservationAlerts: (d['reservationAlerts'] as bool?) ?? true,
      generalAlerts: (d['generalAlerts'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'enableAll': enableAll,
    'emailAlerts': emailAlerts,
    'reservationAlerts': reservationAlerts,
    'generalAlerts': generalAlerts,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  NotificationSettings copyWith({
    bool? enableAll,
    bool? emailAlerts,
    bool? reservationAlerts,
    bool? generalAlerts,
  }) => NotificationSettings(
    enableAll: enableAll ?? this.enableAll,
    emailAlerts: emailAlerts ?? this.emailAlerts,
    reservationAlerts: reservationAlerts ?? this.reservationAlerts,
    generalAlerts: generalAlerts ?? this.generalAlerts,
  );
}
