import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_api/features/core/providers/firebase_providers.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';

/// Stream de reservas del usuario autenticado
final userReservationsProvider = StreamProvider<List<Reservation>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final db = ref.watch(firestoreProvider);

  final uid = auth.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  final q = db
      .collection('reservations')
      .where('userId', isEqualTo: uid)
      .orderBy('reservedAt', descending: true);

  return q.snapshots().map(
    (s) => s.docs.map((d) => Reservation.fromMap(d.data())).toList(),
  );
});

/// Acción: crear una reserva
final createReservationProvider = Provider<Future<void> Function(Reservation)>((
  ref,
) {
  final db = ref.watch(firestoreProvider);
  return (Reservation r) async {
    await db.collection('reservations').add(r.toMap());
  };
});

/// (Opcional) cancelar o completar: agrega proveedores similares
