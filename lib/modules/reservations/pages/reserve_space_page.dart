import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/modules/reservations/models/parking.dart';
import 'package:mapbox_api/modules/reservations/models/reservation.dart';

class ReserveSpacePage extends StatefulWidget {
  final Parking parking;

  const ReserveSpacePage({super.key, required this.parking});

  @override
  State<ReserveSpacePage> createState() => _ReserveSpacePageState();
}

class _ReserveSpacePageState extends State<ReserveSpacePage> {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  // usa el número de espacios del parking si existe
  late final int totalSpaces =
      (widget.parking.spaces is int && widget.parking.spaces > 0)
          ? widget.parking.spaces
          : 20;

  // demo de espacios ocupados (cámbialo por datos reales cuando los tengas)
  final List<int> occupiedSpaces = [2, 5, 6, 9, 13];
  int? selectedSpace;

  Future<void> _confirmReservation() async {
    final confirm = await ConfirmReservationDialog.show(
      context,
      destination: LatLng(widget.parking.lat, widget.parking.lng),
      parkingName: widget.parking.name,
      spaceNumber: selectedSpace!,
    );

    if (confirm == true && selectedSpace != null) {
      final reservation = Reservation(
        userId: FirebaseAuth.instance.currentUser!.uid,
        parkingId: widget.parking.id,
        parkingName: widget.parking.name,
        spaceNumber: selectedSpace!,
        reservedAt: DateTime.now(),
        lat: widget.parking.lat,
        lng: widget.parking.lng,
      );

      await FirebaseFirestore.instance
          .collection('reservations')
          .add(reservation.toMap());

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/routeView',
        ModalRoute.withName('/homeNav'),
        arguments: {
          'destination': LatLng(widget.parking.lat, widget.parking.lng),
          'parkingName': widget.parking.name,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const headerHeight = 220.0;

    // responsive columns (3–5)
    final w = MediaQuery.of(context).size.width;
    final cross =
        w >= 500
            ? 5
            : w >= 380
            ? 4
            : 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // ===== HEADER (degradado como Login/Profile) =====
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
                        // icono/imagen del parking
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
                  // cerrar
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

              // ===== CARD (misma tarjeta que en Login/Configure) =====
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

                          // Leyenda
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

                          // GRID
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: totalSpaces,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cross,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1.05,
                                ),
                            itemBuilder: (_, idx) {
                              final num = idx + 1;
                              final occupied = occupiedSpaces.contains(num);
                              final selected = selectedSpace == num;
                              return _SpaceTile(
                                number: num,
                                occupied: occupied,
                                selected: selected,
                                onTap:
                                    occupied
                                        ? null
                                        : () => setState(() {
                                          selectedSpace = selected ? null : num;
                                        }),
                              );
                            },
                          ),

                          const SizedBox(height: 14),
                          // Resumen
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
    // estilos según estado
    final BoxDecoration deco;
    if (occupied) {
      deco = BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
      );
    } else if (selected) {
      deco = BoxDecoration(
        gradient: const LinearGradient(
          colors: [navyTop, navyBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      );
    } else {
      deco = BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF16A34A), width: 1.2),
      );
    }

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

/// Diálogo de confirmación consistente con tus componentes
class ConfirmReservationDialog {
  static Future<bool?> show(
    BuildContext context, {
    required LatLng destination,
    required String parkingName,
    required int spaceNumber,
  }) {
    const navyLight = Color(0xFF1B3A57);

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
                            side: const BorderSide(
                              color: navyLight,
                              width: 1.4,
                            ),
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
