// lib/features/reservations/components/reservations_details_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';
import 'package:mapbox_api/features/reservations/providers/reservations_providers.dart';

class ReservationDetailsSheet extends ConsumerWidget {
  const ReservationDetailsSheet({super.key, required this.reservation});
  final Reservation reservation;

  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pAsync = ref.watch(parkingByIdProvider(reservation.parkingId));
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;

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
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (e, _) => SizedBox(
                  height: 180,
                  child: Center(
                    child: MyText(
                      text: 'Error cargando parking: $e',
                      variant: MyTextVariant.bodyBold,
                    ),
                  ),
                ),
            data: (p) {
              final photos =
                  p.photos.isNotEmpty
                      ? p.photos
                      : (p.coverUrl != null ? [p.coverUrl!] : const <String>[]);
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
                      _StateChip(state: reservation.state),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder:
                          (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                photos.isEmpty
                                    ? Container(
                                      width: 160,
                                      color: const Color(0xFFF2F4F7),
                                    )
                                    : Image.network(
                                      photos[i],
                                      width: 180,
                                      height: 120,
                                      fit: BoxFit.cover,
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
                  if (reservation.amount != null)
                    _RowIconText(
                      icon: Icons.payments_outlined,
                      text: 'Q${reservation.amount}',
                    ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: MyButton(
                            text: 'Navegar',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                '/routeView',
                                arguments: {
                                  'destination': LatLng(p.lat, p.lng),
                                  'parkingName': p.name,
                                  'reservationId': reservation.id,
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: navyBottom,
                                width: 1.6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed:
                                reservation.state == 'active'
                                    ? () async {
                                      final cancel = ref.read(
                                        cancelReservationProvider,
                                      );
                                      await cancel(reservation: reservation);
                                      if (context.mounted)
                                        Navigator.pop(context);
                                    }
                                    : null,
                            child: const MyText(
                              text: 'Cancelar',
                              variant: MyTextVariant.normalBold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: navyBottom,
                                width: 1.6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed:
                                reservation.state == 'active'
                                    ? () async {
                                      // 1) pre-cálculo y confirmación visual
                                      final billed = _previewBill(
                                        start: reservation.startedAt,
                                        pricePerHour: frozenOrParkingPrice,
                                      );
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (ctx) => _ConfirmBillingDialog(
                                              start: reservation.startedAt,
                                              pricePerHour:
                                                  frozenOrParkingPrice,
                                              preview: billed,
                                            ),
                                      );
                                      if (ok != true) return;

                                      // 2) completar con cobro
                                      final complete = ref.read(
                                        completeReservationWithBillingProvider,
                                      );
                                      final result = await complete(
                                        r: reservation,
                                      );

                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Reserva completada. Total Q${result.amountQ}.',
                                          ),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }
                                    : null,
                            child: const MyText(
                              text: 'Completar',
                              variant: MyTextVariant.normalBold,
                              fontSize: 16,
                            ),
                          ),
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

  // pre-cálculo con "ahora"
  ({int minutes, int amountQ}) _previewBill({
    required DateTime start,
    required int pricePerHour,
  }) {
    final end = DateTime.now();
    final totalMin = end.difference(start).inMinutes.clamp(0, 1000000);
    final blocks = (totalMin + 14) ~/ 15; // ceil 15'
    final amount = ((pricePerHour * blocks) + 3) ~/ 4; // 4 bloques por hora
    return (minutes: blocks * 15, amountQ: amount);
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
    required this.start,
    required this.pricePerHour,
    required this.preview,
  });
  final DateTime start;
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
        const Icon(Icons.circle, size: 0), // keep layout
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
    final color = switch (state) {
      'active' => const Color(0xFF16A34A),
      'completed' => const Color(0xFF1B3A57),
      'cancelled' => const Color(0xFF9CA3AF),
      _ => const Color(0xFF9CA3AF),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(state),
    );
  }
}
