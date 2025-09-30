import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/core/roles/role_utils.dart';

// Aquí mostrarás todos tus parqueos, crear/editar, etc.
class OwnerParkingListPage extends ConsumerWidget {
  const OwnerParkingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OwnerOnly(
      builder:
          (_) => const Center(
            child: MyText(
              text: 'Mis parqueos (owner)',
              variant: MyTextVariant.bodyBold,
            ),
          ),
    );
  }
}
