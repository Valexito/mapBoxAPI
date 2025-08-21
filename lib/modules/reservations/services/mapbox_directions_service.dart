import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapboxDirectionsService {
  static const String _baseUrl =
      'https://api.mapbox.com/directions/v5/mapbox/driving';
  static const String _accessToken =
      'pk.eyJ1IjoiYWxleC1hcmd1ZXRhIiwiYSI6ImNtYm9veml5MjA0dDUyd3B3YXI1ZGxqeWsifQ.4WNWf4fqoNZeL5cByoS05A';

  Future<List<LatLng>> getRouteCoordinates({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url =
        '$_baseUrl/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&overview=full&access_token=$_accessToken';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final coords = jsonData['routes'][0]['geometry']['coordinates'];
      return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception('Error al obtener la ruta desde Mapbox Directions API');
    }
  }

  Future<String> getRouteDistance({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url =
        '$_baseUrl/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?access_token=$_accessToken';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final distanceMeters = jsonData['routes'][0]['distance'];
      final distanceKm = (distanceMeters / 1000).toStringAsFixed(1);
      return '$distanceKm km';
    } else {
      throw Exception('Error al obtener la distancia desde Mapbox');
    }
  }

  Future<String> getRouteDuration({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url =
        '$_baseUrl/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?access_token=$_accessToken';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final durationSeconds = jsonData['routes'][0]['duration'];
      final durationMin = (durationSeconds / 60).round();
      return '$durationMin min';
    } else {
      throw Exception('Error al obtener la duración desde Mapbox');
    }
  }
}
