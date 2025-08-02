class Reservation {
  final String parkingId;
  final String parkingName;
  final int spaceNumber;
  final double lat;
  final double lng;
  final DateTime reservedAt;
  final String userId;

  Reservation({
    required this.parkingId,
    required this.parkingName,
    required this.spaceNumber,
    required this.lat,
    required this.lng,
    required this.reservedAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'parkingId': parkingId,
      'parkingName': parkingName,
      'spaceNumber': spaceNumber,
      'lat': lat,
      'lng': lng,
      'reservedAt': reservedAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      parkingId: map['parkingId'],
      parkingName: map['parkingName'],
      spaceNumber: map['spaceNumber'],
      lat: map['lat'],
      lng: map['lng'],
      reservedAt: DateTime.parse(map['reservedAt']),
      userId: map['userId'],
    );
  }
}
