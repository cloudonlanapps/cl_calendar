import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'calendar_view_range.dart';

@immutable
class MonthViewRange extends CalendarViewRange {
  MonthViewRange({required this.year, required this.month})
      : super(
          start: DateTime(year, month, 1),
          end: DateTime(year, month + 1, 0),
        );

  final int year;
  final int month;

  int get daysInMonth => end.day;

  factory MonthViewRange.fromDate(DateTime date) {
    return MonthViewRange(year: date.year, month: date.month);
  }

  /// Builds grid of dates for this month. Always 6 rows.
  /// Each cell contains either a date or null (empty cell).
  List<List<DateTime?>> buildGrid() {
    final offset = start.weekday - 1; // 0 = Monday, 6 = Sunday
    int day = 1;

    return List.generate(6, (row) {
      return List.generate(7, (col) {
        final cell = row * 7 + col;
        if (cell < offset || day > daysInMonth) return null;
        return DateTime(year, month, day++);
      });
    });
  }

  @override
  MonthViewRange next() => month == 12
      ? MonthViewRange(year: year + 1, month: 1)
      : MonthViewRange(year: year, month: month + 1);

  @override
  MonthViewRange prev() => month == 1
      ? MonthViewRange(year: year - 1, month: 12)
      : MonthViewRange(year: year, month: month - 1);

  MonthViewRange copyWith({int? year, int? month}) {
    return MonthViewRange(
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    };
  }

  factory MonthViewRange.fromMap(Map<String, dynamic> map) {
    return MonthViewRange(
      year: map['year'] ?? 0,
      month: map['month'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory MonthViewRange.fromJson(String source) =>
      MonthViewRange.fromMap(json.decode(source));

  @override
  String toString() =>
      'MonthViewRange(year: $year, month: $month, start: $start, end: $end)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthViewRange &&
        other.year == year &&
        other.month == month &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode =>
      year.hashCode ^ month.hashCode ^ start.hashCode ^ end.hashCode;
}
