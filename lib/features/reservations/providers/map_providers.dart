import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Un solo MapController compartido entre pantallas (con keepAlive)
final mapControllerProvider = Provider<MapController>((ref) {
  final ctrl = MapController();
  ref.keepAlive(); // evita descarte agresivo cuando cambias de pantalla
  return ctrl;
});
