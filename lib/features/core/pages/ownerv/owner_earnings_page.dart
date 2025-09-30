import 'package:flutter/material.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/core/roles/role_utils.dart';

// Reportes/ingresos
class OwnerEarningsPage extends StatelessWidget {
  const OwnerEarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OwnerOnly(
      builder:
          (_) => const Center(
            child: MyText(
              text: 'Ganancias/Reportes',
              variant: MyTextVariant.bodyBold,
            ),
          ),
    );
  }
}
