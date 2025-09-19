import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emite la hora actual cada segundo para forzar rebuilds reactivos.
final nowTickerProvider = StreamProvider<DateTime>((ref) {
  // Stream.periodic ya maneja el cierre cuando no hay listeners.
  return Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  ).asBroadcastStream();
});
