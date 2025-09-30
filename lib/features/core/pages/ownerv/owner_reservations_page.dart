import 'package:flutter/material.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/core/roles/role_utils.dart';

// Lista/gestión de reservas que recibió el propietario
class OwnerReservationsPage extends StatelessWidget {
  const OwnerReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OwnerOnly(
      builder:
          (_) => const Center(
            child: MyText(
              text: 'Reservas de mi(s) parqueo(s)',
              variant: MyTextVariant.bodyBold,
            ),
          ),
    );
  }
}
