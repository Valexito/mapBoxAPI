import 'package:flutter/material.dart';
import 'package:mapbox_api/modules/user_parking/pages/route_view_page.dart';

class RouteViewPageWrapper extends StatelessWidget {
  const RouteViewPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return RouteViewPage(
      destination: args['destination'],
      parkingName: args['parkingName'],
    );
  }
}
