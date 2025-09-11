import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String userId;
  final String parkingId;
  final String parkingName;
  final int spaceNumber;

  /// Guardamos reservedAt; la UI puede leer startedAt (alias).
  final DateTime reservedAt;

  final DateTime? endedAt;
  final String state; // "active" | "completed" | "cancelled"
  final int? pricePerHour;
  final int? amount;
  final int? durationMinutes;

  Reservation({
    required this.id,
    required this.userId,
    required this.parkingId,
    required this.parkingName,
    required this.spaceNumber,
    required this.reservedAt,
    this.endedAt,
    this.state = "active",
    this.pricePerHour,
    this.amount,
    this.durationMinutes,
  });

  DateTime get startedAt => reservedAt;

  factory Reservation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Reservation(
      id: doc.id,
      userId: data['userId'] ?? '',
      parkingId: data['parkingId'] ?? '',
      parkingName: data['parkingName'] ?? '',
      spaceNumber: (data['spaceNumber'] ?? 0) as int,
      reservedAt:
          ((data['reservedAt'] ?? data['startedAt']) as Timestamp? ??
                  Timestamp.now())
              .toDate(),
      endedAt:
          data['endedAt'] != null
              ? (data['endedAt'] as Timestamp).toDate()
              : null,
      state: data['state'] ?? 'active',
      pricePerHour: (data['pricePerHour'] as num?)?.toInt(),
      amount: (data['amount'] as num?)?.toInt(),
      durationMinutes: (data['durationMinutes'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'parkingId': parkingId,
      'parkingName': parkingName,
      'spaceNumber': spaceNumber,
      'reservedAt': Timestamp.fromDate(reservedAt),
      'startedAt': Timestamp.fromDate(reservedAt), // alias para compatibilidad
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'state': state,
      'pricePerHour': pricePerHour,
      'amount': amount,
      'durationMinutes': durationMinutes,
    };
  }
}
