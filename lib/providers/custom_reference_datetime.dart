import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom reference date set by the user (used when useLiveTimeProvider is false).
/// Defaults to January 1, 2026.
final customReferenceDateTimeUtcProvider = StateProvider<DateTime>((ref) {
  return DateTime.utc(2026, 1, 1, 9, 0);
});
