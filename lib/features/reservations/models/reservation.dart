import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String parkingId;
  final String parkingName;
  final int spaceNumber;
  final double lat;
  final double lng;
  final DateTime reservedAt;
  final String userId;

  const Reservation({
    required this.parkingId,
    required this.parkingName,
    required this.spaceNumber,
    required this.lat,
    required this.lng,
    required this.reservedAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    'parkingId': parkingId,
    'parkingName': parkingName,
    'spaceNumber': spaceNumber,
    'lat': lat,
    'lng': lng,
    'reservedAt': Timestamp.fromDate(reservedAt),
    'userId': userId,
  };

  factory Reservation.fromMap(Map<String, dynamic> map) {
    final raw = map['reservedAt'];
    DateTime parseReservedAt(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.parse(v);
      if (v is int) {
        return v > 20000000000
            ? DateTime.fromMillisecondsSinceEpoch(v)
            : DateTime.fromMillisecondsSinceEpoch(v * 1000);
      }
      throw StateError('Invalid reservedAt: $v');
    }

    return Reservation(
      parkingId: map['parkingId'] as String,
      parkingName: map['parkingName'] as String,
      spaceNumber: (map['spaceNumber'] as num).toInt(),
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      reservedAt: parseReservedAt(raw),
      userId: map['userId'] as String,
    );
  }
}
