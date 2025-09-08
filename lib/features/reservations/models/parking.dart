// lib/modules/reservations/models/parking.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Parking {
  final String id;
  final double lat;
  final double lng;
  final String name;
  final String ownerID;
  final int price;
  final int spaces;
  final double? rating;
  final double? originalPrice;
  final String? imageUrl; // legacy
  final String? localImagePath; // assets
  final String? descripcion;

  // 👇 nuevos
  final String? coverUrl; // portada
  final List<String> photos; // galería

  Parking({
    required this.id,
    required this.lat,
    required this.lng,
    required this.name,
    required this.ownerID,
    required this.price,
    required this.spaces,
    this.rating,
    this.originalPrice,
    this.imageUrl,
    this.localImagePath,
    this.descripcion,
    this.coverUrl,
    this.photos = const [],
  });

  factory Parking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    double _d(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    List<String> _ls(dynamic v) =>
        (v is List)
            ? v
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList()
            : const <String>[];

    return Parking(
      id: doc.id,
      lat: _d(data['lat']),
      lng: _d(data['lng']),
      name: data['name'] ?? '',
      ownerID: data['ownerID'] ?? '',
      price: (data['price'] ?? 0) as int,
      spaces: (data['spaces'] ?? 0) as int,
      rating:
          (data['rating'] is num) ? (data['rating'] as num).toDouble() : null,
      originalPrice:
          (data['originalPrice'] is num)
              ? (data['originalPrice'] as num).toDouble()
              : null,
      imageUrl: data['imageUrl'],
      localImagePath: data['localImagePath'],
      descripcion: data['descripcion'],
      coverUrl: data['coverUrl'],
      photos: _ls(data['photos']),
    );
  }

  factory Parking.fromMap(Map<String, dynamic> data, {required String id}) {
    double _d(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    List<String> _ls(dynamic v) =>
        (v is List)
            ? v
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList()
            : const <String>[];

    return Parking(
      id: id,
      lat: _d(data['lat']),
      lng: _d(data['lng']),
      name: data['name'] ?? '',
      ownerID: data['ownerID'] ?? '',
      price: (data['price'] ?? 0) as int,
      spaces: (data['spaces'] ?? 0) as int,
      rating:
          (data['rating'] is num) ? (data['rating'] as num).toDouble() : null,
      originalPrice:
          (data['originalPrice'] is num)
              ? (data['originalPrice'] as num).toDouble()
              : null,
      imageUrl: data['imageUrl'],
      localImagePath: data['localImagePath'],
      descripcion: data['descripcion'],
      coverUrl: data['coverUrl'],
      photos: _ls(data['photos']),
    );
  }
}
