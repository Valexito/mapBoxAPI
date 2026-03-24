import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:mapbox_api/common/env/env.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/my_textfield.dart';
import 'package:mapbox_api/features/core/services/recent_searches.dart';

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
  static const _minSize = 0.22;
  static const _maxSize = 0.72;

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
      if (!mounted) return;
      setState(() => _suggestions = []);
      return;
    }

    final token = Env.mapboxToken;
    if (token.isEmpty) {
      if (!mounted) return;
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
                  'coordinates': (f['center'] ?? const []) as List,
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

    widget.onPlaceSelected(target);

    await RecentSearches.add(
      RecentItem(name: name, address: address, lat: lat, lng: lng),
    );
    await _loadRecents();

    _animateTo(_minSize);
    FocusScope.of(context).unfocus();
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MyText(
        text: text,
        variant: MyTextVariant.normalBold,
        fontSize: 15,
        customColor: AppColors.headerBottom,
      ),
    );
  }

  Widget _resultCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDims.radiusMd),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDims.radiusMd),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDims.radiusMd),
              border: Border.all(color: AppColors.borderSoft),
              boxShadow: [
                BoxShadow(
                  color: AppColors.headerBottom.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.iconCircle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: title,
                        variant: MyTextVariant.bodyBold,
                        fontSize: 14,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: subtitle,
                        variant: MyTextVariant.bodyMuted,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDims.radiusMd),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 30,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 10),
          MyText(
            text: 'Sin lugares recientes',
            variant: MyTextVariant.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSuggestions = _suggestions.isNotEmpty;

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
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(34),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.headerBottom.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 5,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.borderSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText(
                          text: 'Buscar destino',
                          variant: MyTextVariant.title,
                          customColor: AppColors.headerBottom,
                          fontSize: 20,
                        ),
                        const SizedBox(height: 6),

                        const SizedBox(height: 16),
                        MyTextField(
                          controller: _searchController,
                          hintText: '¿A dónde quieres ir?',
                          keyboardType: TextInputType.text,
                          prefixIcon: Icons.search_rounded,
                          onChanged: _onSearchChanged,
                          margin: EdgeInsets.zero,
                          focusNode: _focus,
                        ),
                        const SizedBox(height: 18),
                        if (hasSuggestions) ...[
                          _sectionTitle('Sugerencias'),
                          ..._suggestions.map(
                            (s) => _resultCard(
                              icon: Icons.place_outlined,
                              iconColor: AppColors.headerBottom,
                              title: (s['name'] ?? '') as String,
                              subtitle: (s['address'] ?? '') as String,
                              onTap:
                                  () => _selectPlace(
                                    name: s['name'] ?? '',
                                    address: s['address'] ?? '',
                                    coords: s['coordinates'] ?? const [],
                                  ),
                            ),
                          ),
                        ] else ...[
                          _sectionTitle('Recientes'),
                          if (_recents.isEmpty)
                            _emptyState()
                          else
                            ..._recents.map(
                              (r) => _resultCard(
                                icon: Icons.history_rounded,
                                iconColor: AppColors.textSecondary,
                                title: r.name,
                                subtitle: r.address,
                                onTap:
                                    () => _selectPlace(
                                      name: r.name,
                                      address: r.address,
                                      coords: [r.lng, r.lat],
                                    ),
                              ),
                            ),
                        ],
                      ],
                    ),
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
