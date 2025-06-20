import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

Future<LatLng> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Verifica si el GPS está activo
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('La ubicación está desactivada');
  }

  // Verifica permisos
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Permiso de ubicación denegado');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Permisos de ubicación permanentemente denegados');
  }

  // Obtiene la ubicación actual
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  return LatLng(position.latitude, position.longitude);
}
