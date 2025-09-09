// lib/features/owners/services/owner_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerService {
  OwnerService(this._db);
  final FirebaseFirestore _db;

  Future<void> submitOwnerApplication({
    required String uid,
    required String companyName,
    required String parkingName,
    required String email,
    required String phone,
    required String address,
    required int capacity,
    required String description,
    String status = 'approved', // 'pending' si vas a revisar manualmente
  }) async {
    await _db.collection('provider_applications').add({
      'uid': uid,
      'companyName': companyName,
      'parkingName': parkingName,
      'email': email,
      'phone': phone,
      'address': address,
      'capacity': capacity,
      'description': description,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
