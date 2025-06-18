import 'package:geolocator/geolocator.dart';

class LocationTracker {
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Solo emite si se mueve 5 metros
      ),
    );
  }
}
