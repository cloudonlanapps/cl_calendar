import 'package:flutter/material.dart';

import '../models/calendar_controller.dart';
import '../models/view_range/calendar_view_range.dart';

/// Abstract calendar view widget - renders a single calendar view.
/// No page transitions - that's handled by the parent wrapper.
abstract class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    required this.controller,
    required this.range,
    super.key,
    this.rowHeight,
    this.headerHeight,
    this.columnHeaderHeight,
    this.headerBuilder,
    this.columnHeaderBuilder,
    this.dateBuilder,
    this.slotBuilder,
    this.cellBorder,
  });

  final CalendarController controller;
  final CalendarViewRange range;
  final double? Function()? rowHeight;
  final double? Function()? headerHeight;
  final double? Function()? columnHeaderHeight;

  /// Builder for the calendar header. If null, uses CalendarNavigationHeader.
  final Widget Function(CalendarViewRange currentRange, Size size)?
  headerBuilder;

  /// Builder for column headers (weekday names). If null, uses default weekday labels.
  final Widget Function(int dayIndex, Size size)? columnHeaderBuilder;

  /// Builder for month view day cells. If null, uses default day number display.
  final Widget Function(DateTime date, Size size)? dateBuilder;

  /// Builder for week/day view 30-minute time slots. If null, uses empty container.
  final Widget Function(DateTime slotTime, Size size)? slotBuilder;

  final BorderSide? cellBorder;
}
