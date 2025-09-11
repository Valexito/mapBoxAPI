// lib/features/reservations/providers/reservations_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_api/features/core/providers/firebase_providers.dart';
import 'package:mapbox_api/features/reservations/models/parking_space.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';

/// Stream de /parkings/{id}/spaces ordenados por número
final parkingSpacesProvider = StreamProvider.family<List<ParkingSpace>, String>(
  (ref, parkingId) {
    final db = ref.watch(firestoreProvider);
    final q = db
        .collection('parkings')
        .doc(parkingId)
        .collection('spaces')
        .orderBy(FieldPath.documentId);
    return q.snapshots().map((snap) {
      return snap.docs
          .map(
            (d) => ParkingSpace.fromDoc(
              d as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    });
  },
);

/// Lista de reservas del usuario autenticado
final userReservationsProvider = FutureProvider<List<Reservation>>((ref) async {
  final db = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  final uid = auth.currentUser?.uid;
  if (uid == null) return const [];

  final q =
      await db
          .collection('reservations')
          .where('userId', isEqualTo: uid)
          .orderBy('reservedAt', descending: true)
          .get();

  return q.docs
      .map(
        (d) => Reservation.fromDoc(d as DocumentSnapshot<Map<String, dynamic>>),
      )
      .toList();
});

/// Hace la reserva cumpliendo las reglas:
/// 1) Crea /reservations/{id} con state:"active", userId y reservedAt timestamp
/// 2) Actualiza /parkings/{pid}/spaces/{N} de free→occupied
///    seteando currentReservationId = id de arriba
final reserveSpaceProvider = Provider<
  Future<String> Function({
    required String parkingId,
    required String parkingName,
    required int spaceNumber,
  })
>((ref) {
  final db = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);

  return ({
    required String parkingId,
    required String parkingName,
    required int spaceNumber,
  }) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Debes iniciar sesión para reservar.');
    }

    final spaceDoc = db
        .collection('parkings')
        .doc(parkingId)
        .collection('spaces')
        .doc('$spaceNumber');

    // 0) chequeo rápido: que el espacio esté "free"
    final spaceSnap = await spaceDoc.get();
    if (spaceSnap.exists) {
      final data = spaceSnap.data() as Map<String, dynamic>? ?? {};
      if ((data['status'] ?? 'free') != 'free') {
        throw StateError('El espacio $spaceNumber ya está ocupado.');
      }
    }

    // 1) crea primero la reservation (las reglas del UPDATE consultan su existencia)
    final resRef = db.collection('reservations').doc();
    final now = DateTime.now();

    final reservation = Reservation(
      id: resRef.id,
      userId: uid,
      parkingId: parkingId,
      parkingName: parkingName,
      spaceNumber: spaceNumber,
      reservedAt: now, // <- Timestamp requerido por reglas
      state: 'active', // <- Requerido por tu regla del update de space
      pricePerHour: null,
      amount: null,
      durationMinutes: null,
    );

    await resRef.set(reservation.toMap());

    // 2) ahora sí, ocupamos el espacio.
    //    Esta operación cumple las condiciones de tu regla:
    //    - resource.status == "free"
    //    - request.status == "occupied"
    //    - request.currentReservationId == resRef.id
    //    - /reservations/{id} existe, userId == uid, state == "active"
    await db.runTransaction((tx) async {
      final snap = await tx.get(spaceDoc);
      final current = snap.data() as Map<String, dynamic>? ?? {};
      if ((current['status'] ?? 'free') != 'free') {
        throw StateError(
          'El espacio $spaceNumber se ocupó mientras reservabas.',
        );
      }

      tx.set(spaceDoc, {
        'status': 'occupied',
        'currentReservationId': resRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    return resRef.id;
  };
});
