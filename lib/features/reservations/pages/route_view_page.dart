// lib/features/reservations/pages/route_view_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/reservations/providers/location_providers.dart';
import 'package:mapbox_api/features/reservations/providers/map_providers.dart';
import 'package:mapbox_api/features/reservations/providers/directions_providers.dart';
import 'package:mapbox_api/features/reservations/components/route_bottom_info_card.dart';

class RouteViewPage extends ConsumerWidget {
  final LatLng destination;
  final String parkingName;
  const RouteViewPage({
    super.key,
    required this.destination,
    required this.parkingName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final map = ref.watch(mapControllerProvider);
    // 1) Obtener origen (con fallback si falla)
    final originAsync = ref.watch(currentLocationProvider);

    return originAsync.when(
      loading: () => const _ScaffoldLoader(),
      error:
          (e, _) => _ErrorScaffold(
            message:
                'No se pudo obtener tu ubicación.\n$e\n\nActiva GPS y permisos y reintenta.',
            onRetry: () => ref.refresh(currentLocationProvider),
          ),
      data: (origin) {
        // 2) Obtener ruta/distancia/tiempo con providers family
        final args = (origin: origin, destination: destination);
        final pointsAsync = ref.watch(routePointsProvider(args));
        final distanceAsync = ref.watch(routeDistanceProvider(args));
        final durationAsync = ref.watch(routeDurationProvider(args));

        return pointsAsync.when(
          loading: () => const _ScaffoldLoader(),
          error:
              (e, _) => _ErrorScaffold(
                message:
                    'No se pudo calcular la ruta.\n$e\n\nVerifica tu conexión o el MAPBOX_TOKEN.',
                onRetry: () {
                  ref.invalidate(routePointsProvider(args));
                  ref.invalidate(routeDistanceProvider(args));
                  ref.invalidate(routeDurationProvider(args));
                },
              ),
          data: (points) {
            final distance = distanceAsync.maybeWhen(
              data: (v) => v,
              orElse: () => '—',
            );
            final duration = durationAsync.maybeWhen(
              data: (v) => v,
              orElse: () => '—',
            );

            const navyBottom = Color(0xFF1B3A57);
            return Scaffold(
              backgroundColor: const Color(0xFFF2F4F7),
              body: Stack(
                children: [
                  FlutterMap(
                    mapController: map,
                    options: MapOptions(
                      initialCenter: origin,
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      // === Mapbox Streets (mismo look que tu 1a captura) ===
                      TileLayer(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/{id}/tiles/512/{z}/{x}/{y}@2x?access_token={accessToken}',
                        additionalOptions: const {
                          'accessToken': String.fromEnvironment('MAPBOX_TOKEN'),
                          'id': 'mapbox/streets-v12',
                        },
                        tileProvider: NetworkTileProvider(),
                      ),

                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: points,
                            strokeWidth: 6,
                            color: navyBottom,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          _pin(
                            origin,
                            const Icon(
                              Icons.my_location,
                              color: Color(0xFF16A34A),
                              size: 22,
                            ),
                          ),
                          _pin(
                            destination,
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _TopGradientHeader(
                    title: 'Ruta a',
                    subtitle: parkingName,
                    onBack: () => Navigator.pop(context),
                  ),
                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: _RouteSummaryCard(
                      distance: distance,
                      duration: duration,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 140,
                    child: _RecenterButton(
                      onTap: () => map.move(origin, map.camera.zoom),
                    ),
                  ),
                ],
              ),
              bottomSheet: RouteBottomInfoCard(
                parkingName: parkingName,
                distance: distance,
                duration: duration,
                onNavigate: () {},
                onCancelLater: () => Navigator.pop(context),
              ),
            );
          },
        );
      },
    );
  }

  Marker _pin(LatLng p, Widget icon) => Marker(
    point: p,
    width: 44,
    height: 44,
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Center(child: icon),
    ),
  );
}

class _ScaffoldLoader extends StatelessWidget {
  const _ScaffoldLoader();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Color(0xFFF2F4F7),
    body: Center(child: CircularProgressIndicator()),
  );
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorScaffold({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF2F4F7),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 42,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TopGradientHeader extends StatelessWidget {
  const _TopGradientHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [navyTop, navyBottom],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MyText(text: 'RUTA', variant: MyTextVariant.title),
                  const SizedBox(height: 2),
                  MyText(
                    text: '$title $subtitle',
                    variant: MyTextVariant.normal,
                    fontSize: 13,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({required this.distance, required this.duration});
  final String distance;
  final String duration;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.directions_walk, color: Color(0xFF1B3A57)),
            const SizedBox(width: 10),
            Expanded(
              child: MyText(
                text: 'Distancia: $distance',
                variant: MyTextVariant.body,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.timer_outlined, color: Color(0xFF1B3A57)),
            const SizedBox(width: 8),
            MyText(
              text: duration,
              variant: MyTextVariant.bodyBold,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.onTap});
  final VoidCallback onTap;
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [navyTop, navyBottom],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.my_location, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
