import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/features/reservations/services/geolocator.dart';

/// Ubicación actual (pide permisos, puede fallar).
/// Usa tu helper existente getCurrentLocation() que ya empleas en MapPickPage.
final currentLocationProvider = FutureProvider<LatLng>((ref) async {
  try {
    return await getCurrentLocation(); // puede lanzar
  } catch (_) {
    // Fallback al centro por defecto que ya usas en tu app
    return LatLng(14.834999, -91.518669);
  }
});