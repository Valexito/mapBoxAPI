class Parqueo {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final int price;
  final int spaces;
  final String ownerId;

  Parqueo({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.price,
    required this.spaces,
    required this.ownerId,
  });

  factory Parqueo.fromMap(String id, Map<String, dynamic> data) {
    return Parqueo(
      id: id,
      name: data['name'] ?? '',
      lat: data['lat']?.toDouble() ?? 0.0,
      lng: data['lng']?.toDouble() ?? 0.0,
      price: data['price'] ?? 0,
      spaces: data['spaces'] ?? 0,
      ownerId: data['ownerId'] ?? '',
    );
  }
}
