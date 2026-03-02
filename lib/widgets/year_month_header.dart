import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/view_range/calendar_view_range.dart';
import '../models/view_range/month_view_range.dart';
import '../models/view_range/week_view_range.dart';
import '../providers/calendar_view_range.dart';
import '../providers/reference_datetime.dart';

class YearMonthHeader extends ConsumerStatefulWidget {
  const YearMonthHeader({super.key, this.yearsBefore = 2, this.yearsAfter = 4});

  final int yearsBefore;
  final int yearsAfter;

  @override
  ConsumerState<YearMonthHeader> createState() => _YearMonthHeaderState();
}

class _YearMonthHeaderState extends ConsumerState<YearMonthHeader> {
  final popoverController = ShadPopoverController();

  // Internal state to track selected year before month is picked
  int? _pendingYear;

  @override
  void initState() {
    super.initState();
    // Reset pending year when popover closes
    popoverController.addListener(_onPopoverStateChanged);
  }

  void _onPopoverStateChanged() {
    if (!popoverController.isOpen && _pendingYear != null) {
      setState(() {
        _pendingYear = null;
      });
    }
  }

  static const List<String> months = [
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
  void dispose() {
    popoverController
      ..removeListener(_onPopoverStateChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final rangeAsync = ref.watch(calendarViewRangeProvider);
    final referenceDate =
        ref.watch(referenceDateTimeUtcProvider) ?? DateTime.now().toUtc();

    return rangeAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (range) => _buildHeader(context, theme, range, referenceDate),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ShadThemeData theme,
    CalendarViewRange range,
    DateTime referenceDate,
  ) {
    // Determine the display date based on range type
    final DateTime displayDate;
    if (range is MonthViewRange) {
      displayDate = DateTime(range.year, range.month, 15);
    } else if (range is WeekViewRange) {
      // Use midpoint of the week
      displayDate = range.start.add(const Duration(days: 3));
    } else {
      displayDate = range.start;
    }

    final monthText = DateFormat('MMMM yyyy').format(displayDate.toLocal());
    final currentYear = displayDate.year;
    final currentMonth = displayDate.month;
    final localReferenceDate = referenceDate.toLocal();
    final startYear = localReferenceDate.year - widget.yearsBefore;
    final endYear = localReferenceDate.year + widget.yearsAfter;

    return ShadPopover(
      controller: popoverController,
      popover: (context) => ShadCard(
        width: 280,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Month', style: theme.textTheme.muted),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShadButton.ghost(
                      padding: EdgeInsets.zero,
                      width: 32,
                      height: 32,
                      onPressed: (_pendingYear ?? currentYear) > startYear
                          ? () {
                              setState(() {
                                _pendingYear =
                                    (_pendingYear ?? currentYear) - 1;
                              });
                            }
                          : null,
                      child: const Icon(Icons.chevron_left, size: 18),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        (_pendingYear ?? currentYear).toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.p.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ShadButton.ghost(
                      padding: EdgeInsets.zero,
                      width: 32,
                      height: 32,
                      onPressed: (_pendingYear ?? currentYear) < endYear
                          ? () {
                              setState(() {
                                _pendingYear =
                                    (_pendingYear ?? currentYear) + 1;
                              });
                            }
                          : null,
                      child: const Icon(Icons.chevron_right, size: 18),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.2,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthIndex = index + 1;
                // Use pending year if set, otherwise current year
                final effectiveYear = _pendingYear ?? currentYear;
                final isSelected =
                    currentMonth == monthIndex && _pendingYear == null;
                void onPressed() {
                  final newDate = DateTime.utc(effectiveYear, monthIndex);
                  ref.read(calendarViewRangeProvider.notifier).jumpTo(newDate);
                  // Reset pending year and close popover
                  setState(() {
                    _pendingYear = null;
                  });
                  popoverController.hide();
                }

                final label = Text(months[index]);

                if (isSelected) {
                  return ShadButton(
                    padding: EdgeInsets.zero,
                    onPressed: onPressed,
                    child: label,
                  );
                } else {
                  return ShadButton.ghost(
                    padding: EdgeInsets.zero,
                    onPressed: onPressed,
                    child: label,
                  );
                }
              },
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: popoverController.toggle,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                monthText,
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
}
