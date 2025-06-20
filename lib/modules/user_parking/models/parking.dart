class Parking {
  final double lat;
  final double lng;
  final String name;
  final String ownerID;
  final int price;
  final int spaces;

  Parking({
    required this.lat,
    required this.lng,
    required this.name,
    required this.ownerID,
    required this.price,
    required this.spaces,
  });

  factory Parking.fromMap(Map<String, dynamic> data) {
    return Parking(
      lat: data['lat'],
      lng: data['lng'],
      name: data['name'],
      ownerID: data['ownerID'],
      price: data['price'],
      spaces: data['spaces'],
    );
  }
}
