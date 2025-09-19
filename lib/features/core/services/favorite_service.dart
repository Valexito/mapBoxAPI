import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_api/features/reservations/models/parking.dart';

/// Servicio para manejar /favorites asegurando compatibilidad con docs antiguos
/// que pudieron crearse con auto-ID.
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

  /// ID determinista: {uid}_{parkingId} (lo usamos al escribir de ahora en adelante)
  String _docId(String parkingId) => '${_uid}_$parkingId';

  /// Añadir/actualizar favorito con los datos del parking.
  /// Escribe en el doc determinista y limpia duplicados con auto-ID si los hay.
  Future<void> add(Parking p) async {
    if (p.id.isEmpty) {
      throw ArgumentError('Parking.id must not be empty');
    }

    final cover =
        (p.photos.isNotEmpty ? p.photos.first : null) ??
        p.coverUrl ??
        p.imageUrl;

    final map = <String, dynamic>{
      'userId': _uid,
      'parkingId': p.id,
      'name': p.name,
      'ownerID': p.ownerID,
      'price': p.price,
      'spaces': p.spaces,
      'rating': (p.rating ?? 0).toDouble(),
      'originalPrice': p.originalPrice,
      'imageUrl': p.imageUrl, // legacy
      'coverUrl': cover, // principal para la UI
      'photos': p.photos, // opcional
      'descripcion': p.descripcion,
      'lat': p.lat,
      'lng': p.lng,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Escribimos en el doc determinista
    await _col.doc(_docId(p.id)).set(map, SetOptions(merge: true));

    // (Opcional) limpia duplicados con auto-ID si existen
    final dupes =
        await _col
            .where('userId', isEqualTo: _uid)
            .where('parkingId', isEqualTo: p.id)
            .get();
    for (final d in dupes.docs) {
      if (d.id != _docId(p.id)) {
        await d.reference.delete();
      }
    }
  }

  /// Quitar favorito por parkingId (borra el determinista y cualquier auto-ID previo)
  Future<void> removeByParkingId(String parkingId) async {
    // borra determinista
    await _col.doc(_docId(parkingId)).delete();

    // borra cualquier auto-ID que hubiera quedado
    final qs =
        await _col
            .where('userId', isEqualTo: _uid)
            .where('parkingId', isEqualTo: parkingId)
            .get();
    for (final d in qs.docs) {
      if (d.exists) await d.reference.delete();
    }
  }

  /// Quitar por docId (útil desde la lista de favoritos)
  Future<void> removeByDocId(String docId) async {
    await _col.doc(docId).delete();
  }

  /// ¿Es favorito? — No dependemos del docId, sino de la existencia de un match.
  Stream<bool> isFavoriteStream(String parkingId) {
    return _col
        .where('userId', isEqualTo: _uid)
        .where('parkingId', isEqualTo: parkingId)
        .limit(1)
        .snapshots()
        .map((qs) => qs.docs.isNotEmpty);
  }
}
