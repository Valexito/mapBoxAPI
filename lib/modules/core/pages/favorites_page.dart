import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/modules/core/services/favorite_service.dart';
import 'package:mapbox_api/modules/reservations/models/parking.dart';
import 'package:mapbox_api/modules/reservations/pages/reserve_space_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

enum FavFilter { all, rating45, cheapest, spaces }

class _FavoritesPageState extends State<FavoritesPage> {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  FavFilter _filter = FavFilter.all;

  Stream<List<_FavItem>> _streamFavorites() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map(
          (qs) => qs.docs.map((d) => _FavItem.fromMap(d.id, d.data())).toList(),
        );
  }

  List<_FavItem> _applyFilter(List<_FavItem> items) {
    switch (_filter) {
      case FavFilter.rating45:
        return items.where((e) => e.rating >= 4.5).toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));
      case FavFilter.cheapest:
        return [...items]..sort((a, b) => a.price.compareTo(b.price));
      case FavFilter.spaces:
        return items.where((e) => e.spaces > 0).toList();
      case FavFilter.all:
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    const headerH = 140.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
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
                ],
              ),
            ),

            // ===== FILTER CHIPS =====
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
                        children: [
                          _Chip(
                            label: 'All',
                            selected: _filter == FavFilter.all,
                            onTap:
                                () => setState(() => _filter = FavFilter.all),
                          ),
                          const SizedBox(width: 8),
                          _Chip(
                            label: 'Rating 4.5+',
                            selected: _filter == FavFilter.rating45,
                            onTap:
                                () => setState(
                                  () => _filter = FavFilter.rating45,
                                ),
                          ),
                          const SizedBox(width: 8),
                          _Chip(
                            label: 'Cheapest',
                            selected: _filter == FavFilter.cheapest,
                            onTap:
                                () => setState(
                                  () => _filter = FavFilter.cheapest,
                                ),
                          ),
                          const SizedBox(width: 8),
                          _Chip(
                            label: 'With spaces',
                            selected: _filter == FavFilter.spaces,
                            onTap:
                                () =>
                                    setState(() => _filter = FavFilter.spaces),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ===== LIST =====
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -16),
                child: StreamBuilder<List<_FavItem>>(
                  stream: _streamFavorites(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return const Center(
                        child: MyText(
                          text: 'Error loading favorites',
                          variant: MyTextVariant.body,
                        ),
                      );
                    }

                    final all = snap.data ?? const <_FavItem>[];
                    final items = _applyFilter(all);

                    if (items.isEmpty) {
                      return const Center(
                        child: MyText(
                          text: 'No favorites yet',
                          variant: MyTextVariant.bodyMuted,
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({
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
  bool _fav = true;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1B3A57);
    final heroImg =
        widget.item.heroImage ??
        'https://via.placeholder.com/800x450?text=Parking';

    // 👉 Toda la tarjeta es clickeable y navega a ReserveSpacePage
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        final parking = widget.item.toParking();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReserveSpacePage(parking: parking)),
        );
      },
      child: Material(
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
                    child: Image.network(
                      heroImg,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: const Color(0xFFE7ECF3),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                      loadingBuilder:
                          (c, child, p) =>
                              p == null ? child : const _ImageShimmer(),
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
                      onPressed: () async {
                        setState(() => _fav = !_fav);
                        try {
                          if (!_fav) {
                            await FavoriteService.instance.removeByDocId(
                              widget.item.id,
                            );
                          }
                        } catch (_) {
                          setState(() => _fav = !_fav);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo actualizar favorito'),
                              ),
                            );
                          }
                        }
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
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: navy),
                      const SizedBox(width: 6),
                      MyText(
                        text: 'Q${widget.item.price}',
                        variant: MyTextVariant.body,
                        fontSize: 13,
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.local_parking, size: 16, color: navy),
                      const SizedBox(width: 6),
                      MyText(
                        text: 'Spaces: ${widget.item.spaces}',
                        variant: MyTextVariant.bodyMuted,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  if ((widget.item.descripcion ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    MyText(
                      text: widget.item.descripcion!,
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 12,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageShimmer extends StatelessWidget {
  const _ImageShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9EDF3),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _FavItem {
  final String id; // favorites doc id (uid_parkingId)
  final String parkingId; // <-- lo usamos para reconstruir Parking
  final String name;
  final String ownerID;
  final int price;
  final int spaces;
  final double rating;
  final String? imageUrl;
  final String? coverUrl;
  final List<String> photos;
  final String? descripcion;
  final double lat;
  final double lng;

  const _FavItem({
    required this.id,
    required this.parkingId,
    required this.name,
    required this.ownerID,
    required this.price,
    required this.spaces,
    required this.rating,
    required this.lat,
    required this.lng,
    this.imageUrl,
    this.coverUrl,
    this.photos = const [],
    this.descripcion,
  });

  // Prioridad para mostrar
  String? get heroImage {
    if (photos.isNotEmpty) return photos.first;
    return coverUrl ?? imageUrl;
  }

  /// Reconstruye un `Parking` para pantallas que lo necesitan (ReserveSpacePage).
  Parking toParking() => Parking(
    id: parkingId,
    lat: lat,
    lng: lng,
    name: name,
    ownerID: ownerID,
    price: price,
    spaces: spaces,
    rating: rating,
    originalPrice: null,
    imageUrl: imageUrl,
    localImagePath: null,
    descripcion: descripcion,
    coverUrl: coverUrl,
    photos: photos,
  );

  factory _FavItem.fromMap(String id, Map<String, dynamic> m) {
    double _d(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    List<String> _ls(dynamic v) =>
        (v is List)
            ? v
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList()
            : const <String>[];

    return _FavItem(
      id: id,
      parkingId:
          (m['parkingId'] ?? '') as String, // <- viene del FavoriteService
      name: m['name'] ?? 'Parking',
      ownerID: m['ownerID'] ?? '',
      price: (m['price'] ?? 0) as int,
      spaces: (m['spaces'] ?? 0) as int,
      rating: _d(m['rating'] ?? 0),
      imageUrl: m['imageUrl'] as String?,
      coverUrl: m['coverUrl'] as String?,
      photos: _ls(m['photos']),
      descripcion: m['descripcion'] as String?,
      lat: _d(m['lat']),
      lng: _d(m['lng']),
    );
  }
}
