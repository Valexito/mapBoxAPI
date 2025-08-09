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

  void _onSearchChanged(String value) async {
    if (value.length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    final String accessToken =
        'pk.eyJ1IjoiYWxleC1hcmd1ZXRhIiwiYSI6ImNtYm9veml5MjA0dDUyd3B3YXI1ZGxqeWsifQ.4WNWf4fqoNZeL5cByoS05A'; // ⚠️ PON TU TOKEN
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$value.json?access_token=$accessToken&autocomplete=true&country=GT&limit=5';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'] as List;

      setState(() {
        _suggestions =
            features
                .map(
                  (f) => {
                    'name': f['text'],
                    'address': f['place_name'],
                    'coordinates': f['center'],
                  },
                )
                .toList();
      });
    } else {
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
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 16),
                if (_suggestions.isNotEmpty)
                  ..._suggestions.map(
                    (s) => ListTile(
                      leading: const Icon(
                        Icons.place,
                        color: Color(0xFF1976D2),
                      ),
                      title: MyText(
                        text: s['name'],
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      subtitle: MyText(
                        text: s['address'],
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                      onTap: () {
                        // Aquí puedes manejar la selección del lugar
                        print('Seleccionado: ${s['address']}');
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
