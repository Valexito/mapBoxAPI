import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/modules/reservations/pages/reserve_space_page.dart';
import 'package:mapbox_api/modules/reservations/models/parking.dart';

class HomeParkingDetailBottomSheet extends StatelessWidget {
  final Parking parking;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const HomeParkingDetailBottomSheet({
    super.key,
    required this.parking,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  static const navyBottom = Color(0xFF1B3A57);

  String _money(num v) => 'Q${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Material(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== Imagen + overlay + acciones =====
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child:
                      parking.localImagePath != null
                          ? Image.asset(
                            parking.localImagePath!,
                            fit: BoxFit.cover,
                          )
                          : Image.network(
                            parking.imageUrl ??
                                'https://via.placeholder.com/400x200',
                            fit: BoxFit.cover,
                          ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black26],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      // Corazón: azul marino cuando está activo
                      _RoundIcon(
                        icon:
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? navyBottom : Colors.black38,
                        onTap: onToggleFavorite ?? () {},
                      ),
                      const SizedBox(width: 8),
                      _RoundIcon(
                        icon: Icons.close,
                        color: navyBottom,
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ===== Contenido =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: 'Parqueo en ${parking.name}',
                    variant: MyTextVariant.title,
                    fontSize: 18,
                  ),
                  const SizedBox(height: 6),
                  if ((parking.descripcion ?? '').isNotEmpty)
                    MyText(
                      text: parking.descripcion!,
                      variant: MyTextVariant.body,
                      fontSize: 14,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      MyText(
                        text: '${_money(parking.price)} por noche',
                        variant: MyTextVariant.bodyBold,
                        fontSize: 16,
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        size: 18,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 4),
                      MyText(
                        text: (parking.rating ?? 4.8).toStringAsFixed(2),
                        variant: MyTextVariant.body,
                        fontSize: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MyText(
                    text: 'Espacios disponibles: ${parking.spaces}',
                    variant: MyTextVariant.body,
                    fontSize: 14,
                  ),

                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  MyButton(
                    text: 'Reservar espacio',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReserveSpacePage(parking: parking),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoundIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
