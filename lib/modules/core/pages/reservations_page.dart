import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    return FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: uid)
        .orderBy('reservedAt', descending: true)
        .snapshots()
        .map(
          (qs) =>
              qs.docs.map((d) {
                final data = d.data();
                return _ResItem(
                  id: d.id,
                  parkingId: data['parkingId'] ?? '',
                  name: data['parkingName'] ?? 'Parking',
                  address: data['address'] ?? '',
                  minutes: data['minutes'] ?? 20,
                  imageUrl: data['imageUrl'],
                  status: (data['status'] ?? 'active') as String,
                  reservedAt: (data['reservedAt'] as Timestamp?)?.toDate(),
                );
              }).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    const headerH = 160.0;

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

                      // Mantener subrayado azul CORTO en el tab seleccionado
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(color: navyBottom, width: 2.2),
                        insets: EdgeInsets.symmetric(horizontal: 24),
                      ),

                      // Quitar la línea larga negra
                      dividerColor: Colors.transparent,

                      overlayColor: MaterialStateProperty.all(
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
                    final all = snap.data ?? _demo; // fallback demo
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
                      item.imageUrl == null
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
                            text: '${item.minutes} min',
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
                                  item.address.isEmpty
                                      ? 'Ubicación disponible'
                                      : item.address,
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

            const SizedBox(height: 10),

            // Botón Re-book / Ver ruta
            SizedBox(
              height: 44,
              width: double.infinity,
              child: MyButton(
                text: item.status == 'active' ? 'Ver ruta' : 'Re-Book',
                onTap: () {
                  // TODO: navegación a ruta o re-book
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResItem {
  final String id;
  final String parkingId;
  final String name;
  final String address;
  final int minutes;
  final String status; // active/completed/cancelled
  final String? imageUrl;
  final DateTime? reservedAt;

  _ResItem({
    required this.id,
    required this.parkingId,
    required this.name,
    required this.address,
    required this.minutes,
    required this.status,
    this.imageUrl,
    this.reservedAt,
  });
}

// ===== Demo data =====
final _demo = <_ResItem>[
  _ResItem(
    id: '1',
    parkingId: 'p1',
    name: 'Parqueo Central',
    address: '12 Av. Zona 3, Quetzaltenango',
    minutes: 8,
    status: 'active',
  ),
  _ResItem(
    id: '2',
    parkingId: 'p2',
    name: 'Garage Alameda',
    address: 'Alameda #27',
    minutes: 20,
    status: 'completed',
  ),
  _ResItem(
    id: '3',
    parkingId: 'p3',
    name: 'Shaddai Norte',
    address: 'Calz. San José',
    minutes: 15,
    status: 'cancelled',
  ),
];
