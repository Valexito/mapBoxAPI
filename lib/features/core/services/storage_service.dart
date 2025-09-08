import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();
  final _storage = FirebaseStorage.instance;

  /// Sube una lista de archivos (rutas locales) a:
  /// parkings/{ownerId}/{parkingId}/photo_{i}.jpg
  /// Retorna las URLs de descarga.
  Future<List<String>> uploadParkingPhotos({
    required String ownerId,
    required String parkingId,
    required List<File> files,
  }) async {
    final results = <String>[];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final ref = _storage.ref().child(
        'parkings/$ownerId/$parkingId/photo_$i.jpg',
      );

      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await task.ref.getDownloadURL();
      results.add(url);
    }
    return results;
  }
}
