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
  final String? imageUrl; // nube
  final String? localImagePath; // assets
  final String? descripcion;

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
  });

  // ✅ Construye desde Firestore conservando el doc.id
  factory Parking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    double _d(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;

    return Parking(
      id: doc.id,
      lat: _d(data['lat']),
      lng: _d(data['lng']),
      name: data['name'] ?? '',
      ownerID: data['ownerID'] ?? '',
      price: (data['price'] ?? 0) as int,
      spaces: (data['spaces'] ?? 0) as int,
      rating: data['rating'] == null ? null : _d(data['rating']),
      originalPrice:
          data['originalPrice'] == null ? null : _d(data['originalPrice']),
      imageUrl: data['imageUrl'],
      localImagePath: data['localImagePath'],
      descripcion: data['descripcion'],
    );
  }

  // (opcional) si alguna vez creas desde un map externo, EXIGE id
  factory Parking.fromMap(Map<String, dynamic> data, {required String id}) {
    double _d(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;

    return Parking(
      id: id,
      lat: _d(data['lat']),
      lng: _d(data['lng']),
      name: data['name'] ?? '',
      ownerID: data['ownerID'] ?? '',
      price: (data['price'] ?? 0) as int,
      spaces: (data['spaces'] ?? 0) as int,
      rating: data['rating'] == null ? null : _d(data['rating']),
      originalPrice:
          data['originalPrice'] == null ? null : _d(data['originalPrice']),
      imageUrl: data['imageUrl'],
      localImagePath: data['localImagePath'],
      descripcion: data['descripcion'],
    );
  }
}
