import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';
import 'package:mapbox_api/features/reservations/providers/reservations_providers.dart';

class ReservationDetailsSheet extends ConsumerWidget {
  const ReservationDetailsSheet({super.key, required this.reservation});

  final Reservation reservation;

  static const navyBottom = Color(0xFF1B3A57);

  String get _stateEs {
    switch (reservation.state.toLowerCase()) {
      case 'active':
        return 'Activo';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return reservation.state;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pAsync = ref.watch(parkingByIdProvider(reservation.parkingId));
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;
    final isActive = reservation.state.toLowerCase() == 'active';
    final isCompleted = reservation.state.toLowerCase() == 'completed';

    return SafeArea(
      top: false,
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomSafe),
          child: pAsync.when(
            loading:
                () => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (e, _) => SizedBox(
                  height: 220,
                  child: Center(
                    child: MyText(
                      text: 'Error cargando parking: $e',
                      variant: MyTextVariant.bodyBold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            data: (p) {
              final photos =
                  <String>[
                    ...p.photos
                        .where((e) => e.trim().isNotEmpty)
                        .map((e) => e.trim()),
                    if ((p.coverUrl ?? '').trim().isNotEmpty)
                      p.coverUrl!.trim(),
                    if ((p.imageUrl ?? '').trim().isNotEmpty)
                      p.imageUrl!.trim(),
                  ].toSet().toList();

              final frozenOrParkingPrice =
                  reservation.pricePerHour ?? p.pricePerHour;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.local_parking, color: navyBottom),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MyText(
                          text: p.name,
                          variant: MyTextVariant.title,
                          fontSize: 18,
                        ),
                      ),
                      _StateChip(state: _stateEs),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 120,
                    child:
                        photos.isEmpty
                            ? Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: photos.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 8),
                              itemBuilder:
                                  (_, i) => ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      photos[i],
                                      width: 180,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            width: 180,
                                            color: const Color(0xFFF2F4F7),
                                            child: const Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              color: Colors.grey,
                                            ),
                                          ),
                                    ),
                                  ),
                            ),
                  ),

                  const SizedBox(height: 12),
                  _RowIconText(
                    icon: Icons.confirmation_number_outlined,
                    text: 'Espacio ${reservation.spaceNumber}',
                  ),
                  const SizedBox(height: 6),
                  _RowIconText(
                    icon: Icons.access_time,
                    text: _fmtRange(reservation.startedAt, reservation.endedAt),
                  ),
                  const SizedBox(height: 6),
                  _RowIconText(
                    icon: Icons.payments_outlined,
                    text:
                        reservation.amount != null
                            ? 'Q${reservation.amount}'
                            : 'Q$frozenOrParkingPrice/h',
                  ),
                  if (isCompleted && reservation.durationMinutes != null) ...[
                    const SizedBox(height: 6),
                    _RowIconText(
                      icon: Icons.timer_outlined,
                      text: 'Duración: ${reservation.durationMinutes} min',
                    ),
                  ],
                  const SizedBox(height: 16),

                  if (isActive)
                    Row(
                      children: [
                        Expanded(
                          child: MyButton(
                            text: 'Cancelar',
                            onTap: () async {
                              final cancel = ref.read(
                                cancelReservationProvider,
                              );
                              await cancel(reservation: reservation);
                              if (context.mounted) Navigator.pop(context);
                            },
                            margin: EdgeInsets.zero,
                            height: 48,
                            fontSize: 14,
                            variant: MyButtonVariant.soft,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyButton(
                            text: 'Completar',
                            onTap: () async {
                              final billed = _previewBill(
                                start: reservation.startedAt,
                                pricePerHour: frozenOrParkingPrice,
                              );

                              final ok = await showDialog<bool>(
                                context: context,
                                builder:
                                    (_) => _ConfirmBillingDialog(
                                      pricePerHour: frozenOrParkingPrice,
                                      preview: billed,
                                    ),
                              );

                              if (ok != true) return;

                              final complete = ref.read(
                                completeReservationWithBillingProvider,
                              );
                              final result = await complete(r: reservation);

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Reserva completada. Total Q${result.amountQ}.',
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            },
                            margin: EdgeInsets.zero,
                            height: 48,
                            fontSize: 14,
                            variant: MyButtonVariant.filled,
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  ({int minutes, int amountQ}) _previewBill({
    required DateTime start,
    required int pricePerHour,
  }) {
    final end = DateTime.now();
    final totalMin = end.difference(start).inMinutes.clamp(0, 1000000);
    final blocks = (totalMin + 14) ~/ 15;
    final amount = ((pricePerHour * blocks) + 3) ~/ 4;
    return (minutes: blocks * 15, amountQ: amount);
  }

  Future<void> _openNavigationChooser(
    BuildContext context, {
    required LatLng destination,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          child: Material(
            color: const Color(0xFFF8FAFC),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.borderSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const MyText(
                    text: 'Abrir navegación',
                    variant: MyTextVariant.title,
                    customColor: AppColors.headerBottom,
                    fontSize: 20,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const MyText(
                    text: 'Selecciona la app con la que deseas navegar.',
                    variant: MyTextVariant.bodyMuted,
                    fontSize: 12,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  _NavAppTile(
                    icon: Icons.map_rounded,
                    title: 'Google Maps',
                    subtitle: 'Abrir ruta en Google Maps',
                    onTap: () async {
                      Navigator.pop(context);
                      await _openGoogleMaps(destination);
                    },
                  ),
                  const SizedBox(height: 10),
                  _NavAppTile(
                    icon: Icons.navigation_rounded,
                    title: 'Waze',
                    subtitle: 'Abrir ruta en Waze',
                    onTap: () async {
                      Navigator.pop(context);
                      await _openWaze(destination);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openGoogleMaps(LatLng destination) async {
    final lat = destination.latitude;
    final lng = destination.longitude;

    final googleMapsApp = Uri.parse(
      'comgooglemaps://?daddr=$lat,$lng&directionsmode=driving',
    );
    final googleMapsWeb = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    if (await canLaunchUrl(googleMapsApp)) {
      await launchUrl(googleMapsApp, mode: LaunchMode.externalApplication);
      return;
    }

    await launchUrl(googleMapsWeb, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWaze(LatLng destination) async {
    final lat = destination.latitude;
    final lng = destination.longitude;

    final wazeUri = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');
    final wazeWeb = Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');

    if (await canLaunchUrl(wazeUri)) {
      await launchUrl(wazeUri, mode: LaunchMode.externalApplication);
      return;
    }

    await launchUrl(wazeWeb, mode: LaunchMode.externalApplication);
  }

  static String _fmtRange(DateTime start, DateTime? end) {
    String two(int n) => n.toString().padLeft(2, '0');

    String hm(DateTime d) {
      final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final am = d.hour < 12 ? 'AM' : 'PM';
      return '$h:${two(d.minute)} $am';
    }

    final day = '${two(start.day)}/${two(start.month)}/${start.year}';
    final s = hm(start);
    final e = end == null ? '—' : hm(end);
    return '$day  $s — $e';
  }
}

class _ConfirmBillingDialog extends StatelessWidget {
  const _ConfirmBillingDialog({
    required this.pricePerHour,
    required this.preview,
  });

  final int pricePerHour;
  final ({int minutes, int amountQ}) preview;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1B3A57);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MyText(
              text: 'COMPLETAR RESERVA',
              variant: MyTextVariant.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            MyText(
              text:
                  'Tarifa: Q$pricePerHour / hora\n'
                  'Tiempo: ${preview.minutes} min\n'
                  'Total a pagar: Q${preview.amountQ}\n\n¿Confirmar cobro y finalizar?',
              variant: MyTextVariant.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 42,
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: navy, width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const MyText(
                      text: 'Volver',
                      variant: MyTextVariant.normalBold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 42,
                  width: 160,
                  child: MyButton(
                    text: 'Confirmar cobro',
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RowIconText extends StatelessWidget {
  const _RowIconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 6),
        Expanded(
          child: MyText(text: text, variant: MyTextVariant.body, fontSize: 14),
        ),
      ],
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.state});

  final String state;

  @override
  Widget build(BuildContext context) {
    final normalized = state.toLowerCase();

    Color color;
    if (normalized == 'activo') {
      color = const Color(0xFF16A34A);
    } else if (normalized == 'completado') {
      color = const Color(0xFF1B3A57);
    } else {
      color = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: MyText(
        text: state,
        variant: MyTextVariant.bodyBold,
        fontSize: 12,
        customColor: color,
      ),
    );
  }
}

class _NavAppTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavAppTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.iconCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.headerBottom, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: title,
                      variant: MyTextVariant.bodyBold,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 2),
                    MyText(
                      text: subtitle,
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
