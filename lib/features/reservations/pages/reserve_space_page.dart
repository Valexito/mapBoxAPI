import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/reservations/models/parking.dart';
import 'package:mapbox_api/features/reservations/providers/reservations_providers.dart';
import 'package:mapbox_api/features/reservations/components/confirm_reservation_dialog.dart';

class ReserveSpacePage extends ConsumerStatefulWidget {
  final Parking parking;
  const ReserveSpacePage({super.key, required this.parking});

  @override
  ConsumerState<ReserveSpacePage> createState() => _ReserveSpacePageState();
}

class _ReserveSpacePageState extends ConsumerState<ReserveSpacePage> {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  int? selectedSpace;

  Future<void> _confirmReservation() async {
    final ok = await ConfirmReservationDialog.show(
      context,
      destination: LatLng(widget.parking.lat, widget.parking.lng),
      parkingName: widget.parking.name,
      spaceNumber: selectedSpace!,
    );

    if (ok == true && selectedSpace != null) {
      try {
        final reserve = ref.read(reserveSpaceProvider);
        final reservationId = await reserve(
          parkingId: widget.parking.id,
          parkingName: widget.parking.name,
          spaceNumber: selectedSpace!,
        );

        if (!mounted) return;
        Navigator.of(context).pushNamed(
          '/routeView',
          arguments: {
            'destination': LatLng(widget.parking.lat, widget.parking.lng),
            'parkingName': widget.parking.name,
            'reservationId': reservationId,
          },
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo reservar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const headerHeight = 220.0;
    final w = MediaQuery.of(context).size.width;
    final cross =
        w >= 500
            ? 5
            : w >= 380
            ? 4
            : 3;

    // Stream en tiempo real de spaces del parking (ahora Mapa<int, ParkingSpace>)
    final spacesAsync = ref.watch(parkingSpacesProvider(widget.parking.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // ===== HEADER =====
              Stack(
                children: [
                  Container(
                    height: headerHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [navyTop, navyBottom],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child:
                                (widget.parking.imageUrl?.isNotEmpty ?? false)
                                    ? Image.network(
                                      widget.parking.imageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                    : Container(
                                      color: Colors.white,
                                      child: const Icon(
                                        Icons.local_parking,
                                        size: 46,
                                        color: navyBottom,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const MyText(
                          text: 'RESERVAR ESPACIO',
                          variant: MyTextVariant.title,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        MyText(
                          text: widget.parking.name,
                          variant: MyTextVariant.normal,
                          fontSize: 13,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),

              // ===== CARD =====
              Transform.translate(
                offset: const Offset(0, -34),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const MyText(
                            text: 'Selecciona tu espacio',
                            variant: MyTextVariant.normal,
                            fontSize: 13,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              _LegendDot(
                                color: Color(0xFF16A34A),
                                label: 'Libre',
                              ),
                              SizedBox(width: 14),
                              _LegendDot(
                                color: Color(0xFF9CA3AF),
                                label: 'Ocupado',
                              ),
                              SizedBox(width: 14),
                              _LegendDot(
                                color: Color(0xFF1B3A57),
                                label: 'Seleccionado',
                                filled: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // GRID con estados en tiempo real
                          spacesAsync.when(
                            loading:
                                () => const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            error:
                                (e, _) => Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Center(
                                    child: MyText(
                                      text: 'Error cargando espacios: $e',
                                      variant: MyTextVariant.bodyBold,
                                    ),
                                  ),
                                ),
                            data: (spacesMap) {
                              // cantidad total mostrada
                              final total =
                                  widget.parking.spaces > 0
                                      ? widget.parking.spaces
                                      : (spacesMap.isNotEmpty
                                          ? spacesMap.length
                                          : 20);

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: total,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cross,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: 1.05,
                                    ),
                                itemBuilder: (_, idx) {
                                  final num = idx + 1;

                                  // Toma el espacio por su número de documento
                                  final space = spacesMap[num];
                                  final occupied =
                                      (space?.status ?? 'free') != 'free';
                                  final selected = selectedSpace == num;

                                  // Si se ocupó en tiempo real, deselecciona
                                  if (selected && occupied) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted)
                                            setState(
                                              () => selectedSpace = null,
                                            );
                                        });
                                  }

                                  return _SpaceTile(
                                    number: num,
                                    occupied: occupied,
                                    selected: selected,
                                    onTap:
                                        occupied
                                            ? null
                                            : () => setState(
                                              () =>
                                                  selectedSpace =
                                                      selected ? null : num,
                                            ),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_parking,
                                  color: navyBottom,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: MyText(
                                    text:
                                        selectedSpace == null
                                            ? 'Ningún espacio seleccionado'
                                            : 'Espacio seleccionado: $selectedSpace',
                                    variant: MyTextVariant.body,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          MyButton(
                            text: 'Confirmar reserva',
                            onTap:
                                selectedSpace != null
                                    ? _confirmReservation
                                    : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpaceTile extends StatelessWidget {
  final int number;
  final bool occupied;
  final bool selected;
  final VoidCallback? onTap;

  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  const _SpaceTile({
    required this.number,
    required this.occupied,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final BoxDecoration deco =
        occupied
            ? BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
            )
            : selected
            ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [navyTop, navyBottom],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            )
            : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF16A34A), width: 1.2),
            );

    final textColor =
        occupied
            ? const Color(0xFF6B7280)
            : (selected ? Colors.white : Colors.black87);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: deco,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car,
                size: 20,
                color: selected ? Colors.white : textColor,
              ),
              const SizedBox(height: 4),
              MyText(
                text: 'Espacio $number',
                variant: MyTextVariant.body,
                fontSize: 12,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool filled;
  const _LegendDot({
    required this.color,
    required this.label,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 6),
        MyText(text: label, variant: MyTextVariant.body, fontSize: 12),
      ],
    );
  }
}
