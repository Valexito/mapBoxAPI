// lib/common/env/env.dart
class Env {
  /// Define este valor al correr o compilar:
  /// flutter run --dart-define=MAPBOX_TOKEN=pk....
  static const String mapboxToken = String.fromEnvironment('MAPBOX_TOKEN');
}
