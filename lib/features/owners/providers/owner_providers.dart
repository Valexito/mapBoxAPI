// lib/features/owners/providers/owner_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_api/features/core/providers/firebase_providers.dart';
import 'package:mapbox_api/features/owners/services/owner_service.dart';
import 'package:mapbox_api/features/reservations/providers/parking_service_providers.dart';
import 'package:mapbox_api/features/reservations/services/parking_service.dart';
import 'package:image_picker/image_picker.dart';

final ownerServiceProvider = Provider<OwnerService>((ref) {
  final db = ref.watch(firestoreProvider);
  return OwnerService(db);
});

/// Exponemos una acción orquestada que:
/// 1) guarda la aplicación del owner
/// 2) crea el parking con imágenes
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
    required List<XFile> images, // List<XFile>
    int price,
  })
>((ref) {
  final ownerSvc = ref.read(ownerServiceProvider);
  final ParkingService parkingSvc = ref.read(parkingServiceProvider);

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
    int price = 0,
  }) async {
    await ownerSvc.submitOwnerApplication(
      uid: uid,
      companyName: companyName,
      parkingName: parkingName,
      email: email,
      phone: phone,
      address: address,
      capacity: capacity,
      description: description,
    );

    await parkingSvc.createParkingWithImages(
      ownerID: uid,
      name: parkingName,
      lat: lat,
      lng: lng,
      spaces: capacity,
      descripcion: description,
      price: price,
      images: images, // XFile[]
    );
  };
});
