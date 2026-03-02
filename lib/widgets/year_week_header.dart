import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/view_range/week_view_range.dart';
import '../providers/calendar_view_range.dart';
import '../providers/reference_datetime.dart';
import '../providers/selected_datetime.dart';

/// Year and Week picker header for week view navigation.
/// Shows weeks as start dates (e.g., "23 Feb") for easy selection.
class YearWeekHeader extends ConsumerStatefulWidget {
  const YearWeekHeader({super.key, this.yearsBefore = 2, this.yearsAfter = 4});

  final int yearsBefore;
  final int yearsAfter;

  @override
  ConsumerState<YearWeekHeader> createState() => _YearWeekHeaderState();
}

class _YearWeekHeaderState extends ConsumerState<YearWeekHeader> {
  final popoverController = ShadPopoverController();

  // Internal state to track selected year/month before week is picked
  int? _pendingYear;
  int? _pendingMonth;

  static const _shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    popoverController.addListener(_onPopoverStateChanged);
  }

  void _onPopoverStateChanged() {
    if (!popoverController.isOpen) {
      setState(() {
        _pendingYear = null;
        _pendingMonth = null;
      });
    }
  }

  @override
  void dispose() {
    popoverController.removeListener(_onPopoverStateChanged);
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final rangeAsync = ref.watch(calendarViewRangeProvider);
    final referenceDate = ref.watch(referenceDateTimeUtcProvider);

    return rangeAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (range) => _buildHeader(context, theme, range, referenceDate),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ShadThemeData theme,
    dynamic range,
    DateTime referenceDate,
  ) {
    if (range is! WeekViewRange) {
      return const SizedBox.shrink();
    }

    final start = range.start;
    final end = range.end.subtract(const Duration(days: 1));

    final currentYear = start.year;
    final currentMonth = start.month;
    final localReferenceDate = referenceDate.toLocal();
    final startYear = localReferenceDate.year - widget.yearsBefore;
    final endYear = localReferenceDate.year + widget.yearsAfter;

    // Format the display text: "23 Feb - 1 Mar 2025"
    final String rangeText;
    if (start.month == end.month) {
      rangeText =
          '${start.day} - ${end.day} ${_shortMonthNames[end.month - 1]} ${end.year}';
    } else if (start.year == end.year) {
      rangeText =
          '${start.day} ${_shortMonthNames[start.month - 1]} - ${end.day} ${_shortMonthNames[end.month - 1]} ${end.year}';
    } else {
      rangeText =
          '${start.day} ${_shortMonthNames[start.month - 1]} ${start.year} - ${end.day} ${_shortMonthNames[end.month - 1]} ${end.year}';
    }

    final effectiveYear = _pendingYear ?? currentYear;
    final effectiveMonth = _pendingMonth ?? currentMonth;

    // Get all Mondays (week starts) for the selected month
    final weeksInMonth = _getWeekStartsInMonth(effectiveYear, effectiveMonth);

    return ShadPopover(
      controller: popoverController,
      popover: (context) => ShadCard(
        width: 280,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year navigation row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShadButton.ghost(
                  padding: EdgeInsets.zero,
                  width: 32,
                  height: 32,
                  onPressed: effectiveYear > startYear
                      ? () {
                          setState(() {
                            _pendingYear = effectiveYear - 1;
                          });
                        }
                      : null,
                  child: const Icon(Icons.chevron_left, size: 18),
                ),
                Text(
                  effectiveYear.toString(),
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ShadButton.ghost(
                  padding: EdgeInsets.zero,
                  width: 32,
                  height: 32,
                  onPressed: effectiveYear < endYear
                      ? () {
                          setState(() {
                            _pendingYear = effectiveYear + 1;
                          });
                        }
                      : null,
                  child: const Icon(Icons.chevron_right, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Month selector
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 12,
                itemBuilder: (context, index) {
                  final monthNum = index + 1;
                  final isSelected = effectiveMonth == monthNum;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: isSelected
                        ? ShadButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            height: 32,
                            onPressed: () {},
                            child: Text(_shortMonthNames[index]),
                          )
                        : ShadButton.ghost(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            height: 32,
                            onPressed: () {
                              setState(() {
                                _pendingMonth = monthNum;
                              });
                            },
                            child: Text(_shortMonthNames[index]),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Weeks in selected month
            Text('Select week starting:', style: theme.textTheme.muted),
            const SizedBox(height: 8),
            ...weeksInMonth.map((weekStart) {
              final weekEnd = weekStart.add(const Duration(days: 6));
              final isCurrentWeek = weekStart.isAtSameMomentAs(start);

              final label =
                  '${weekStart.day} ${_shortMonthNames[weekStart.month - 1]} - ${weekEnd.day} ${_shortMonthNames[weekEnd.month - 1]}';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: SizedBox(
                  width: double.infinity,
                  child:
                      isCurrentWeek &&
                          _pendingYear == null &&
                          _pendingMonth == null
                      ? ShadButton(
                          onPressed: () => _selectWeek(weekStart),
                          child: Text(label),
                        )
                      : ShadButton.outline(
                          onPressed: () => _selectWeek(weekStart),
                          child: Text(label),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
      child: InkWell(
        onTap: () => popoverController.toggle(),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rangeText,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: theme.colorScheme.foreground,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectWeek(DateTime weekStart) {
    ref.read(calendarViewRangeProvider.notifier).jumpTo(weekStart);
    ref.read(selectedDateTimeProvider.notifier).state = weekStart;
    setState(() {
      _pendingYear = null;
      _pendingMonth = null;
    });
    popoverController.hide();
  }

  /// Get all week start dates (Mondays) that have days in the given month
  List<DateTime> _getWeekStartsInMonth(int year, int month) {
    final weeks = <DateTime>[];

    // Start from the Monday of the week containing the 1st of the month
    var firstOfMonth = DateTime(year, month, 1);
    var monday = firstOfMonth.subtract(
      Duration(days: firstOfMonth.weekday - 1),
    );

    // Collect all Mondays until we pass the end of the month
    final lastOfMonth = DateTime(year, month + 1, 0);

    while (monday.isBefore(lastOfMonth) ||
        monday.isAtSameMomentAs(lastOfMonth)) {
      // Only include if the week has at least one day in this month
      final sunday = monday.add(const Duration(days: 6));
      if (sunday.month == month || monday.month == month) {
        weeks.add(monday);
      }
      monday = monday.add(const Duration(days: 7));
    }

    return weeks;
  }
}
