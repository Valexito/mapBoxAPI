import 'package:flutter/material.dart';
import 'package:mapbox_api/components/my_text.dart';
import 'package:mapbox_api/components/my_textfield.dart';

class HomeBottomPanel extends StatelessWidget {
  const HomeBottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();

    return DraggableScrollableSheet(
      initialChildSize: 0.18, // Altura inicial (solo el search)
      minChildSize: 0.18,
      maxChildSize: 0.6, // Altura máxima al expandirse
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 6,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                MyTextField(
                  controller: _searchController,
                  hintText: '¿A dónde quieres ir?',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),

                const MyText(
                  text: 'Recientes',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),

                // Ejemplo de lista
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history, color: Color(0xFF1976D2)),
                  title: const MyText(
                    text: 'San Juan La Laguna',
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  subtitle: const MyText(
                    text: '3ra calle, San Juan La Laguna',
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                  onTap: () {
                    // Acción al tocar reciente
                  },
                ),

                // Puedes seguir agregando más recientes aquí
              ],
            ),
          ),
        );
      },
    );
  }
}
