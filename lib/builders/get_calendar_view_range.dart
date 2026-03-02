import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/calendar_controller.dart';
import '../models/view_range/calendar_view_range.dart';
import '../providers/calendar_view_range.dart';
import '../providers/selected_datetime.dart';

/// Builder callback signature for GetCalendarViewRange.
typedef CalendarViewRangeBuilder =
    Widget Function(
      CalendarController controller,
      CalendarViewRange range,
      DateTime selectedDateTime,
      void Function(DateTime) onChangeSelectedDateTime,
    );

class GetCalendarViewRange extends ConsumerWidget {
  const GetCalendarViewRange({super.key, required this.builder});

  final CalendarViewRangeBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rangeAsync = ref.watch(calendarViewRangeProvider);
    final controller = ref.watch(calendarViewRangeProvider.notifier);
    final selectedDateTime = ref.watch(selectedDateTimeProvider);

    return rangeAsync.when(
      data: (range) {
        return builder(
          controller,
          range,
          selectedDateTime,
          (dateTime) =>
              ref.read(selectedDateTimeProvider.notifier).state = dateTime,
        );
      },
      error: (e, st) => const Center(child: Text("Error Occurred")),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
