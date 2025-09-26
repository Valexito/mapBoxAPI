import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/navy_header.dart';
import 'package:mapbox_api/features/core/providers/firebase_providers.dart';
import 'package:mapbox_api/features/reservations/components/reservations_details_sheet.dart';
import 'package:mapbox_api/features/reservations/models/reservation.dart';
import 'package:mapbox_api/features/reservations/providers/reservations_providers.dart';

class ReservationsPage extends ConsumerStatefulWidget {
  const ReservationsPage({super.key});
  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage>
    with SingleTickerProviderStateMixin {
  static const navyBottom = Color(0xFF1B3A57);
  static const bg = Color(0xFFF2F4F7);

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
        backgroundColor: bg,
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
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header consistente
            const NavyHeader(
              height: 150,
              roundedBottom: false,
              children: [
                MyText(
                  text: 'MIS RESERVACIONES',
                  variant: MyTextVariant.title,
                  textAlign: TextAlign.center,
                  customColor: Colors.white,
                ),
              ],
            ),

            Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _SegmentTabs(controller: _tab),
              ),
            ),

            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: asyncList.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (e, __) => const Center(
                        child: MyText(
                          text: 'Error loading reservations',
                          variant: MyTextVariant.bodyBold,
                        ),
                      ),
                  data: (all) {
                    final active =
                        all.where((r) => r.state == 'Acitvo').toList();
                    final completed =
                        all.where((r) => r.state == 'Completado').toList();
                    final cancelled =
                        all.where((r) => r.state == 'Cancelado').toList();

                    return TabBarView(
                      controller: _tab,
                      children: [
                        _ResList(items: active),
                        _ResList(items: completed),
                        _ResList(items: cancelled),
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

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    const navyBottom = _ReservationsPageState.navyBottom;
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(22),
      color: Colors.white,
      child: Container(
        height: 54,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
        ),
        child: TabBar(
          controller: controller,
          labelPadding: EdgeInsets.zero,
          indicator: BoxDecoration(
            color: const Color(0xFFEAF0F7),
            borderRadius: BorderRadius.circular(16),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
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
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ReservationCard(r: items[i]),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.r});
  final Reservation r;

  @override
  Widget build(BuildContext context) {
    const navyBottom = _ReservationsPageState.navyBottom;
    final dt = r.startedAt;
    final day = dt.day.toString().padLeft(2, '0');
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final mon = months[(dt.month - 1).clamp(0, 11)];
    final hh = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final am = dt.hour < 12 ? 'AM' : 'PM';
    final time = '$hh:$mm $am';
    final priceText =
        r.amount != null
            ? 'Q${r.amount}'
            : (r.pricePerHour != null ? 'Q${r.pricePerHour}/h' : 'Q—');

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ReservationDetailsSheet(reservation: r),
        );
      },
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 2),
                    MyText(
                      text: mon.toUpperCase(),
                      variant: MyTextVariant.bodyBold,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 2),
                    MyText(
                      text: day,
                      variant: MyTextVariant.title,
                      fontSize: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: r.parkingName,
                      variant: MyTextVariant.bodyBold,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        MyText(
                          text: time,
                          variant: MyTextVariant.body,
                          fontSize: 13,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_parking,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        MyText(
                          text: 'Espacio ${r.spaceNumber}',
                          variant: MyTextVariant.body,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MyText(
                text: priceText,
                variant: MyTextVariant.bodyBold,
                fontSize: 14,
                textAlign: TextAlign.right,
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: navyBottom),
            ],
          ),
        ),
      ),
    );
  }
}
