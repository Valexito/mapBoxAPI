import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mapbox_api/features/core/providers/firebase_providers.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';
import 'package:mapbox_api/features/reservations/models/parking_space.dart';

/// true = cobra por hora completa (ceil)
/// false = prorratea por minuto usando la tarifa/hora guardada en la reserva
const bool kRoundUpToFullHour = false;

/// Tarifa por hora del parking (stream). Fallback a 'price' si no hay 'pricePerHour'.
final parkingHourlyPriceProvider = StreamProvider.family<int, String>((
  ref,
  parkingId,
) {
  final db = ref.watch(firestoreProvider);
  return db.doc('parking/$parkingId').snapshots().map((snap) {
    final data = snap.data();
    if (data == null) return 0;
    final n = (data['pricePerHour'] ?? data['price'] ?? 0) as num;
    return n.toInt();
  });
});

/// Espacios por parking (tiempo real)
final parkingSpacesProvider = StreamProvider.family<List<ParkingSpace>, String>(
  (ref, parkingId) {
    final db = ref.watch(firestoreProvider);
    return db
        .collection('parkings')
        .doc(parkingId)
        .collection('spaces')
        .orderBy(FieldPath.documentId)
        .snapshots()
        .map((qs) => qs.docs.map((d) => ParkingSpace.fromDoc(d)).toList());
  },
);

/// Reservar espacio (transacción)
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
    final uid = auth.currentUser!.uid;

    return await db.runTransaction<String>((tx) async {
      // 1) tarifa/hora del parking
      final parkingRef = db.doc('parking/$parkingId');
      final parkingSnap = await tx.get(parkingRef);
      final Map<String, dynamic> pdata =
          (parkingSnap.data() as Map<String, dynamic>?) ?? {};
      final pricePerHour =
          ((pdata['pricePerHour'] ?? pdata['price'] ?? 0) as num).toInt();

      // 2) espacio libre?
      final spaceRef = db.doc('parkings/$parkingId/spaces/$spaceNumber');
      final spaceSnap = await tx.get(spaceRef);
      final status = (spaceSnap.data()?['status'] as String?) ?? 'free';
      if (status != 'free') {
        throw StateError('Ese espacio ya no está disponible.');
      }

      // 3) crear reserva (queda "active")
      final resRef = db.collection('reservations').doc();
      tx.set(resRef, {
        'parkingId': parkingId,
        'parkingName': parkingName,
        'spaceNumber': spaceNumber,
        'userId': uid,
        'state': 'active',
        'startedAt': FieldValue.serverTimestamp(),
        'pricePerHour': pricePerHour,
      });

      // 4) ocupar espacio
      tx.update(spaceRef, {
        'status': 'occupied',
        'currentReservationId': resRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return resRef.id;
    });
  };
});

/// Finalizar reserva (transacción)
final endReservationProvider = Provider<Future<void> Function(String)>((ref) {
  final db = ref.watch(firestoreProvider);

  int _calcAmount(int minutes, int pricePerHour) {
    if (kRoundUpToFullHour) {
      final hours = (minutes / 60).ceil();
      return hours * pricePerHour;
    }
    // prorrateo por minuto (redondeo hacia arriba)
    return ((minutes * pricePerHour) / 60).ceil();
  }

  return (String reservationId) async {
    await db.runTransaction((tx) async {
      final resRef = db.collection('reservations').doc(reservationId);
      final snap = await tx.get(resRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;

      final parkingId = data['parkingId'] as String;
      final spaceNum = (data['spaceNumber'] as num).toInt();
      final started = (data['startedAt'] as Timestamp).toDate();
      final pph = (data['pricePerHour'] as num?)?.toInt() ?? 0;

      final minutes = DateTime.now().difference(started).inMinutes;
      final amount = _calcAmount(minutes, pph);

      tx.update(resRef, {
        'state': 'completed',
        'endedAt': FieldValue.serverTimestamp(),
        'durationMinutes': minutes,
        'amount': amount,
      });

      final spaceRef = db.doc('parkings/$parkingId/spaces/$spaceNum');
      tx.update(spaceRef, {
        'status': 'free',
        'currentReservationId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  };
});

/// Reservas del usuario autenticado
final userReservationsProvider = StreamProvider<List<Reservation>>((ref) {
  final db = ref.watch(firestoreProvider);
  final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  if (uid == null) return const Stream<List<Reservation>>.empty();

  return db
      .collection('reservations')
      .where('userId', isEqualTo: uid)
      .orderBy('startedAt', descending: true)
      .snapshots()
      .map((qs) => qs.docs.map((d) => Reservation.fromDoc(d)).toList());
});

/// Filtro en memoria por estado
final userReservationsByStatusProvider =
    Provider<List<Reservation> Function(String)>((ref) {
      final all = ref
          .watch(userReservationsProvider)
          .maybeWhen(data: (v) => v, orElse: () => <Reservation>[]);
      return (state) => all.where((r) => r.state == state).toList();
    });

/// Cronómetro (desde startedAt) – útil para UI en reservas activas
final reservationTickerProvider = StreamProvider.family<Duration, String>((
  ref,
  id,
) {
  final db = ref.watch(firestoreProvider);
  final controller = StreamController<Duration>();
  Timestamp? started;

  final sub = db.collection('reservations').doc(id).snapshots().listen((snap) {
    started = snap.data()?['startedAt'] as Timestamp?;
    if (started != null) {
      controller.add(DateTime.now().difference(started!.toDate()));
    }
  });

  final tick = Stream.periodic(const Duration(seconds: 1)).listen((_) {
    if (started != null) {
      controller.add(DateTime.now().difference(started!.toDate()));
    }
  });

  ref.onDispose(() {
    sub.cancel();
    tick.cancel();
    controller.close();
  });

  return controller.stream;
});
