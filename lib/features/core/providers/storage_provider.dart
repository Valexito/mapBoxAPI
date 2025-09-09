// features/core/providers/storage_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>(
  (_) => StorageService.instance,
);

final uploadParkingPhotosProvider = Provider<
  Future<List<String>> Function({
    required String ownerId,
    required String parkingId,
    required List<File> files,
  })
>((ref) {
  final svc = ref.watch(storageServiceProvider);
  return ({required ownerId, required parkingId, required files}) {
    return svc.uploadParkingPhotos(
      ownerId: ownerId,
      parkingId: parkingId,
      files: files,
    );
  };
});
