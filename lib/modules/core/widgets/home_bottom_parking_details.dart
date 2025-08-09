import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/modules/user_parking/pages/reserve_space_page.dart';
import '../../user_parking/models/parking.dart';

class HomeParkingDetailBottomSheet extends StatelessWidget {
  final Parking parking;

  const HomeParkingDetailBottomSheet({super.key, required this.parking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imagen superior con botones
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                child:
                    parking.localImagePath != null
                        ? Image.asset(
                          parking.localImagePath!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                        : Image.network(
                          parking.imageUrl ??
                              'https://via.placeholder.com/400x200',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {}, // Lógica de favoritos
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Contenido inferior
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: 'Parqueo en ${parking.name}',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 6),
                MyText(
                  text: parking.descripcion ?? 'Descripción no disponible',
                  fontSize: 14,
                  color: Colors.black54,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    MyText(
                      text: 'Q${parking.price} por noche',
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    const Spacer(),
                    const Icon(Icons.star, size: 18, color: Colors.black87),
                    const SizedBox(width: 4),
                    MyText(
                      text: parking.rating?.toStringAsFixed(2) ?? '4.8',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                MyText(
                  text: 'Espacios disponibles: ${parking.spaces}',
                  fontSize: 14,
                  color: Colors.black87,
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReserveSpacePage(parking: parking),
                        ),
                      );
                    },
                    icon: const Icon(Icons.book_online, color: Colors.white),
                    label: const Text(
                      'Reservar espacio',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
