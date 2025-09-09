// features/core/providers/favorites_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../reservations/models/parking.dart';
import '../services/favorite_service.dart';

// Inyectables base
final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);
final firebaseAuthProviderCore = Provider<FirebaseAuth>(
  (_) => FirebaseAuth.instance,
);

// Modelo visible para la UI (antes era _FavItem privado en la page)
class FavoriteItem {
  final String id;
  final String parkingId;
  final String name;
  final String ownerID;
  final int price;
  final int spaces;
  final double rating;
  final String? imageUrl;
  final String? coverUrl;
  final List<String> photos;
  final String? descripcion;
  final double lat;
  final double lng;

  const FavoriteItem({
    required this.id,
    required this.parkingId,
    required this.name,
    required this.ownerID,
    required this.price,
    required this.spaces,
    required this.rating,
    required this.lat,
    required this.lng,
    this.imageUrl,
    this.coverUrl,
    this.photos = const [],
    this.descripcion,
  });

  String? get heroImage =>
      photos.isNotEmpty ? photos.first : (coverUrl ?? imageUrl);

  Parking toParking() => Parking(
    id: parkingId,
    lat: lat,
    lng: lng,
    name: name,
    ownerID: ownerID,
    price: price,
    spaces: spaces,
    rating: rating,
    originalPrice: null,
    imageUrl: imageUrl,
    localImagePath: null,
    descripcion: descripcion,
    coverUrl: coverUrl,
    photos: photos,
  );

  factory FavoriteItem.fromMap(String id, Map<String, dynamic> m) {
    double _d(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    List<String> _ls(dynamic v) =>
        (v is List)
            ? v
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList()
            : const <String>[];

    return FavoriteItem(
      id: id,
      parkingId: (m['parkingId'] ?? '') as String,
      name: m['name'] ?? 'Parking',
      ownerID: m['ownerID'] ?? '',
      price: (m['price'] ?? 0) as int,
      spaces: (m['spaces'] ?? 0) as int,
      rating: _d(m['rating'] ?? 0),
      imageUrl: m['imageUrl'] as String?,
      coverUrl: m['coverUrl'] as String?,
      photos: _ls(m['photos']),
      descripcion: m['descripcion'] as String?,
      lat: _d(m['lat']),
      lng: _d(m['lng']),
    );
  }
}

// Servicio como provider (inyectable)
final favoriteServiceProvider = Provider<FavoriteService>(
  (_) => FavoriteService.instance,
);

// Stream<List<FavoriteItem>> del usuario actual
final favoritesStreamProvider = StreamProvider<List<FavoriteItem>>((ref) {
  final db = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProviderCore);
  final uid = auth.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  return db
      .collection('favorites')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map(
        (qs) =>
            qs.docs.map((d) => FavoriteItem.fromMap(d.id, d.data())).toList(),
      );
});

// Acciones (remove, toggle, etc.)
final removeFavoriteByDocIdProvider = Provider<Future<void> Function(String)>((
  ref,
) {
  final svc = ref.watch(favoriteServiceProvider);
  return (docId) => svc.removeByDocId(docId);
});

// Stream<bool> pero con family para cualquier parkingId
final isFavoriteStreamProvider = StreamProvider.family<bool, String>((
  ref,
  parkingId,
) {
  final svc = ref.watch(favoriteServiceProvider);
  return svc.isFavoriteStream(parkingId);
});

// Acción toggle (add/remove) optimista
final toggleFavoriteProvider =
    Provider<Future<void> Function({required bool toFav, required Parking p})>((
      ref,
    ) {
      final svc = ref.watch(favoriteServiceProvider);
      return ({required toFav, required Parking p}) async {
        if (toFav) {
          await svc.add(p);
        } else {
          await svc.removeByParkingId(p.id);
        }
      };
    });
