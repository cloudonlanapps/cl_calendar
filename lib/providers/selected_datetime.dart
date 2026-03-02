import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reference_datetime.dart';

/// The currently selected date/time in the calendar.
/// Defaults to the reference date.
final selectedDateTimeProvider = StateProvider<DateTime>((ref) {
  return ref.read(referenceDateTimeUtcProvider);
});
