// parking_service.dart
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/parking.dart';

class ParkingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // ----- Reads -----
  Future<List<Parking>> getAllParkings() async {
    final snapshot = await _firestore.collection('parking').get();
    return snapshot.docs.map((d) => Parking.fromDoc(d)).toList();
  }

  // ----- Create (no photos) - your original method -----
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
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // ----- Create with photo uploads (≥3 images recommended) -----
  Future<String> createParkingWithImages({
    required String ownerID,
    required String name,
    required double lat,
    required double lng,
    required int spaces,
    required List<XFile> images, // from image_picker
    String? descripcion,
    int price = 0,
  }) async {
    if (images.isEmpty || images.length < 3) {
      throw Exception('Please provide at least 3 images.');
    }

    // Create doc ID first so Storage path can include {parkingId}
    final docRef = _firestore.collection('parking').doc();
    final parkingId = docRef.id;

    // Upload images to Storage and collect URLs
    final urls = await _uploadImages(
      ownerID: ownerID,
      parkingId: parkingId,
      images: images,
    );

    // Create Firestore doc (rules require ownerID == uid)
    await docRef.set({
      'ownerID': ownerID,
      'name': name,
      'lat': lat,
      'lng': lng,
      'spaces': spaces,
      'price': price,
      'descripcion': descripcion,
      'photos': urls, // <— array of download URLs
      'coverUrl': urls.first, // <— main image
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return parkingId;
  }

  // ----- Add more images later -----
  Future<List<String>> addParkingImages({
    required String ownerID,
    required String parkingId,
    required List<XFile> images,
  }) async {
    final urls = await _uploadImages(
      ownerID: ownerID,
      parkingId: parkingId,
      images: images,
    );

    await _firestore.collection('parking').doc(parkingId).update({
      'photos': FieldValue.arrayUnion(urls),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return urls;
  }

  // ===== Helpers =====
  Future<List<String>> _uploadImages({
    required String ownerID,
    required String parkingId,
    required List<XFile> images,
  }) async {
    final urls = <String>[];

    for (final img in images) {
      final bytes = await img.readAsBytes();
      final ext = _guessExt(img.name);
      final contentType = _guessContentType(ext);

      // Your Storage rules cap images to 5 MB and require image/* contentType
      if (bytes.length > 5 * 1024 * 1024) {
        throw Exception('Image ${img.name} exceeds 5 MB.');
      }

      final fileName = '${_uuid.v4()}.$ext';
      final ref = _storage.ref('parkings/$ownerID/$parkingId/$fileName');

      final metadata = SettableMetadata(contentType: contentType);
      await ref.putData(Uint8List.fromList(bytes), metadata);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  String _guessExt(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return 'png';
    if (n.endsWith('.webp')) return 'webp';
    if (n.endsWith('.jpeg')) return 'jpg';
    return 'jpg';
  }

  String _guessContentType(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
