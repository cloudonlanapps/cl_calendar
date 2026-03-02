import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/view_range/calendar_view_range.dart';
import '../models/view_range/day_view_range.dart';
import '../models/view_range/week_view_range.dart' show WeekViewRange;
import '../providers/calendar_header_config.dart';
import '../providers/calendar_view_mode.dart';
import '../providers/calendar_view_range.dart';
import '../providers/display_range.dart';
import '../providers/reference_datetime.dart';
import '../providers/selected_datetime.dart';
import 'nav_button.dart';
import 'view_toggle.dart';
import 'year_month_header.dart';
import 'year_week_header.dart';

/// A reusable navigation header for calendar views.
/// Includes prev/next navigation, today button, date picker, and view toggle.
class CalendarNavigationHeader extends ConsumerWidget {
  const CalendarNavigationHeader({
    required this.range,
    required this.size,
    super.key,
  });

  final CalendarViewRange range;
  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final config = ref.watch(calendarHeaderConfigProvider);
    final displayRange = ref.watch(displayRangeProvider);
    final viewMode = ref.watch(calendarViewModeProvider);
    final controller = ref.watch(calendarViewRangeProvider.notifier);

    final isCompact = size.width < 400;

    // Determine if we're at the boundaries
    final isAtStart =
        range.start.isBefore(displayRange.start) ||
        range.start.isAtSameMomentAs(displayRange.start);
    final isAtEnd =
        range.end.isAfter(displayRange.end) ||
        range.end.isAtSameMomentAs(displayRange.end);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // Part 1: Navigation (arrows + today)
            if (config.showNavigationArrows) ...[
              NavButton(
                onTap: isAtStart ? null : controller.previous,
                child: Icon(
                  LucideIcons.chevronLeft,
                  size: 18,
                  color: isAtStart
                      ? theme.colorScheme.mutedForeground
                      : theme.colorScheme.foreground,
                ),
              ),
              NavButton(
                onTap: isAtEnd ? null : controller.next,
                child: Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: isAtEnd
                      ? theme.colorScheme.mutedForeground
                      : theme.colorScheme.foreground,
                ),
              ),
            ],
            if (config.showTodayButton && !isCompact)
              NavButton(
                onTap: () {
                  final refDate =
                      (ref.read(referenceDateTimeUtcProvider) ??
                              DateTime.now().toUtc())
                          .toLocal();
                  controller.jumpTo(refDate);
                  ref.read(selectedDateTimeProvider.notifier).state = refDate;
                },
                child: Text('Today', style: theme.textTheme.small),
              ),

            const Spacer(),

            // Part 2: Date navigation (center) - different for each view type
            if (config.showYearMonthPicker)
              _buildDateNavigation(context, ref, theme, controller),

            const Spacer(),

            // Part 3: View toggle (right)
            if (config.showViewToggle)
              ViewToggle(
                currentViewMode: viewMode,
                onViewModeChanged: (mode) {
                  ref.read(calendarViewModeProvider.notifier).state = mode;
                },
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavigation(
    BuildContext context,
    WidgetRef ref,
    ShadThemeData theme,
    CalendarViewRangeNotifier controller,
  ) {
    if (range is WeekViewRange) {
      return _buildWeekNavigation(context, ref, theme, controller);
    } else if (range is DayViewRange) {
      return _buildDayNavigation(context, ref, theme, controller);
    } else {
      return _buildMonthNavigation(context, ref, theme, controller);
    }
  }

  /// Week view: Uses YearWeekHeader for year/week selection
  Widget _buildWeekNavigation(
    BuildContext context,
    WidgetRef ref,
    ShadThemeData theme,
    CalendarViewRangeNotifier controller,
  ) {
    return const YearWeekHeader();
  }

  /// Day view: Shows "17 Mar 2025" with date picker
  Widget _buildDayNavigation(
    BuildContext context,
    WidgetRef ref,
    ShadThemeData theme,
    CalendarViewRangeNotifier controller,
  ) {
    final dayRange = range as DayViewRange;
    final date = dayRange.date;

    return ShadDatePicker(
      selected: date,
      formatDate: (d) => DateFormat('EEEE, d MMM yyyy').format(d),
      onChanged: (newDate) {
        if (newDate != null) {
          controller.jumpTo(newDate);
          ref.read(selectedDateTimeProvider.notifier).state = newDate;
        }
      },
    );
  }

  /// Month view: Uses YearMonthHeader for year/month selection
  Widget _buildMonthNavigation(
    BuildContext context,
    WidgetRef ref,
    ShadThemeData theme,
    CalendarViewRangeNotifier controller,
  ) {
    return const YearMonthHeader();
  }
}
