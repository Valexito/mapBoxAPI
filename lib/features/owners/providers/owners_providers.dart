// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'dart:async';
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
  final auth = ref.watch(firebaseAuthProvider);
  final uuid = const Uuid();

  Future<T> _retry<T>(
    Future<T> Function() op, {
    int max = 8,
    Duration firstDelay = const Duration(milliseconds: 300),
  }) async {
    var attempt = 0;
    var delay = firstDelay;
    late Object lastErr;
    while (attempt < max) {
      try {
        return await op();
      } catch (e) {
        lastErr = e;
        attempt++;
        if (attempt >= max) break;
        print('[upload retry] attempt=$attempt because=$e');
        await Future.delayed(delay);
        final nextMs = (delay.inMilliseconds * 1.8).clamp(300, 4000).toInt();
        delay = Duration(milliseconds: nextMs);
      }
    }
    throw lastErr;
  }

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

    final current = auth.currentUser;
    if (current == null || current.uid != uid) {
      throw StateError('Debes iniciar sesión correctamente.');
    }

    // 1) Crear parking
    final parkingRef = db.collection('parkings').doc();
    final parkingId = parkingRef.id;
    print('[create] parkingId=$parkingId uid=$uid');

    await parkingRef.set({
      'ownerID': uid,
      'name': parkingName,
      'lat': lat,
      'lng': lng,
      'spaces': capacity,
      'pricePerHour': price,
      'price': price,
      'descripcion': description.isEmpty ? null : description,
      'address': address,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await Future.delayed(const Duration(milliseconds: 350));
    final verify = await parkingRef.get();
    final data = verify.data() ?? {};
    print(
      '[verify] parking doc exists=${verify.exists} ownerID=${data['ownerID']}',
    );
    if (data['ownerID'] != uid) {
      throw StateError('ownerID no coincide.');
    }

    // 3) Subir fotos
    final List<String> photoUrls = [];
    try {
      for (final img in images) {
        final bytes = await img.readAsBytes();
        if (bytes.length > 10 * 1024 * 1024) {
          throw Exception('La imagen ${img.name} excede 10MB.');
        }
        final ext = _guessExt(img.name);
        final path = 'parkings/$parkingId/photos/${uuid.v4()}.$ext';
        final refSt = storage.ref(path);
        final metadata = SettableMetadata(contentType: _guessContentType(ext));

        print(
          '[storage] uploading path=$path uid=$uid bytes=${bytes.length} ct=${metadata.contentType}',
        );
        await _retry(() async {
          await refSt.putData(Uint8List.fromList(bytes), metadata);
          return true;
        });
        final url = await refSt.getDownloadURL();
        print('[storage] uploaded path=$path url=$url');
        photoUrls.add(url);
      }
    } catch (e) {
      print('[error] upload failed -> deleting $parkingId error=$e');
      try {
        await parkingRef.delete();
      } catch (_) {}
      rethrow;
    }

    await parkingRef.set({
      'coverUrl': photoUrls.first,
      'photos': photoUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    print('[update] coverUrl set and ${photoUrls.length} photos saved');

    // 5) Sembrar espacios
    final spacesColl = parkingRef.collection('spaces');
    final batch = db.batch();
    for (int i = 1; i <= capacity; i++) {
      batch.set(spacesColl.doc('$i'), {
        'status': 'free',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
    print('[seed] $capacity spaces created');

    // 6) Dejar perfil listo como owner (name/phone/role)
    final authName = current.displayName?.trim();
    final safeName =
        (authName != null && authName.isNotEmpty) ? authName : companyName;
    final safePhone = (phone.trim().isNotEmpty) ? phone.trim() : '+502 ...';

    await db.collection('users').doc(uid).set({
      'name': safeName,
      'phone': safePhone,
      'companyName': companyName,
      'role': 'owner',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    print('[user] role=owner set for uid=$uid');
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
