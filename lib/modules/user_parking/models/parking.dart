class Parking {
  final double lat;
  final double lng;
  final String name;
  final String ownerID;
  final int price;
  final int spaces;
  final double? rating;
  final double? originalPrice;
  final String? imageUrl; // para Firebase (nube)
  final String? localImagePath; // para assets locales
  final String? descripcion;

  Parking({
    required this.lat,
    required this.lng,
    required this.name,
    required this.ownerID,
    required this.price,
    required this.spaces,
    this.originalPrice,
    this.rating,
    this.imageUrl,
    this.localImagePath,
    this.descripcion,
  });

  factory Parking.fromMap(Map<String, dynamic> data) {
    return Parking(
      lat: data['lat'],
      lng: data['lng'],
      name: data['name'],
      ownerID: data['ownerID'],
      price: data['price'],
      spaces: data['spaces'],
      imageUrl: data['imageUrl'],
      localImagePath: data['localImagePath'],
      originalPrice: data['originalPrice']?.toDouble(),
      rating: data['rating']?.toDouble(),
      descripcion: data['descripcion'], // ✅ ahora sí la traes de Firestore
    );
  }
}
