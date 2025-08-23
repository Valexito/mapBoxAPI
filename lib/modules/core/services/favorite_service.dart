import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_api/modules/reservations/models/parking.dart';

class FavoriteService {
  FavoriteService._();
  static final instance = FavoriteService._();

  final _auth = FirebaseAuth.instance;
  final _col = FirebaseFirestore.instance.collection('favorites');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User not signed in');
    return uid;
  }

  // Un doc por (uid + parkingId) para evitar duplicados
  String _docId(String parkingId) => '${_uid}_$parkingId';

  Future<void> add(Parking p) async {
    if (p.id.isEmpty) throw ArgumentError('Parking.id must not be empty');
    final map = {
      'userId': _uid,
      'parkingId': p.id,
      'name': p.name,
      'ownerID': p.ownerID,
      'price': p.price, // int
      'spaces': p.spaces, // int
      'rating': (p.rating ?? 0).toDouble(),
      'originalPrice': p.originalPrice, // double?
      'imageUrl': p.imageUrl,
      'descripcion': p.descripcion,
      'lat': p.lat, // double
      'lng': p.lng, // double
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _col.doc(_docId(p.id)).set(map, SetOptions(merge: true));
  }

  Future<void> removeByParkingId(String parkingId) async {
    await _col.doc(_docId(parkingId)).delete();
  }

  Future<void> removeByDocId(String docId) async {
    await _col.doc(docId).delete();
  }

  Stream<bool> isFavoriteStream(String parkingId) {
    return _col.doc(_docId(parkingId)).snapshots().map((d) => d.exists);
  }
}
