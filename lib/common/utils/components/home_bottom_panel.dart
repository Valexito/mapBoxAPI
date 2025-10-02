import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/my_textfield.dart';
import 'package:mapbox_api/features/core/services/recent_searches.dart';
import 'package:mapbox_api/common/env/env.dart';

class HomeBottomPanel extends StatefulWidget {
  const HomeBottomPanel({
    super.key,
    required this.controller,
    required this.onPlaceSelected,
  });

  final DraggableScrollableController controller;
  final ValueChanged<LatLng> onPlaceSelected;

  @override
  State<HomeBottomPanel> createState() => _HomeBottomPanelState();
}

class _HomeBottomPanelState extends State<HomeBottomPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focus = FocusNode();

  List<Map<String, dynamic>> _suggestions = [];
  List<RecentItem> _recents = [];
  Timer? _debounce;

  static const _debounceMs = 350;
  static const _minSize = 0.18;
  static const _maxSize = 0.60;

  @override
  void initState() {
    super.initState();
    _loadRecents();
    _focus.addListener(() {
      if (_focus.hasFocus) _animateTo(_maxSize);
    });
  }

  Future<void> _loadRecents() async {
    final items = await RecentSearches.load();
    if (!mounted) return;
    setState(() => _recents = items);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _animateTo(double size) {
    widget.controller.animateTo(
      size,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: _debounceMs), () {
      _fetchSuggestions(value);
    });
  }

  Future<void> _fetchSuggestions(String value) async {
    final q = value.trim();
    if (q.length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    final token = Env.mapboxToken;
    if (token.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final uri = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(q)}.json'
      '?access_token=$token&autocomplete=true&country=GT&limit=5',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final features = (data['features'] as List?) ?? [];
        setState(() {
          _suggestions = features
              .map<Map<String, dynamic>>(
                (f) => {
                  'name': f['text'] ?? '',
                  'address': f['place_name'] ?? '',
                  'coordinates':
                      (f['center'] ?? const []) as List, // [lng, lat]
                },
              )
              .toList(growable: false);
        });
      } else {
        setState(() => _suggestions = []);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _suggestions = []);
    }
  }

  void _selectPlace({
    required String name,
    required String address,
    required List coords,
  }) async {
    if (coords.length < 2) return;
    final lng = (coords[0] as num).toDouble();
    final lat = (coords[1] as num).toDouble();
    final target = LatLng(lat, lng);

    widget.onPlaceSelected(target); // mueve el mapa
    await RecentSearches.add(
      RecentItem(name: name, address: address, lat: lat, lng: lng),
    );
    await _loadRecents();

    _animateTo(_minSize); // minimizar
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: widget.controller,
      initialChildSize: _minSize,
      minChildSize: _minSize,
      maxChildSize: _maxSize,
      builder: (context, scrollController) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _animateTo(_maxSize),
          child: Container(
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
                    prefixIcon: Icons.search,
                    onChanged: _onSearchChanged,
                    margin: EdgeInsets.zero,
                    focusNode: _focus,
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
                              variant: MyTextVariant.body,
                            ),
                            subtitle: MyText(
                              text: s['address'] ?? '',
                              variant: MyTextVariant.bodyMuted,
                            ),
                            onTap:
                                () => _selectPlace(
                                  name: s['name'] ?? '',
                                  address: s['address'] ?? '',
                                  coords: s['coordinates'] ?? const [],
                                ),
                          ),
                          Divider(height: 1, color: Colors.grey[300]),
                        ],
                      ),
                    ),
                  ] else ...[
                    const MyText(
                      text: 'Recientes',
                      variant: MyTextVariant.normalBold,
                    ),
                    const SizedBox(height: 8),
                    if (_recents.isEmpty)
                      const MyText(
                        text: 'Sin lugares recientes',
                        variant: MyTextVariant.bodyMuted,
                      )
                    else
                      ..._recents.map(
                        (r) => Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.history,
                                color: Colors.black54,
                              ),
                              title: MyText(
                                text: r.name,
                                variant: MyTextVariant.body,
                              ),
                              subtitle: MyText(
                                text: r.address,
                                variant: MyTextVariant.bodyMuted,
                              ),
                              onTap:
                                  () => _selectPlace(
                                    name: r.name,
                                    address: r.address,
                                    coords: [r.lng, r.lat],
                                  ),
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
