import 'package:flutter/foundation.dart';

/// Base sealed class for calendar view ranges.
@immutable
abstract class CalendarViewRange {
  const CalendarViewRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  int get dayCount => end.difference(start).inDays + 1;

  CalendarViewRange next();
  CalendarViewRange prev();

  @override
  String toString() => 'CalendarViewRange(start: $start, end: $end)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarViewRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
