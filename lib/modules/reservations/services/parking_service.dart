import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parking.dart';

class ParkingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Parking>> getAllParkings() async {
    final snapshot = await _firestore.collection('parking').get();
    return snapshot.docs
        .map((doc) => Parking.fromDoc(doc))
        .toList(); // ✅ usa fromDoc
  }
}
