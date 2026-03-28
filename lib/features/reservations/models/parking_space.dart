import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpace {
  final String id;
  final String status; // free | occupied
  final String? currentReservationId;
  final DateTime? updatedAt;

  const ParkingSpace({
    required this.id,
    required this.status,
    this.currentReservationId,
    this.updatedAt,
  });

  bool get isFree => status == 'free';
  bool get isOccupied => status == 'occupied';

  factory ParkingSpace.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return ParkingSpace(
      id: doc.id,
      status: (data['status'] as String?) ?? 'free',
      currentReservationId: data['currentReservationId'] as String?,
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'currentReservationId': currentReservationId,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  ParkingSpace copyWith({
    String? id,
    String? status,
    String? currentReservationId,
    DateTime? updatedAt,
  }) {
    return ParkingSpace(
      id: id ?? this.id,
      status: status ?? this.status,
      currentReservationId: currentReservationId ?? this.currentReservationId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
