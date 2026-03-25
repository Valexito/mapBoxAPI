import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/reservations/components/reservations_details_sheet.dart';
import 'package:mapbox_api/features/reservations/models/parking.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';
import 'package:mapbox_api/features/reservations/providers/reservations_providers.dart';

class ReservationCard extends ConsumerWidget {
  const ReservationCard({super.key, required this.reservation});

  final Reservation reservation;

  static const navyBottom = Color(0xFF1B3A57);

  String get _status =>
      reservation.state.trim().isEmpty ? 'active' : reservation.state.trim();

  String get _statusEs {
    switch (_status.toLowerCase()) {
      case 'active':
        return 'Activo';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return _status;
    }
  }

  String get _priceText {
    if (reservation.amount != null) return 'Q${reservation.amount}';
    if (reservation.pricePerHour != null)
      return 'Q${reservation.pricePerHour}/h';
    return 'Q—';
  }

  String get _dateText {
    final dt = reservation.startedAt;
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    final day = dt.day.toString().padLeft(2, '0');
    final mon = months[(dt.month - 1).clamp(0, 11)];
    final year = dt.year;

    return '$day $mon $year';
  }

  String get _timeText {
    final dt = reservation.startedAt;
    final hh = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final am = dt.hour < 12 ? 'AM' : 'PM';
    return '$hh:$mm $am';
  }

  String _fmtRange(DateTime start, DateTime? end) {
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

  String? _parkingImageFrom(Parking parking) {
    final photos =
        parking.photos
            .where((e) => e.trim().isNotEmpty)
            .map((e) => e.trim())
            .toList();

    if (photos.isNotEmpty) return photos.first;

    final cover = (parking.coverUrl ?? '').trim();
    if (cover.isNotEmpty) return cover;

    final image = (parking.imageUrl ?? '').trim();
    if (image.isNotEmpty) return image;

    return null;
  }

  void _openDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReservationDetailsSheet(reservation: reservation),
    );
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

  Future<void> _openCompletedSummary(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder:
          (_) => _CompletedSummaryDialog(
            reservation: reservation,
            dateText: _dateText,
            timeRangeText: _fmtRange(
              reservation.startedAt,
              reservation.endedAt,
            ),
            priceText: _priceText,
          ),
    );
  }

  Future<void> _openCancelledReview(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder:
          (_) => _CancelledReviewDialog(
            reservation: reservation,
            dateText: _dateText,
            timeRangeText: _fmtRange(
              reservation.startedAt,
              reservation.endedAt,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalized = _status.toLowerCase();
    final isActive = normalized == 'active';
    final isCompleted = normalized == 'completed';
    final isCancelled = normalized == 'cancelled';

    final parkingAsync = ref.watch(parkingByIdProvider(reservation.parkingId));

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _openDetails(context),
      child: Material(
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  parkingAsync.when(
                    loading: () => const _ReservationImage(imageUrl: null),
                    error: (_, __) => const _ReservationImage(imageUrl: null),
                    data:
                        (parking) => _ReservationImage(
                          imageUrl: _parkingImageFrom(parking),
                        ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MyText(
                                text: reservation.parkingName,
                                variant: MyTextVariant.bodyBold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusPill(status: _statusEs),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _InfoLine(
                          icon: Icons.calendar_month_outlined,
                          text: _dateText,
                        ),
                        const SizedBox(height: 6),
                        _InfoLine(
                          icon: Icons.access_time_rounded,
                          text: _timeText,
                        ),
                        const SizedBox(height: 6),
                        _InfoLine(
                          icon: Icons.local_parking_outlined,
                          text: 'Espacio ${reservation.spaceNumber}',
                        ),
                        const SizedBox(height: 6),
                        _InfoLine(
                          icon: Icons.payments_outlined,
                          text: _priceText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: const Color(0xFFE9EEF5)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      text: 'Ver detalles',
                      onTap: () => _openDetails(context),
                      margin: EdgeInsets.zero,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: parkingAsync.when(
                        loading:
                            () => const _DisabledSecondaryButton(
                              text: 'Navegar',
                              icon: Icons.navigation_outlined,
                            ),
                        error:
                            (_, __) => const _DisabledSecondaryButton(
                              text: 'Navegar',
                              icon: Icons.navigation_outlined,
                            ),
                        data:
                            (parking) => _SecondaryActionButton(
                              text: 'Navegar',
                              icon: Icons.navigation_outlined,
                              onTap:
                                  () => _openNavigationChooser(
                                    context,
                                    destination: LatLng(
                                      parking.lat,
                                      parking.lng,
                                    ),
                                  ),
                            ),
                      ),
                    ),
                  ],
                  if (isCompleted) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SecondaryActionButton(
                        text: 'Resumen',
                        icon: Icons.receipt_long_outlined,
                        onTap: () => _openCompletedSummary(context),
                      ),
                    ),
                  ],
                  if (isCancelled) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SecondaryActionButton(
                        text: 'Revisar',
                        icon: Icons.refresh_rounded,
                        onTap: () => _openCancelledReview(context),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReservationImage extends StatelessWidget {
  final String? imageUrl;

  const _ReservationImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container(
        width: 92,
        height: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.headerTop, AppColors.headerBottom],
          ),
        ),
        child: const Icon(
          Icons.local_parking_rounded,
          color: Colors.white,
          size: 34,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 92,
        height: 96,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.headerTop, AppColors.headerBottom],
                  ),
                ),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: const Color(0xFFE9EDF3),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: MyText(text: text, variant: MyTextVariant.body, fontSize: 13),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    Color bg;
    Color fg;

    if (normalized == 'activo') {
      bg = const Color(0xFFE8F7EE);
      fg = const Color(0xFF17803D);
    } else if (normalized == 'completado') {
      bg = const Color(0xFFEAF0F7);
      fg = const Color(0xFF1B3A57);
    } else {
      bg = const Color(0xFFFDECEC);
      fg = const Color(0xFFC62828);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: MyText(
        text: status,
        variant: MyTextVariant.bodyBold,
        fontSize: 11,
        customColor: fg,
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F7FB),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE1E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: ReservationCard.navyBottom),
              const SizedBox(width: 8),
              Flexible(
                child: MyText(
                  text: text,
                  variant: MyTextVariant.bodyBold,
                  fontSize: 13,
                  customColor: ReservationCard.navyBottom,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisabledSecondaryButton extends StatelessWidget {
  final String text;
  final IconData icon;

  const _DisabledSecondaryButton({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F7FB),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.black38),
            const SizedBox(width: 8),
            Flexible(
              child: MyText(
                text: text,
                variant: MyTextVariant.bodyBold,
                fontSize: 13,
                customColor: Colors.black38,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedSummaryDialog extends StatelessWidget {
  final Reservation reservation;
  final String dateText;
  final String timeRangeText;
  final String priceText;

  const _CompletedSummaryDialog({
    required this.reservation,
    required this.dateText,
    required this.timeRangeText,
    required this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    final durationText =
        reservation.durationMinutes != null
            ? '${reservation.durationMinutes} min'
            : 'No disponible';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MyText(
              text: 'Resumen de reservación',
              variant: MyTextVariant.title,
              textAlign: TextAlign.center,
              customColor: ReservationCard.navyBottom,
              fontSize: 20,
            ),
            const SizedBox(height: 14),
            _DialogInfoRow(label: 'Parqueo', value: reservation.parkingName),
            _DialogInfoRow(label: 'Fecha', value: dateText),
            _DialogInfoRow(label: 'Horario', value: timeRangeText),
            _DialogInfoRow(
              label: 'Espacio',
              value: '${reservation.spaceNumber}',
            ),
            _DialogInfoRow(label: 'Duración', value: durationText),
            _DialogInfoRow(label: 'Total', value: priceText),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: MyButton(
                text: 'Cerrar',
                onTap: () => Navigator.pop(context),
                margin: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelledReviewDialog extends StatelessWidget {
  final Reservation reservation;
  final String dateText;
  final String timeRangeText;

  const _CancelledReviewDialog({
    required this.reservation,
    required this.dateText,
    required this.timeRangeText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MyText(
              text: 'Revisión de cancelación',
              variant: MyTextVariant.title,
              textAlign: TextAlign.center,
              customColor: ReservationCard.navyBottom,
              fontSize: 20,
            ),
            const SizedBox(height: 14),
            _DialogInfoRow(label: 'Parqueo', value: reservation.parkingName),
            _DialogInfoRow(label: 'Fecha', value: dateText),
            _DialogInfoRow(label: 'Horario', value: timeRangeText),
            _DialogInfoRow(
              label: 'Espacio',
              value: '${reservation.spaceNumber}',
            ),
            const _DialogInfoRow(label: 'Estado', value: 'Cancelado'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: MyButton(
                text: 'Cerrar',
                onTap: () => Navigator.pop(context),
                margin: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DialogInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: MyText(
              text: '$label:',
              variant: MyTextVariant.bodyBold,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: MyText(
              text: value,
              variant: MyTextVariant.body,
              fontSize: 13,
            ),
          ),
        ],
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
