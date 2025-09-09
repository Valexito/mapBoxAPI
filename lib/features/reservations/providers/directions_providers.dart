import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/features/reservations/services/mapbox_directions_service.dart';

/// DI del servicio. Toma el token del entorno y si está vacío,
/// el service hará fallback automático a OSRM.
final directionsServiceProvider = Provider<MapboxDirectionsService>((ref) {
  const token = String.fromEnvironment('MAPBOX_TOKEN', defaultValue: '');
  return MapboxDirectionsService(mapboxAccessToken: token, profile: 'driving');
});

typedef RouteArgs = ({LatLng origin, LatLng destination});

final routePointsProvider = FutureProvider.autoDispose
    .family<List<LatLng>, RouteArgs>((ref, args) async {
      ref.keepAlive();
      final svc = ref.read(directionsServiceProvider);
      return svc.getRoutePoints(args.origin, args.destination);
    });

final routeDistanceProvider = FutureProvider.autoDispose
    .family<String, RouteArgs>((ref, args) async {
      ref.keepAlive();
      final svc = ref.read(directionsServiceProvider);
      final meters = await svc.getDistanceMeters(args.origin, args.destination);
      if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
      return '${(meters / 1000).toStringAsFixed(1)} km';
    });

final routeDurationProvider = FutureProvider.autoDispose
    .family<String, RouteArgs>((ref, args) async {
      ref.keepAlive();
      final svc = ref.read(directionsServiceProvider);
      final seconds = await svc.getDurationSeconds(
        args.origin,
        args.destination,
      );
      final minutes = (seconds / 60).round();
      return '$minutes min';
    });
