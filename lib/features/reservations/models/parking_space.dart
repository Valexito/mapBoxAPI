import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpace {
  final String id;

  /// 'free' | 'occupied'
  final String status;
  final String? currentReservationId;
  final DateTime? updatedAt;

  const ParkingSpace({
    required this.id,
    required this.status,
    this.currentReservationId,
    this.updatedAt,
  });

  factory ParkingSpace.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ParkingSpace(
      id: doc.id,
      status: (data['status'] as String?) ?? 'free',
      currentReservationId: data['currentReservationId'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
