import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';
import 'package:mapbox_api/features/reservations/providers/reservations_providers.dart';

class ReservationDetailsSheet extends ConsumerStatefulWidget {
  final Reservation reservation;

  const ReservationDetailsSheet({super.key, required this.reservation});

  @override
  ConsumerState<ReservationDetailsSheet> createState() =>
      _ReservationDetailsSheetState();
}

class _ReservationDetailsSheetState
    extends ConsumerState<ReservationDetailsSheet> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final requestExit = ref.read(requestExitProvider);
    final complete = ref.read(completeReservationWithBillingProvider);
    final reservation = widget.reservation;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.borderSoft,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            MyText(
              text: reservation.parkingName,
              variant: MyTextVariant.bodyBold,
              fontSize: 18,
            ),
            const SizedBox(height: 6),
            MyText(
              text: 'Espacio ${reservation.spaceNumber}',
              variant: MyTextVariant.bodyMuted,
              fontSize: 13,
            ),
            const SizedBox(height: 18),
            _InfoRow(label: 'Estado', value: _displayStatus(reservation)),
            _InfoRow(
              label: 'Inicio',
              value: _formatDateTime(reservation.reservedAt),
            ),
            if (reservation.exitStatus == 'requested')
              _InfoRow(label: 'Salida', value: 'Pendiente de aprobación'),
            if (reservation.exitStatus == 'approved')
              _InfoRow(label: 'Salida', value: 'Aprobada'),
            if (reservation.endedAt != null)
              _InfoRow(
                label: 'Fin',
                value: _formatDateTime(reservation.endedAt!),
              ),
            if (reservation.durationMinutes != null)
              _InfoRow(
                label: 'Duración',
                value: '${reservation.durationMinutes} min',
              ),
            if (reservation.pricePerHour != null)
              _InfoRow(
                label: 'Tarifa',
                value: 'Q ${reservation.pricePerHour}/hora',
              ),
            if (reservation.amount != null)
              _InfoRow(label: 'Monto', value: 'Q ${reservation.amount}'),
            const SizedBox(height: 20),
            if (reservation.state == 'active' &&
                reservation.exitStatus == 'none')
              MyButton(
                text: _isProcessing ? 'Procesando...' : 'Solicitar salida',
                onTap:
                    _isProcessing
                        ? null
                        : () async {
                          setState(() => _isProcessing = true);
                          try {
                            await requestExit(reservation: reservation);
                            if (!mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            if (!mounted) return;
                            _showError(context, e.toString());
                          } finally {
                            if (mounted) {
                              setState(() => _isProcessing = false);
                            }
                          }
                        },
                margin: EdgeInsets.zero,
              ),
            if (reservation.state == 'active' &&
                reservation.exitStatus == 'requested')
              MyButton(
                text: 'Esperando aprobación...',
                onTap: null,
                margin: EdgeInsets.zero,
              ),
            if (reservation.state == 'active' &&
                reservation.exitStatus == 'approved')
              MyButton(
                text: _isProcessing ? 'Procesando...' : 'Finalizar y pagar',
                onTap:
                    _isProcessing
                        ? null
                        : () async {
                          setState(() => _isProcessing = true);
                          try {
                            await complete(r: reservation);
                            if (!mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            if (!mounted) return;
                            _showError(context, e.toString());
                          } finally {
                            if (mounted) {
                              setState(() => _isProcessing = false);
                            }
                          }
                        },
                margin: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }

  String _displayStatus(Reservation r) {
    if (r.state == 'completed') return 'Completada';
    if (r.state == 'cancelled') return 'Cancelada';
    if (r.state == 'cancellation_requested') return 'Cancelación pendiente';
    if (r.state == 'active' && r.exitStatus == 'approved') {
      return 'Salida aprobada';
    }
    if (r.state == 'active' && r.exitStatus == 'requested') {
      return 'Salida solicitada';
    }
    return 'Activa';
  }

  String _formatDateTime(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final h = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: MyText(
              text: label,
              variant: MyTextVariant.bodyMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: MyText(
              text: value,
              variant: MyTextVariant.bodyBold,
              fontSize: 13,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
