import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'custom_reference_datetime.dart';
import 'use_live_time.dart';

/// The reference date used as "current time" throughout the app.
/// Returns DateTime.now().toUtc() if useLiveTimeProvider is true,
/// otherwise returns the custom time.
final referenceDateTimeUtcProvider = Provider<DateTime?>((ref) {
  final useLive = ref.watch(useLiveTimeProvider);
  if (useLive) {
    return null;
  }
  return ref.watch(customReferenceDateTimeUtcProvider);
});
