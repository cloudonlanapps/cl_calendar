import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The display range for the calendar (min/max navigable dates).
final displayRangeProvider = StateProvider<DateTimeRange>((ref) {
  return DateTimeRange(
    start: DateTime.utc(2024),
    end: DateTime.utc(2030),
  );
});
