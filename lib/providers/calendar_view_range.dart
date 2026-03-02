import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/calendar_controller.dart';
import '../models/calendar_view_mode.dart';
import '../models/view_range/calendar_view_range.dart';
import '../models/view_range/day_view_range.dart';
import '../models/view_range/month_view_range.dart';
import '../models/view_range/week_view_range.dart';
import 'calendar_view_mode.dart';
import 'selected_datetime.dart';

/// Provider family for calendar view range.
/// Pass the initial range to create a provider instance.
final calendarViewRangeProvider =
    AsyncNotifierProvider<CalendarViewRangeNotifier, CalendarViewRange>(
      CalendarViewRangeNotifier.new,
    );

/// AsyncNotifier that implements CalendarController interface.
/// Only manages navigation commands - no PageController.
class CalendarViewRangeNotifier extends AsyncNotifier<CalendarViewRange>
    implements CalendarController {
  @override
  Future<CalendarViewRange> build() async {
    final viewMode = ref.watch(calendarViewModeProvider);
    // Use read() instead of watch() - range should only update via explicit
    // jumpTo/next/previous calls, not when selectedDateTime changes
    final selectedDate = ref.read(selectedDateTimeProvider);

    return switch (viewMode) {
      CalendarViewMode.month => MonthViewRange.fromDate(selectedDate),
      CalendarViewMode.week => WeekViewRange.fromDate(selectedDate),
    };
  }

  @override
  void jumpTo(DateTime day) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncValue.data(switch (current) {
      MonthViewRange() => MonthViewRange.fromDate(day),
      WeekViewRange() => WeekViewRange.fromDate(day),
      DayViewRange() => DayViewRange.fromDate(day),
      _ => current,
    });
  }

  @override
  void next() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(current.next());
  }

  @override
  void previous() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(current.prev());
  }
}
