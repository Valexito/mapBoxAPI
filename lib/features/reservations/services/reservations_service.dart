// lib/features/reservations/services/reservations_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';

class ReservationsService {
  ReservationsService(this._db);
  final FirebaseFirestore _db;

  Stream<List<Reservation>> watchUserReservations(String userId) {
    return _db
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .orderBy('reservedAt', descending: true)
        .snapshots()
        .map(
          (qs) => qs.docs.map((d) => Reservation.fromMap(d.data())).toList(),
        );
  }

  Future<void> createReservation(Reservation r) async {
    await _db.collection('reservations').add(r.toMap());
  }
}
