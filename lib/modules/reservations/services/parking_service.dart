import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parking.dart';

class ParkingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Parking>> getAllParkings() async {
    final snapshot = await _firestore.collection('parking').get();
    return snapshot.docs.map((d) => Parking.fromDoc(d)).toList();
  }

  Future<String> createParking({
    required String ownerID,
    required String name,
    required double lat,
    required double lng,
    required int spaces,
    String? descripcion,
    int price = 0,
    String? imageUrl,
    String? localImagePath,
  }) async {
    final ref = await _firestore.collection('parking').add({
      'ownerID': ownerID,
      'name': name,
      'lat': lat,
      'lng': lng,
      'spaces': spaces,
      'price': price,
      'descripcion': descripcion,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
