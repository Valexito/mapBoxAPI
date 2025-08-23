import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentItem {
  final String name;
  final String address;
  final double lat;
  final double lng;

  RecentItem({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'lat': lat,
    'lng': lng,
  };

  static RecentItem fromJson(Map<String, dynamic> m) => RecentItem(
    name: m['name'] ?? '',
    address: m['address'] ?? '',
    lat: (m['lat'] as num).toDouble(),
    lng: (m['lng'] as num).toDouble(),
  );
}

class RecentSearches {
  static const _kKey = 'recent_places';
  static const _kMax = 10;

  static Future<List<RecentItem>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_kKey) ?? [];
    return raw.map((s) => RecentItem.fromJson(json.decode(s))).toList();
  }

  static Future<void> add(RecentItem item) async {
    final sp = await SharedPreferences.getInstance();
    final list = await load();

    // evitar duplicados por address
    final i = list.indexWhere((e) => e.address == item.address);
    if (i >= 0) list.removeAt(i);

    list.insert(0, item);
    while (list.length > _kMax) list.removeLast();

    await sp.setStringList(
      _kKey,
      list.map((e) => json.encode(e.toJson())).toList(),
    );
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kKey);
  }
}
