import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_api/features/reservations/services/parking_service.dart';

final parkingServiceProvider = Provider<ParkingService>((ref) {
  return ParkingService();
});
