import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/components/ui/my_textfield.dart';

class HomeBottomPanel extends StatefulWidget {
  const HomeBottomPanel({super.key});

  @override
  State<HomeBottomPanel> createState() => _HomeBottomPanelState();
}

class _HomeBottomPanelState extends State<HomeBottomPanel> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;

  static const _debounceMs = 350;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: _debounceMs), () {
      _fetchSuggestions(value);
    });
  }

  Future<void> _fetchSuggestions(String value) async {
    if (value.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    const String accessToken =
        'pk.eyJ1IjoiYWxleC1hcmd1ZXRhIiwiYSI6ImNtYm9veml5MjA0dDUyd3B3YXI1ZGxqeWsifQ.4WNWf4fqoNZeL5cByoS05A'; // ⚠️ mueve a config/secure storage en producción
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$value.json?access_token=$accessToken&autocomplete=true&country=GT&limit=5';

    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = (data['features'] as List?) ?? [];

        setState(() {
          _suggestions =
              features
                  .map(
                    (f) => {
                      'name': f['text'] ?? '',
                      'address': f['place_name'] ?? '',
                      'coordinates': f['center'] ?? [],
                    },
                  )
                  .toList();
        });
      } else {
        setState(() => _suggestions = []);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _suggestions = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.18,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
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
                // handle
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

                // Search
                MyTextField(
                  controller: _searchController,
                  hintText: '¿A dónde quieres ir?',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.search,
                  onChanged: _onSearchChanged,
                  margin: EdgeInsets.zero,
                ),

                const SizedBox(height: 16),

                if (_suggestions.isNotEmpty) ...[
                  const MyText(
                    text: 'Sugerencias',
                    variant: MyTextVariant.normalBold,
                  ),
                  const SizedBox(height: 8),

                  ..._suggestions.map(
                    (s) => Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.place,
                            color: Color(0xFF1976D2),
                          ),
                          title: MyText(
                            text: s['name'] ?? '',
                            variant: MyTextVariant.body, // negro, 15, w500
                          ),
                          subtitle: MyText(
                            text: s['address'] ?? '',
                            variant:
                                MyTextVariant.bodyMuted, // negro atenuado, 13
                          ),
                          onTap: () {
                            // Manejar selección del lugar
                            debugPrint('Seleccionado: ${s['address']}');
                            // TODO: pasar coordenadas a tu mapa:
                            // final coords = s['coordinates']; // [lng, lat]
                          },
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
