import 'dart:convert';

import 'package:flutter/material.dart';

import 'calendar_view_range.dart';

@immutable
class WeekViewRange extends CalendarViewRange {
  const WeekViewRange._({required super.start, required super.end});

  factory WeekViewRange.fromDate(DateTime date) {
    final d = DateUtils.dateOnly(date);
    final monday = d.subtract(Duration(days: d.weekday - 1));
    return WeekViewRange._(
      start: monday,
      end: monday.add(const Duration(days: 6)),
    );
  }

  List<DateTime> get days =>
      List.generate(7, (i) => start.add(Duration(days: i)));

  @override
  WeekViewRange next() =>
      WeekViewRange.fromDate(start.add(const Duration(days: 7)));

  @override
  WeekViewRange prev() =>
      WeekViewRange.fromDate(start.subtract(const Duration(days: 7)));

  WeekViewRange copyWith({DateTime? start, DateTime? end}) {
    return WeekViewRange._(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    };
  }

  factory WeekViewRange.fromMap(Map<String, dynamic> map) {
    final startDate = DateTime.fromMillisecondsSinceEpoch(
      map['start'] ?? DateTime.now().millisecondsSinceEpoch,
    );
    return WeekViewRange.fromDate(startDate);
  }

  String toJson() => json.encode(toMap());

  factory WeekViewRange.fromJson(String source) =>
      WeekViewRange.fromMap(json.decode(source));

  @override
  String toString() => 'WeekViewRange(start: $start, end: $end)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeekViewRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
