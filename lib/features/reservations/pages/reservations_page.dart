import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage>
    with SingleTickerProviderStateMixin {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Stream<List<_ResItem>> _streamUserReservations() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    // TIP: si Firestore te pide un índice, abre el link que muestra en consola una vez.
    return FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: uid)
        .orderBy('reservedAt', descending: true)
        .snapshots()
        .map(
          (qs) =>
              qs.docs
                  .map((d) => _ResItem.fromFirestore(d.id, d.data()))
                  .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    const headerH = 160.0;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F4F7),
        body: Center(
          child: MyText(
            text: 'Please sign in to view your reservations',
            variant: MyTextVariant.body,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER navy (con back) =====
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
                      text: 'MY RESERVATIONS',
                      variant: MyTextVariant.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // ===== CARD con tabs =====
            Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                    child: TabBar(
                      controller: _tab,
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(color: navyBottom, width: 2.2),
                        insets: EdgeInsets.symmetric(horizontal: 24),
                      ),
                      dividerColor: Colors.transparent,
                      overlayColor: MaterialStatePropertyAll(
                        Colors.transparent,
                      ),
                      splashFactory: NoSplash.splashFactory,
                      labelColor: navyBottom,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: 'Active'),
                        Tab(text: 'Completed'),
                        Tab(text: 'Cancelled'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===== LISTAS =====
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: StreamBuilder<List<_ResItem>>(
                  stream: _streamUserReservations(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return const _ErrorState();
                    }

                    final all = snap.data ?? const <_ResItem>[];
                    final act = all.where((e) => e.status == 'active').toList();
                    final com =
                        all.where((e) => e.status == 'completed').toList();
                    final can =
                        all.where((e) => e.status == 'cancelled').toList();

                    return TabBarView(
                      controller: _tab,
                      children: [
                        _ResList(items: act),
                        _ResList(items: com),
                        _ResList(items: can),
                      ],
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

class _ResList extends StatelessWidget {
  final List<_ResItem> items;
  const _ResList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: MyText(
          text: 'No hay reservas aquí',
          variant: MyTextVariant.bodyMuted,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ReservationCard(item: items[i]),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final _ResItem item;
  const _ReservationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1B3A57);

    return Material(
      elevation: 3,
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          children: [
            Row(
              children: [
                // Thumbnail
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF2F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      item.imageUrl == null || item.imageUrl!.isEmpty
                          ? const Icon(
                            Icons.local_parking,
                            color: navy,
                            size: 32,
                          )
                          : Image.network(item.imageUrl!, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: item.name,
                        variant: MyTextVariant.bodyBold,
                        fontSize: 15,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16, color: navy),
                          const SizedBox(width: 6),
                          MyText(
                            text:
                                item.minutes != null
                                    ? '${item.minutes} min'
                                    : '—',
                            variant: MyTextVariant.body,
                            fontSize: 13,
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: navy,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: MyText(
                              text:
                                  (item.address?.isEmpty ?? true)
                                      ? 'Ubicación disponible'
                                      : item.address!,
                              variant: MyTextVariant.bodyMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (item.reservedAt != null) ...[
                        const SizedBox(height: 4),
                        MyText(
                          text: _fmtDate(item.reservedAt!),
                          variant: MyTextVariant.bodyMuted,
                          fontSize: 12,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Botón Ver ruta / Re-Book
            SizedBox(
              height: 44,
              width: double.infinity,
              child: MyButton(
                text: item.status == 'active' ? 'Ver ruta' : 'Re-Book',
                onTap: () {
                  if (item.status == 'active' &&
                      item.lat != null &&
                      item.lng != null) {
                    Navigator.pushNamed(
                      context,
                      '/routeView',
                      arguments: {
                        'destination': LatLng(item.lat!, item.lng!),
                        'parkingName': item.name,
                      },
                    );
                  } else {
                    // aquí puedes navegar al flujo de nueva reserva
                    // Navigator.pushNamed(context, '/reserve', arguments: {...});
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy  $hh:$min';
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: MyText(
          text: 'Error loading reservations',
          variant: MyTextVariant.bodyBold,
        ),
      ),
    );
  }
}

class _ResItem {
  final String id;
  final String parkingId;
  final String name;
  final String? address;
  final int? minutes;
  final String status; // active/completed/cancelled
  final String? imageUrl;
  final DateTime? reservedAt;
  final double? lat;
  final double? lng;

  const _ResItem({
    required this.id,
    required this.parkingId,
    required this.name,
    required this.status,
    this.address,
    this.minutes,
    this.imageUrl,
    this.reservedAt,
    this.lat,
    this.lng,
  });

  factory _ResItem.fromFirestore(String id, Map<String, dynamic> data) {
    // Campos tolerantes a null/ausentes para evitar crasheos en prod
    DateTime? reserved;
    final ts = data['reservedAt'];
    if (ts is Timestamp) reserved = ts.toDate();
    if (ts is DateTime) reserved = ts;

    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return _ResItem(
      id: id,
      parkingId: (data['parkingId'] ?? '') as String,
      name: (data['parkingName'] ?? 'Parking') as String,
      address: data['address'] as String?,
      minutes: (data['minutes'] is int) ? data['minutes'] as int : null,
      status: (data['status'] ?? 'active') as String,
      imageUrl: data['imageUrl'] as String?,
      reservedAt: reserved,
      lat: _toDouble(data['lat']),
      lng: _toDouble(data['lng']),
    );
  }
}
