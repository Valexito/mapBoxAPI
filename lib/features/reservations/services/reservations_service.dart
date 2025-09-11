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
        .map((qs) {
          return qs.docs
              .map(
                (d) => Reservation.fromDoc(
                  d as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();
        });
  }

  Future<String> createReservation(Reservation r) async {
    final doc = await _db.collection('reservations').add(r.toMap());
    return doc.id;
  }

  Future<void> updateReservation(String id, Map<String, dynamic> delta) async {
    await _db.collection('reservations').doc(id).update(delta);
  }

  Future<void> deleteReservation(String id) async {
    await _db.collection('reservations').doc(id).delete();
  }
}
