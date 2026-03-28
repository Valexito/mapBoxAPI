import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/reservations/components/reservations_details_sheet.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';

class ReservationCard extends ConsumerWidget {
  final Reservation reservation;

  const ReservationCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusText = _displayStatus(reservation);
    final color = _statusColor(reservation);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ReservationDetailsSheet(reservation: reservation),
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.iconCircle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: AppColors.headerBottom,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: reservation.parkingName,
                      variant: MyTextVariant.bodyBold,
                      fontSize: 15,
                    ),
                    const SizedBox(height: 4),
                    MyText(
                      text: 'Espacio ${reservation.spaceNumber}',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayStatus(Reservation r) {
    if (r.state == 'completed') return 'COMPLETADA';
    if (r.state == 'cancelled') return 'CANCELADA';
    if (r.state == 'cancellation_requested') return 'CANCELACIÓN PENDIENTE';

    if (r.state == 'active' && r.exitStatus == 'approved') {
      return 'SALIDA APROBADA';
    }

    if (r.state == 'active' && r.exitStatus == 'requested') {
      return 'SALIDA SOLICITADA';
    }

    return 'ACTIVA';
  }

  Color _statusColor(Reservation r) {
    if (r.state == 'completed') {
      return const Color(0xFF2563EB);
    }
    if (r.state == 'cancelled') {
      return const Color(0xFFDC2626);
    }
    if (r.state == 'cancellation_requested') {
      return const Color(0xFFF59E0B);
    }
    if (r.state == 'active' && r.exitStatus == 'approved') {
      return const Color(0xFF7C3AED);
    }
    if (r.state == 'active' && r.exitStatus == 'requested') {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF16A34A);
  }
}
