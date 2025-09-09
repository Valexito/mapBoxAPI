import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/foundation.dart';

/// Un único MapController compartido (mientras viva el árbol de widgets).
final mapControllerProvider = Provider<MapController>((ref) {
  final ctrl = MapController();
  // Si quisieras limpiar algo al salir:
  // ref.onDispose(() { /* nada por ahora */ });
  return ctrl;
});

/// Útil si quieres controlar el panel al tocar el mapa desde distintos widgets.
final mapOnTapProvider = StateProvider<VoidCallback?>((_) => null);
