import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_text.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  final _categories = const ['All', 'Centro', 'Norte', 'Sur', 'Oeste'];
  String _selectedCat = 'All';

  Stream<List<_FavItem>> _streamFavorites() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    // Estructura esperada en Firestore (colección "favorites"):
    // { userId, name, address, minutes, rating, imageUrl, category, discount }
    return FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map(
          (qs) =>
              qs.docs.map((d) {
                final m = d.data();
                return _FavItem(
                  id: d.id,
                  name: m['name'] ?? 'Parking',
                  address: m['address'] ?? '',
                  minutes: (m['minutes'] ?? 10) as int,
                  rating: (m['rating'] ?? 4.6).toDouble(),
                  imageUrl: m['imageUrl'],
                  category: m['category'] ?? 'All',
                  discount: (m['discount'] ?? 0) as int,
                );
              }).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    const headerH = 140.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER (gradiente + back + título + buscador) =====
            SizedBox(
              height: headerH,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [navyTop, navyBottom],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 4,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Center(
                    child: MyText(
                      text: 'FAVORITES',
                      variant: MyTextVariant.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        // TODO: acción de búsqueda
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ===== CHIPS DE FILTRO =====
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  elevation: 6,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            _categories
                                .map(
                                  (c) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _FilterChip(
                                      label: c,
                                      selected: _selectedCat == c,
                                      onTap:
                                          () =>
                                              setState(() => _selectedCat = c),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ===== LISTA =====
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -16),
                child: StreamBuilder<List<_FavItem>>(
                  stream: _streamFavorites(),
                  builder: (context, snap) {
                    final all = snap.data ?? _demoFavorites;
                    final items =
                        _selectedCat == 'All'
                            ? all
                            : all
                                .where((e) => e.category == _selectedCat)
                                .toList();

                    if (items.isEmpty) {
                      return const Center(
                        child: MyText(
                          text: 'No hay favoritos aquí',
                          variant: MyTextVariant.bodyMuted,
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        24 + 8,
                      ), // aire
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _FavoriteCard(item: items[i]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1B3A57);
    final bg = selected ? navy : const Color(0xFFEFF2F6);
    final fg = selected ? Colors.white : navy;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: fg, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatefulWidget {
  final _FavItem item;
  const _FavoriteCard({required this.item});

  @override
  State<_FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<_FavoriteCard> {
  bool _fav = true; // ya está en favoritos

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1B3A57);

    return Material(
      elevation: 4,
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          // Imagen + heart
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child:
                      widget.item.imageUrl == null
                          ? Container(color: const Color(0xFFE7ECF3))
                          : Image.network(
                            widget.item.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              if (widget.item.discount > 0)
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MyText(
                      text: '${widget.item.discount}% OFF',
                      variant: MyTextVariant.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              Positioned(
                right: 10,
                top: 10,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: IconButton(
                    icon: Icon(
                      _fav ? Icons.favorite : Icons.favorite_border,
                      color: _fav ? Colors.red : navy,
                    ),
                    onPressed: () {
                      setState(() => _fav = !_fav);
                      // TODO: actualizar backend (add/remove favorito)
                    },
                  ),
                ),
              ),
            ],
          ),

          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // nombre + rating
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: widget.item.name,
                        variant: MyTextVariant.bodyBold,
                        fontSize: 15,
                      ),
                    ),
                    const Icon(Icons.star, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    MyText(
                      text: widget.item.rating.toStringAsFixed(1),
                      variant: MyTextVariant.body,
                      fontSize: 13,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // min + dirección
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: navy),
                    const SizedBox(width: 6),
                    MyText(
                      text: '${widget.item.minutes} min',
                      variant: MyTextVariant.body,
                      fontSize: 13,
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.place_outlined, size: 16, color: navy),
                    const SizedBox(width: 6),
                    Expanded(
                      child: MyText(
                        text: widget.item.address,
                        variant: MyTextVariant.bodyMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavItem {
  final String id;
  final String name;
  final String address;
  final int minutes;
  final double rating;
  final String? imageUrl;
  final String category;
  final int discount;

  _FavItem({
    required this.id,
    required this.name,
    required this.address,
    required this.minutes,
    required this.rating,
    required this.category,
    this.imageUrl,
    this.discount = 0,
  });
}

// ===== DEMO =====
final _demoFavorites = <_FavItem>[
  _FavItem(
    id: 'f1',
    name: 'Parqueo Central',
    address: '12 Av. Zona 3, Quetzaltenango',
    minutes: 15,
    rating: 4.9,
    category: 'Centro',
    discount: 10,
  ),
  _FavItem(
    id: 'f2',
    name: 'Shaddai Norte',
    address: 'Calz. San José, Zona 6',
    minutes: 20,
    rating: 4.8,
    category: 'Norte',
    discount: 20,
  ),
  _FavItem(
    id: 'f3',
    name: 'Garage Alameda',
    address: 'Alameda #27',
    minutes: 8,
    rating: 4.6,
    category: 'Sur',
  ),
];
