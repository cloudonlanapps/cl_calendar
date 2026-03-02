import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/calendar_header_config.dart';

/// Provider for calendar header configuration.
final calendarHeaderConfigProvider = StateProvider<CalendarHeaderConfig>((ref) {
  return CalendarHeaderConfig.full;
});
