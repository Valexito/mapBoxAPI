import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';

class ConfirmReservationDialog {
  static Future<bool?> show(
    BuildContext context, {
    required LatLng destination,
    required String parkingName,
    required int spaceNumber,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.headerBottom.withOpacity(0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.headerTop, AppColors.headerBottom],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.24),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.event_available_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const MyText(
                        text: 'Confirmar reserva',
                        variant: MyTextVariant.title,
                        customColor: Colors.white,
                        textAlign: TextAlign.center,
                        fontSize: 21,
                      ),
                      const SizedBox(height: 6),
                      const MyText(
                        text:
                            'Revisa los detalles antes de continuar con tu reservación.',
                        variant: MyTextVariant.bodyMuted,
                        customColor: Colors.white70,
                        textAlign: TextAlign.center,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.headerBottom.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyText(
                              text: 'Resumen de reserva',
                              variant: MyTextVariant.normalBold,
                              fontSize: 15,
                            ),
                            const SizedBox(height: 14),
                            _SummaryRow(
                              icon: Icons.local_parking_outlined,
                              title: 'Parqueo',
                              value: parkingName,
                            ),
                            const SizedBox(height: 12),
                            _SummaryRow(
                              icon: Icons.pin_outlined,
                              title: 'Espacio',
                              value: 'Espacio $spaceNumber',
                            ),
                            const SizedBox(height: 12),
                            _SummaryRow(
                              icon: Icons.place_outlined,
                              title: 'Destino',
                              value:
                                  '${destination.latitude.toStringAsFixed(5)}, ${destination.longitude.toStringAsFixed(5)}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.headerBottom.withOpacity(
                                      0.35,
                                    ),
                                    width: 1.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                child: const MyText(
                                  text: 'Cancelar',
                                  variant: MyTextVariant.normalBold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyButton(
                              text: 'Confirmar',
                              onTap: () => Navigator.of(ctx).pop(true),
                              margin: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.iconCircle,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 19, color: AppColors.headerBottom),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: title,
                variant: MyTextVariant.bodyMuted,
                fontSize: 12,
              ),
              const SizedBox(height: 2),
              MyText(text: value, variant: MyTextVariant.body, fontSize: 13),
            ],
          ),
        ),
      ],
    );
  }
}
