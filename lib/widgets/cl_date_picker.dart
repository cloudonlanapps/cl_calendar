import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../builders/get_calendar_view_range.dart';
import '../models/calendar_header_config.dart';
import '../models/calendar_view_mode.dart';
import '../models/view_range/month_view_range.dart';
import '../providers/calendar_header_config.dart';
import '../providers/calendar_view_mode.dart';
import '../providers/calendar_view_range.dart';
import '../providers/popover_group_id.dart';
import '../providers/selected_datetime.dart';
import 'simple_calendar_view.dart';

/// A popover-style date picker that reuses the rich `cl_calendar` navigation
/// header (prev / Today / next + year-month picker) above a month grid.
///
/// The widget exposes a [child] that the host renders as the visible trigger
/// (e.g. a calendar icon, a button, a text field). Tapping the trigger opens
/// the popover; tapping a date cell fires [onDateSelected] with the picked
/// date and closes the popover.
///
/// Each popover instance lives in its own nested [ProviderScope], so multiple
/// pickers — or a picker rendered alongside an embedded calendar — do not
/// share selection state.
class CLDatePicker extends StatefulWidget {
  const CLDatePicker({
    required this.child,
    required this.onDateSelected,
    this.initialDate,
    this.width = 320,
    this.rowHeight = 40,
    this.headerHeight = 48,
    this.columnHeaderHeight = 28,
    this.yearsBefore = 50,
    this.yearsAfter = 50,
    super.key,
  });

  /// Visible trigger. Tapping this (anywhere in its hit-test area) opens the
  /// popover.
  final Widget child;

  /// Called with the selected date when the user taps a date cell. The
  /// popover is closed automatically after the callback fires.
  final ValueChanged<DateTime> onDateSelected;

  /// Date to highlight when the popover first opens. Defaults to today (UTC).
  final DateTime? initialDate;

  /// Popover width. The grid renders at this fixed width.
  final double width;

  /// Height of each week row in the month grid.
  final double rowHeight;

  /// Height of the navigation header inside the popover.
  final double headerHeight;

  /// Height of the column header (Mon, Tue, …).
  final double columnHeaderHeight;

  /// How many years before the reference date the year/month picker can
  /// navigate to. Defaults to 50 — generous for most date-of-birth or
  /// general-purpose date-picker scenarios. Lower it for forward-only
  /// pickers (e.g. booking flows) and raise it for historical pickers.
  final int yearsBefore;

  /// How many years after the reference date the year/month picker can
  /// navigate to. See [yearsBefore].
  final int yearsAfter;

  @override
  State<CLDatePicker> createState() => _ClDatePickerState();
}

class _ClDatePickerState extends State<CLDatePicker> {
  final ShadPopoverController popoverController = ShadPopoverController();

  /// Shared between the outer popover and the nested year/month popover so
  /// taps inside the nested overlay are not treated as outside-taps on the
  /// outer popover (which would otherwise dismiss it). A `Object()` per
  /// instance gives each popover its own unique group.
  final Object _popoverGroupId = Object();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.initialDate ?? DateTime.now().toUtc();
    // 6 grid rows accommodates every Gregorian month layout.
    final calendarHeight =
        widget.headerHeight + widget.columnHeaderHeight + widget.rowHeight * 6;

    return ShadPopover(
      controller: popoverController,
      groupId: _popoverGroupId,
      popover: (context) => SizedBox(
        width: widget.width,
        height: calendarHeight,
        child: ProviderScope(
          overrides: [
            selectedDateTimeProvider.overrideWith((ref) => initial),
            calendarHeaderConfigProvider.overrideWith(
              (ref) => CalendarHeaderConfig(
                showViewToggle: false,
                reserveViewToggleSpace: true,
                yearsBefore: widget.yearsBefore,
                yearsAfter: widget.yearsAfter,
              ),
            ),
            calendarViewModeProvider.overrideWith(
              (ref) => CalendarViewMode.month,
            ),
            calendarPopoverGroupIdProvider.overrideWith(
              (ref) => _popoverGroupId,
            ),
            // Re-override the dependent provider so Riverpod's transitive
            // override check is satisfied — `calendarViewRangeProvider` is
            // declared without `dependencies:`, so it cannot inherit our
            // overrides without being explicitly re-declared in this scope.
            calendarViewRangeProvider.overrideWith(
              CalendarViewRangeNotifier.new,
            ),
          ],
          child: _ClDatePickerBody(
            initial: initial,
            rowHeight: widget.rowHeight,
            headerHeight: widget.headerHeight,
            columnHeaderHeight: widget.columnHeaderHeight,
            onDateSelected: (date) {
              popoverController.hide();
              widget.onDateSelected(date);
            },
          ),
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: popoverController.toggle,
        child: widget.child,
      ),
    );
  }
}

class _ClDatePickerBody extends ConsumerWidget {
  const _ClDatePickerBody({
    required this.initial,
    required this.rowHeight,
    required this.headerHeight,
    required this.columnHeaderHeight,
    required this.onDateSelected,
  });

  final DateTime initial;
  final double rowHeight;
  final double headerHeight;
  final double columnHeaderHeight;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Forward selection changes to the host. The provider seeds with [initial]
    // so the first user tap is always a real change.
    ref.listen<DateTime>(selectedDateTimeProvider, (prev, next) {
      if (next != initial && (prev == null || prev != next)) {
        onDateSelected(next);
      }
    });

    return GetCalendarViewRange(
      builder: (controller, range, selectedDateTime, onChange) {
        // Date-picker popover is month-only; the override above guarantees a
        // MonthViewRange, but guard defensively.
        if (range is! MonthViewRange) {
          return const SizedBox.shrink();
        }
        return SimpleCalendarView(
          controller: controller,
          range: range,
          rowHeight: () => rowHeight,
          headerHeight: () => headerHeight,
          columnHeaderHeight: () => columnHeaderHeight,
        );
      },
    );
  }
}
