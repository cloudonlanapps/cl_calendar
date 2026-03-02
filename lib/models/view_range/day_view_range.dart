import 'dart:convert';

import 'package:flutter/material.dart';

import 'calendar_view_range.dart';

@immutable
class DayViewRange extends CalendarViewRange {
  factory DayViewRange.fromMap(Map<String, dynamic> map) {
    return DayViewRange._(
      date: DateTime.fromMillisecondsSinceEpoch(
        map['date'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  factory DayViewRange.fromJson(String source) =>
      DayViewRange.fromMap(json.decode(source) as Map<String, dynamic>);
  const DayViewRange._({required DateTime date})
    : super(start: date, end: date);

  factory DayViewRange.fromDate(DateTime date) {
    return DayViewRange._(date: DateUtils.dateOnly(date));
  }

  DateTime get date => start;

  @override
  DayViewRange next() =>
      DayViewRange._(date: start.add(const Duration(days: 1)));

  @override
  DayViewRange prev() =>
      DayViewRange._(date: start.subtract(const Duration(days: 1)));

  DayViewRange copyWith({DateTime? date}) {
    return DayViewRange._(date: date ?? this.date);
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'DayViewRange(date: $date, start: $start, end: $end)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayViewRange &&
        other.date == date &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => date.hashCode ^ start.hashCode ^ end.hashCode;
}
