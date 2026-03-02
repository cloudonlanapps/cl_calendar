import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/resolved_sizes.dart';
import '../providers/reference_datetime.dart';
import '../providers/selected_datetime.dart';
import '../models/view_range/day_view_range.dart';
import '../models/view_range/month_view_range.dart';
import '../models/view_range/week_view_range.dart';
import 'calendar_navigation_header.dart';
import 'calendar_widget.dart';
import 'day_grid.dart';
import 'month_grid.dart';
import 'week_grid.dart';

/// Default heights.
const _kDefaultRowHeight = 48.0;
const _kDefaultHeaderHeight = 48.0;
const _kDefaultColumnHeaderHeight = 32.0;

/// Width of the time label column for hourly views.
const _kTimeLabelWidth = 50.0;

/// Simple calendar view - renders a single calendar for the given range.
/// No page transitions - parent wrapper handles that.
///
/// For MonthViewRange: Uses the traditional grid layout with dateBuilder.
/// For WeekViewRange/DayViewRange: Uses hourly strip view with 30-min slots.
/// The hourly views are scrollable and show events positioned at their times.
class SimpleCalendarView extends CalendarWidget {
  const SimpleCalendarView({
    super.key,
    required super.controller,
    required super.range,
    super.headerBuilder,
    super.columnHeaderBuilder,
    super.dateBuilder,
    super.slotBuilder,
    super.rowHeight,
    super.headerHeight,
    super.columnHeaderHeight,
    super.cellBorder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizes = _resolveSizes(constraints);
        final isHourlyView = range is WeekViewRange || range is DayViewRange;

        return Column(
          children: [
            // Header
            SizedBox(
              height: sizes.headerHeight,
              width: constraints.maxWidth,
              child: headerBuilder != null
                  ? headerBuilder!(
                      range,
                      Size(constraints.maxWidth, sizes.headerHeight),
                    )
                  : CalendarNavigationHeader(
                      range: range,
                      size: Size(constraints.maxWidth, sizes.headerHeight),
                    ),
            ),
            // Column headers (weekdays)
            // For hourly views, show date + day; for month view, just day name
            SizedBox(
              height: isHourlyView
                  ? sizes.columnHeaderHeight * 1.5
                  : sizes.columnHeaderHeight,
              child: Row(
                children: [
                  // Time label spacer for hourly views
                  if (isHourlyView && range is WeekViewRange)
                    SizedBox(width: _kTimeLabelWidth),
                  // Day headers
                  ..._buildColumnHeaders(
                    context,
                    constraints,
                    sizes,
                    isHourlyView,
                  ),
                ],
              ),
            ),
            // Calendar grid - uses all available space for hourly views
            Expanded(
              child: LayoutBuilder(
                builder: (context, gridConstraints) {
                  // For hourly views, pass actual available height
                  // For month view, use calculated rowHeight
                  final gridHeight = isHourlyView
                      ? gridConstraints.maxHeight
                      : sizes.rowHeight;
                  return _buildGrid(constraints.maxWidth, gridHeight);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Short weekday names (0 = Monday, 6 = Sunday).
  static const _shortDayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  List<Widget> _buildColumnHeaders(
    BuildContext context,
    BoxConstraints constraints,
    ResolvedSizes sizes,
    bool isHourlyView,
  ) {
    final theme = ShadTheme.of(context);

    if (range is WeekViewRange) {
      final weekRange = range as WeekViewRange;
      final availableWidth = constraints.maxWidth - _kTimeLabelWidth;
      final cellWidth = availableWidth / 7;
      final headerHeight = sizes.columnHeaderHeight * 1.5;

      return weekRange.days.map((date) {
        final dayName = _shortDayNames[date.weekday - 1];
        final isFirstOfMonth = date.day == 1;

        return SizedBox(
          width: cellWidth,
          height: headerHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: theme.textTheme.small.copyWith(
                  fontWeight: isFirstOfMonth
                      ? FontWeight.bold
                      : FontWeight.w400,
                  color: theme.colorScheme.foreground,
                ),
              ),
              Text(
                dayName,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        );
      }).toList();
    } else if (range is DayViewRange) {
      final dayRange = range as DayViewRange;
      final date = dayRange.date;
      final dayName = _shortDayNames[date.weekday - 1];
      final isFirstOfMonth = date.day == 1;
      final headerHeight = sizes.columnHeaderHeight * 1.5;

      return [
        Expanded(
          child: SizedBox(
            height: headerHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: theme.textTheme.small.copyWith(
                    fontWeight: isFirstOfMonth
                        ? FontWeight.bold
                        : FontWeight.w400,
                    color: theme.colorScheme.foreground,
                  ),
                ),
                Text(
                  dayName,
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    } else {
      // Month view - use the columnHeaderBuilder or default
      return List.generate(7, (index) {
        final cellWidth = constraints.maxWidth / 7;
        final size = Size(cellWidth, sizes.columnHeaderHeight);
        return SizedBox(
          width: cellWidth,
          height: sizes.columnHeaderHeight,
          child: columnHeaderBuilder != null
              ? columnHeaderBuilder!(index, size)
              : _DefaultColumnHeader(dayIndex: index),
        );
      });
    }
  }

  Widget _buildGrid(double width, double rowHeight) {
    // Default builders when not provided
    Widget defaultDateBuilder(DateTime date, Size size) =>
        _DefaultDateCell(date: date, size: size);
    Widget defaultSlotBuilder(DateTime slotTime, Size size) => const SizedBox();

    return switch (range) {
      MonthViewRange() => MonthGrid(
        range: range as MonthViewRange,
        width: width,
        rowHeight: rowHeight,
        dateBuilder: dateBuilder ?? defaultDateBuilder,
        cellBorder: cellBorder,
      ),
      WeekViewRange() => WeekGrid(
        range: range as WeekViewRange,
        width: width,
        rowHeight: rowHeight,
        slotBuilder: slotBuilder ?? defaultSlotBuilder,
        cellBorder: cellBorder,
      ),
      DayViewRange() => DayGrid(
        range: range as DayViewRange,
        width: width,
        rowHeight: rowHeight,
        slotBuilder: slotBuilder ?? defaultSlotBuilder,
        cellBorder: cellBorder,
      ),
      _ => const SizedBox(),
    };
  }

  ResolvedSizes _resolveSizes(BoxConstraints constraints) {
    double? row;
    if (rowHeight == null) {
      row = _kDefaultRowHeight;
    } else {
      row = rowHeight!();
    }

    double? colHeader;
    if (columnHeaderHeight == null) {
      colHeader = _kDefaultColumnHeaderHeight;
    } else {
      colHeader = columnHeaderHeight!();
      colHeader ??= row;
    }

    double? header;
    if (headerHeight == null) {
      header = _kDefaultHeaderHeight;
    } else {
      header = headerHeight!();
      header ??= colHeader;
    }

    if (row == null) {
      if (!constraints.hasBoundedHeight) {
        throw FlutterError(
          'CalendarView needs bounded height.\n'
          'Provide explicit rowHeight or wrap in SizedBox/Expanded.',
        );
      }
      final availableHeight =
          constraints.maxHeight - (header ?? 0) - (colHeader ?? 0);
      final rowCount = 6;
      row = availableHeight / rowCount;
    }

    colHeader ??= row;
    header ??= colHeader;

    return ResolvedSizes(
      rowHeight: row,
      columnHeaderHeight: colHeader,
      headerHeight: header,
    );
  }
}

/// Default column header showing weekday names.
class _DefaultColumnHeader extends StatelessWidget {
  const _DefaultColumnHeader({required this.dayIndex});

  final int dayIndex;

  static const _shortDayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Text(
        _shortDayNames[dayIndex],
        style: theme.textTheme.small.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }
}

/// Default date cell showing day number with today/selected highlighting.
class _DefaultDateCell extends ConsumerWidget {
  const _DefaultDateCell({required this.date, required this.size});

  final DateTime date;
  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refDate =
        ref.watch(referenceDateTimeUtcProvider) ?? DateTime.now().toUtc();
    final selectedDateTime = ref.watch(selectedDateTimeProvider);
    final isToday = DateUtils.isSameDay(date, refDate.toLocal());
    final isSelected = DateUtils.isSameDay(date, selectedDateTime);
    final theme = ShadTheme.of(context);

    // Determine background color with priority: selected > today
    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = theme.colorScheme.selection;
    } else if (isToday) {
      backgroundColor = theme.colorScheme.muted;
    }

    return GestureDetector(
      onTap: () => ref.read(selectedDateTimeProvider.notifier).state = date,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Container(
          decoration: BoxDecoration(color: backgroundColor),
          alignment: Alignment.center,
          child: Text(
            date.day.toString(),
            style: theme.textTheme.large.copyWith(
              color: isSelected ? theme.colorScheme.primaryForeground : null,
            ),
          ),
        ),
      ),
    );
  }
}
