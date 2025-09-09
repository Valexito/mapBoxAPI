// features/core/providers/recent_searches_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recent_searches.dart';

final recentSearchesProvider = FutureProvider((_) => RecentSearches.load());

final addRecentSearchProvider = Provider<Future<void> Function(RecentItem)>((
  _,
) {
  return (item) => RecentSearches.add(item);
});

final clearRecentSearchesProvider = Provider<Future<void> Function()>((_) {
  return () => RecentSearches.clear();
});
