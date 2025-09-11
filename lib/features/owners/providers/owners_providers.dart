// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'package:mapbox_api/features/core/providers/firebase_providers.dart';

final createOwnerAndParkingProvider = Provider<
  Future<void> Function({
    required String uid,
    required String companyName,
    required String parkingName,
    required String email,
    required String phone,
    required String address,
    required int capacity,
    required String description,
    required double lat,
    required double lng,
    required List<XFile> images,
    required int price,
  })
>((ref) {
  final db = ref.watch(firestoreProvider);
  final storage = ref.watch(storageProvider);
  final uuid = const Uuid();

  return ({
    required String uid,
    required String companyName,
    required String parkingName,
    required String email,
    required String phone,
    required String address,
    required int capacity,
    required String description,
    required double lat,
    required double lng,
    required List<XFile> images,
    required int price,
  }) async {
    if (capacity <= 0) throw ArgumentError('La capacidad debe ser mayor a 0.');
    if (price < 0)
      throw ArgumentError('El precio por hora no puede ser negativo.');
    if (images.isEmpty) throw ArgumentError('Debes subir al menos una imagen.');

    // 1) Crea el doc primero (parkings PLURAL)
    final parkingRef = db.collection('parkings').doc();
    final parkingId = parkingRef.id;

    await parkingRef.set({
      'ownerID': uid,
      'name': parkingName,
      'lat': lat,
      'lng': lng,
      'spaces': capacity,
      'pricePerHour': price,
      'price': price, // compat
      'descripcion': description.isEmpty ? null : description,
      'address': address,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // (pequeño respiro para que Storage Rules lean el doc recién creado)
    await Future.delayed(const Duration(milliseconds: 200));

    // 2) Sube fotos a /parkings/{parkingId}/photos/{uuid}.jpg
    final List<String> photoUrls = [];
    try {
      for (final img in images) {
        final bytes = await img.readAsBytes();
        if (bytes.length > 10 * 1024 * 1024) {
          throw Exception('La imagen ${img.name} excede 10MB.');
        }
        final ext = _guessExt(img.name);
        final path = 'parkings/$parkingId/photos/${uuid.v4()}.$ext';
        print('[upload] uid=$uid path=$path size=${bytes.length}');

        final refSt = storage.ref(path);
        final metadata = SettableMetadata(contentType: _guessContentType(ext));
        await refSt.putData(Uint8List.fromList(bytes), metadata);
        final url = await refSt.getDownloadURL();
        photoUrls.add(url);
      }
    } catch (e) {
      // Limpia si algo falla al subir
      await parkingRef.delete();
      rethrow;
    }

    // 3) Actualiza doc con portada y galería
    await parkingRef.set({
      'coverUrl': photoUrls.first,
      'photos': photoUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 4) Siembra espacios /parkings/{id}/spaces/{1..N}
    final spacesColl = parkingRef.collection('spaces');
    final batch = db.batch();
    for (int i = 1; i <= capacity; i++) {
      batch.set(spacesColl.doc('$i'), {
        'status': 'free',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();

    // 5) Marca usuario como owner
    await db.collection('users').doc(uid).set({
      'companyName': companyName,
      'role': 'owner',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  };
});

String _guessExt(String name) {
  final n = name.toLowerCase();
  if (n.endsWith('.png')) return 'png';
  if (n.endsWith('.webp')) return 'webp';
  if (n.endsWith('.jpeg') || n.endsWith('.jpg')) return 'jpg';
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

final upsertParkingProvider = Provider<
  Future<String> Function({
    String? parkingId,
    required String name,
    required double lat,
    required double lng,
    required int spaces,
    required int pricePerHour,
    String? descripcion,
  })
>((ref) {
  final db = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);

  return ({
    String? parkingId,
    required String name,
    required double lat,
    required double lng,
    required int spaces,
    required int pricePerHour,
    String? descripcion,
  }) async {
    if (spaces <= 0) throw ArgumentError('N. de espacios debe ser > 0');
    if (pricePerHour < 0) throw ArgumentError('Precio por hora inválido');
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Debes iniciar sesión.');

    final docRef =
        (parkingId == null)
            ? db.collection('parkings').doc()
            : db.collection('parkings').doc(parkingId);

    final data = <String, dynamic>{
      'ownerID': uid,
      'name': name,
      'lat': lat,
      'lng': lng,
      'spaces': spaces,
      'pricePerHour': pricePerHour,
      'price': pricePerHour, // compat
      'descripcion':
          (descripcion == null || descripcion.isEmpty) ? null : descripcion,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (parkingId == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(data, SetOptions(merge: true));
    return docRef.id;
  };
});
