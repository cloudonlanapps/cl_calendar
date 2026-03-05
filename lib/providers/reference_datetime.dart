import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'custom_reference_datetime.dart';
import 'use_live_time.dart';

/// The reference date used as "current time" throughout the app.
/// Returns null if useLiveTimeProvider is true (SDK uses current time internally),
/// otherwise returns the custom time set by the user.
///
/// Note: Returning null for live time keeps provider family keys stable.
/// The SDK handles current time internally when null is passed.
final referenceDateTimeUtcProvider = Provider<DateTime?>((ref) {
  final useLive = ref.watch(useLiveTimeProvider);
  if (useLive) {
    return null;
  }
  return ref.watch(customReferenceDateTimeUtcProvider);
});
