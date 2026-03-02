import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/calendar_view_mode.dart';

final calendarViewModeProvider = StateProvider<CalendarViewMode>((ref) {
  return CalendarViewMode.month;
});
