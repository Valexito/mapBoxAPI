import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mapbox_api/features/core/providers/firebase_providers.dart';
import 'package:mapbox_api/features/reservations/models/parking_space.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';
import 'package:mapbox_api/features/reservations/models/parking.dart';

/// ----- Firestore base
final _dbProvider = firestoreProvider;

/// ----- Helpers de refs
DocumentReference<Map<String, dynamic>> _parkingDoc(
  FirebaseFirestore db,
  String id,
) => db.collection('parkings').doc(id);

DocumentReference<Map<String, dynamic>> _spaceDoc(
  FirebaseFirestore db,
  String parkingId,
  int spaceNumber,
) => _parkingDoc(db, parkingId).collection('spaces').doc('$spaceNumber');

DocumentReference<Map<String, dynamic>> _reservationDoc(
  FirebaseFirestore db,
  String id,
) => db.collection('reservations').doc(id);

/// ===================================================================
/// Streams base
/// ===================================================================

/// Cambios de autenticación (para reconstruir cuando el usuario entra/sale)
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// /parkings/{id}/spaces en **mapa** {numero -> ParkingSpace}
/// (evita el problema de orden lexicográfico "1,10,11,2,...")
final parkingSpacesProvider =
    StreamProvider.family<Map<int, ParkingSpace>, String>((ref, parkingId) {
      final db = ref.watch(_dbProvider);
      return _parkingDoc(db, parkingId).collection('spaces').snapshots().map((
        s,
      ) {
        final map = <int, ParkingSpace>{};
        for (final d in s.docs) {
          final n = int.tryParse(d.id);
          if (n == null) continue;
          map[n] = ParkingSpace.fromDoc(
            d as DocumentSnapshot<Map<String, dynamic>>,
          );
        }
        return map;
      });
    });

/// Parking por id (para fotos, nombre y pricePerHour)
final parkingByIdProvider = FutureProvider.family<Parking, String>((
  ref,
  id,
) async {
  final db = ref.watch(_dbProvider);
  final snap = await _parkingDoc(db, id).get();
  return Parking.fromDoc(snap as DocumentSnapshot<Map<String, dynamic>>);
});

/// ===================================================================
/// RESERVAS del usuario autenticado (reacciona a authStateChanges)
/// ===================================================================
final userReservationsProvider = StreamProvider<List<Reservation>>((ref) {
  final db = ref.watch(_dbProvider);

  // Este watch fuerza a que el provider se reconstruya cuando cambia el user.
  final userAsync = ref.watch(authStateProvider);

  return userAsync.when(
    // Sin usuario => stream vacío (evita PERMISSION_DENIED)
    data: (user) {
      if (user == null) return const Stream.empty();

      final q = db
          .collection('reservations')
          .where('userId', isEqualTo: user.uid)
          .orderBy('reservedAt', descending: true);

      return q.snapshots().map(
        (qs) =>
            qs.docs
                .map(
                  (d) => Reservation.fromDoc(
                    d as DocumentSnapshot<Map<String, dynamic>>,
                  ),
                )
                .toList(),
      );
    },
    // Mientras resuelve o hubo error leyendo auth => stream vacío
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

/// ===================================================================
/// Crear reserva + ocupar espacio (congelando pricePerHour del parking)
/// ===================================================================
final reserveSpaceProvider = Provider<
  Future<String> Function({
    required String parkingId,
    required String parkingName,
    required int spaceNumber,
  })
>((ref) {
  final db = ref.watch(_dbProvider);
  final auth = ref.watch(firebaseAuthProvider);

  return ({
    required String parkingId,
    required String parkingName,
    required int spaceNumber,
  }) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Debes iniciar sesión para reservar.');

    // Congelamos tarifa por hora vigente
    final parkingSnap = await _parkingDoc(db, parkingId).get();
    final p = Parking.fromDoc(
      parkingSnap as DocumentSnapshot<Map<String, dynamic>>,
    );

    final resRef = db.collection('reservations').doc();
    final now = DateTime.now();

    final r = Reservation(
      id: resRef.id,
      userId: uid,
      parkingId: parkingId,
      parkingName: parkingName,
      spaceNumber: spaceNumber,
      reservedAt: now,
      state: 'active',
      pricePerHour: p.pricePerHour,
    );

    await resRef.set(r.toMap());

    // Ocupar espacio de forma transaccional (cumple reglas)
    final spaceRef = _spaceDoc(db, parkingId, spaceNumber);
    await db.runTransaction((tx) async {
      final snap = await tx.get(spaceRef);
      final cur = snap.data() as Map<String, dynamic>? ?? {};
      if ((cur['status'] ?? 'free') != 'free') {
        throw StateError('El espacio $spaceNumber ya está ocupado.');
      }
      tx.set(spaceRef, {
        'status': 'occupied',
        'currentReservationId': resRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    return resRef.id;
  };
});

/// ===================================================================
/// Cancelar (marca reserva y libera el espacio si corresponde)
/// ===================================================================
final cancelReservationProvider =
    Provider<Future<void> Function({required Reservation reservation})>((ref) {
      final db = ref.watch(_dbProvider);
      final auth = ref.watch(firebaseAuthProvider);

      return ({required Reservation reservation}) async {
        final uid = auth.currentUser?.uid;
        if (uid == null) throw StateError('Debes iniciar sesión.');

        await _reservationDoc(db, reservation.id).update({
          'state': 'cancelled',
          'endedAt': FieldValue.serverTimestamp(),
        });

        final spaceRef = _spaceDoc(
          db,
          reservation.parkingId,
          reservation.spaceNumber,
        );
        await db.runTransaction((tx) async {
          final snap = await tx.get(spaceRef);
          final data = snap.data() as Map<String, dynamic>? ?? {};
          if ((data['status'] as String? ?? 'free') == 'occupied' &&
              data['currentReservationId'] == reservation.id) {
            tx.set(spaceRef, {
              'status': 'free',
              'currentReservationId': null,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        });
      };
    });

/// ===================================================================
/// Completar (marca, calcula importe y libera el espacio)
///  - Redondeo a bloques de 15min
/// ===================================================================
int _ceilDiv(int a, int b) => (a + b - 1) ~/ b;

({int minutes, int amountQ}) _bill({
  required DateTime start,
  required DateTime end,
  required int pricePerHour,
  int blockMinutes = 15,
}) {
  final totalMin = end.difference(start).inMinutes.clamp(0, 1000000);
  final blocks = _ceilDiv(totalMin, blockMinutes);
  final divisor = 60 ~/ blockMinutes; // p.ej. 4 para 15'
  final amount = _ceilDiv(pricePerHour * blocks, divisor);
  return (minutes: blocks * blockMinutes, amountQ: amount);
}

final completeReservationWithBillingProvider = Provider<
  Future<({int minutes, int amountQ})> Function({required Reservation r})
>((ref) {
  final db = ref.watch(_dbProvider);

  return ({required Reservation r}) async {
    final end = DateTime.now();

    int price = r.pricePerHour ?? 0;
    if (price <= 0) {
      final pSnap = await _parkingDoc(db, r.parkingId).get();
      price =
          Parking.fromDoc(
            pSnap as DocumentSnapshot<Map<String, dynamic>>,
          ).pricePerHour;
    }

    final billed = _bill(start: r.startedAt, end: end, pricePerHour: price);

    await _reservationDoc(db, r.id).update({
      'state': 'completed',
      'endedAt': Timestamp.fromDate(end),
      'durationMinutes': billed.minutes,
      'pricePerHour': price,
      'amount': billed.amountQ,
    });

    final spaceRef = _spaceDoc(db, r.parkingId, r.spaceNumber);
    await db.runTransaction((tx) async {
      final snap = await tx.get(spaceRef);
      final data = snap.data() as Map<String, dynamic>? ?? {};
      if ((data['status'] as String? ?? 'free') == 'occupied' &&
          data['currentReservationId'] == r.id) {
        tx.set(spaceRef, {
          'status': 'free',
          'currentReservationId': null,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });

    return billed;
  };
});
