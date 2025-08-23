import 'package:flutter/material.dart';
import 'package:mapbox_api/modules/core/services/favorite_service.dart';
import 'package:mapbox_api/modules/core/widgets/home_bottom_parking_details.dart';
import 'package:mapbox_api/modules/reservations/models/parking.dart';

/// Abre la hoja de detalle de un parking con toggle de favoritos estable.
/// - Muestra flip inmediato en UI
/// - Sincroniza con Firestore
void openParkingSheet(BuildContext context, Parking parking) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      bool? localFav; // estado local del sheet (null = aún no inicializado)

      return StatefulBuilder(
        builder: (context, setSheetState) {
          return StreamBuilder<bool>(
            stream: FavoriteService.instance.isFavoriteStream(parking.id),
            builder: (context, snap) {
              // Inicializar una sola vez desde el stream (cuando llegue)
              if (localFav == null) {
                localFav = snap.data ?? false;
              }
              final uiFav = localFav!;

              return HomeParkingDetailBottomSheet(
                parking: parking,
                isFavorite: uiFav,
                onToggleFavorite: () async {
                  final next = !uiFav;

                  // 1) Flip inmediato en UI
                  setSheetState(() => localFav = next);

                  // 2) Escribir en Firestore
                  try {
                    if (next) {
                      await FavoriteService.instance.add(parking);
                    } else {
                      await FavoriteService.instance.removeByParkingId(
                        parking.id,
                      );
                    }
                  } catch (e) {
                    // 3) Revertir en caso de error
                    setSheetState(() => localFav = !next);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo actualizar favoritos'),
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      );
    },
  );
}
