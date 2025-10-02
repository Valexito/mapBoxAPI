// lib/common/env/env.dart
class Env {
  /// Define este valor en tiempo de build: --dart-define=MAPBOX_TOKEN=pk...
  static const mapboxToken = String.fromEnvironment('MAPBOX_TOKEN');
}
