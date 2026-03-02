import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/selected_datetime.dart';

/// Builder callback signature for GetSelectedDate.
typedef SelectedDateBuilder =
    Widget Function(
      DateTime selectedDate,
      void Function(DateTime) onSelectDate,
    );

/// Builder widget that provides the selected date and a callback to change it.
/// Use this when you only need access to the selected date without the full
/// calendar view range.
class GetSelectedDate extends ConsumerWidget {
  const GetSelectedDate({super.key, required this.builder});

  final SelectedDateBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateTimeProvider);

    return builder(
      selectedDate,
      (dateTime) =>
          ref.read(selectedDateTimeProvider.notifier).state = dateTime,
    );
  }
}
