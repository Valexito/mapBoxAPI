import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/features/auth/providers/auth_providers.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';
import 'package:mapbox_api/features/reservations/providers/reservations_providers.dart';

class ReservationsPage extends ConsumerStatefulWidget {
  const ReservationsPage({super.key});
  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage>
    with SingleTickerProviderStateMixin {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);
  late final TabController _tab = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(firebaseAuthProvider);
    if (auth.currentUser == null) {
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

    final asyncList = ref.watch(userReservationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            _Header(navyTop: navyTop, navyBottom: navyBottom),
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
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: asyncList.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (_, __) => const Center(
                        child: MyText(
                          text: 'Error loading reservations',
                          variant: MyTextVariant.bodyBold,
                        ),
                      ),
                  data: (all) {
                    final act =
                        all
                            .where((_) => true)
                            .toList(); // si luego manejas status, separa aquí
                    final com = <Reservation>[];
                    final can = <Reservation>[];

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

class _Header extends StatelessWidget {
  const _Header({required this.navyTop, required this.navyBottom});
  final Color navyTop;
  final Color navyBottom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [navyTop, navyBottom],
              ),
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
    );
  }
}

class _ResList extends StatelessWidget {
  final List<Reservation> items;
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
      itemBuilder: (_, i) {
        final r = items[i];
        return Card(
          elevation: 3,
          child: ListTile(
            leading: const Icon(Icons.local_parking),
            title: Text(r.parkingName),
            subtitle: Text('Espacio: ${r.spaceNumber}'),
            trailing: Text(
              _fmtDate(r.reservedAt),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  static String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
