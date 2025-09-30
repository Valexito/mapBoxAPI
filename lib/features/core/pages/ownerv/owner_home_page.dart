import 'package:flutter/material.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/features/core/pages/ownerv/owner_earnings_page.dart';
import 'package:mapbox_api/features/core/pages/ownerv/owner_parking_list_page.dart';
import 'package:mapbox_api/features/core/pages/ownerv/owner_reservations_page.dart';
import 'package:mapbox_api/features/core/pages/ownerv/owner_settings_page.dart';

import 'package:mapbox_api/features/core/roles/role_utils.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  int _index = 0;

  final _tabs = const <_TabItem>[
    _TabItem('Parqueos', Icons.local_parking_outlined),
    _TabItem('Reservas', Icons.receipt_long_outlined),
    _TabItem('Ganancias', Icons.payments_outlined),
    _TabItem('Ajustes', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    // Protege todo el shell: OwnerOnly
    return OwnerOnly(
      builder: (_) {
        final pages = const [
          OwnerParkingListPage(),
          OwnerReservationsPage(),
          OwnerEarningsPage(),
          OwnerSettingsPage(),
        ];
        return Scaffold(
          backgroundColor: AppColors.pageBg,
          appBar: AppBar(
            title: Text(_tabs[_index].label),
            centerTitle: true,
            backgroundColor: AppColors.navyBottom,
          ),
          body: pages[_index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations:
                _tabs
                    .map(
                      (t) => NavigationDestination(
                        icon: Icon(t.icon),
                        label: t.label,
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem(this.label, this.icon);
}
