import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';

class ConfirmReservationDialog {
  static Future<bool?> show(
    BuildContext context, {
    required LatLng destination,
    required String parkingName,
    required int spaceNumber,
  }) {
    const navy = Color(0xFF1B3A57);

    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MyText(
                    text: 'CONFIRMAR RESERVA',
                    variant: MyTextVariant.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  MyText(
                    text:
                        'Parqueo: $parkingName\nEspacio: $spaceNumber\n¿Deseas continuar?',
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
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: navy, width: 1.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const MyText(
                            text: 'Cancelar',
                            variant: MyTextVariant.normalBold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 42,
                        width: 140,
                        child: MyButton(
                          text: 'Confirmar',
                          onTap: () => Navigator.of(ctx).pop(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
