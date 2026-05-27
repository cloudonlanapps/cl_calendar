import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/view_range/calendar_view_range.dart';
import '../models/view_range/month_view_range.dart';
import '../models/view_range/week_view_range.dart';
import '../providers/calendar_view_range.dart';
import '../providers/popover_group_id.dart';
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

  /// When true, the popover shows a 4×3 grid of years (decade view) instead
  /// of the month grid. Tapping a year sets [_pendingYear] and returns to
  /// the month grid so the user can pick the month.
  bool _showYearGrid = false;

  /// Top-left year of the currently displayed 12-year window. Recomputed
  /// whenever the year-grid is opened so it always shows the page that
  /// contains the currently-selected year.
  int? _yearGridBase;

  @override
  void initState() {
    super.initState();
    // Reset transient UI state when the popover closes.
    popoverController.addListener(_onPopoverStateChanged);
  }

  void _onPopoverStateChanged() {
    if (!popoverController.isOpen) {
      if (_pendingYear != null || _showYearGrid) {
        setState(() {
          _pendingYear = null;
          _showYearGrid = false;
          _yearGridBase = null;
        });
      }
    }
  }

  static const int _yearsPerPage = 12;

  /// Round a year down to the start of a 12-year page.
  int _pageBaseFor(int year) => year - (year % _yearsPerPage);

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

    final groupId = ref.watch(calendarPopoverGroupIdProvider);

    return ShadPopover(
      controller: popoverController,
      groupId: groupId,
      popover: (context) => SizedBox(
        width: 280,
        // Small extra vertical breathing room on top of ShadPopover's
        // default padding (EdgeInsets.symmetric(horizontal: 12, vertical: 6)).
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _showYearGrid
              ? _buildYearGrid(
                  theme,
                  effectiveYear: _pendingYear ?? currentYear,
                  startYear: startYear,
                  endYear: endYear,
                )
              : _buildMonthGrid(
                  theme,
                  currentYear: currentYear,
                  currentMonth: currentMonth,
                  startYear: startYear,
                  endYear: endYear,
                ),
        ),
      ),
      child: GestureDetector(
        onTap: popoverController.toggle,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
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
      ),
    );
  }

  /// Month-grid view: 3×4 grid of month abbreviations with year stepper.
  /// Tapping the year text switches into the year-grid view.
  Widget _buildMonthGrid(
    ShadThemeData theme, {
    required int currentYear,
    required int currentMonth,
    required int startYear,
    required int endYear,
  }) {
    return Column(
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
                            _pendingYear = (_pendingYear ?? currentYear) - 1;
                          });
                        }
                      : null,
                  child: const Icon(Icons.chevron_left, size: 18),
                ),
                // Tappable year — opens the year-grid for fast jumps.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _showYearGrid = true;
                      _yearGridBase = _pageBaseFor(
                        _pendingYear ?? currentYear,
                      );
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        (_pendingYear ?? currentYear).toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.p.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                            _pendingYear = (_pendingYear ?? currentYear) + 1;
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
            final effectiveYear = _pendingYear ?? currentYear;
            final isSelected =
                currentMonth == monthIndex && _pendingYear == null;
            void onPressed() {
              final newDate = DateTime.utc(effectiveYear, monthIndex);
              ref.read(calendarViewRangeProvider.notifier).jumpTo(newDate);
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
            }
            return ShadButton.ghost(
              padding: EdgeInsets.zero,
              onPressed: onPressed,
              child: label,
            );
          },
        ),
      ],
    );
  }

  /// Year-grid view: 4×3 grid of 12 years per page. Arrows page by 12 years
  /// (one decade-and-a-bit). Tapping a year sets the pending year and
  /// returns to the month-grid view.
  Widget _buildYearGrid(
    ShadThemeData theme, {
    required int effectiveYear,
    required int startYear,
    required int endYear,
  }) {
    final base = _yearGridBase ?? _pageBaseFor(effectiveYear);
    final pageEnd = base + _yearsPerPage - 1;
    final canPagePrev = base - _yearsPerPage >= startYear - (_yearsPerPage - 1);
    final canPageNext = base + _yearsPerPage <= endYear;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Year', style: theme.textTheme.muted),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShadButton.ghost(
                  padding: EdgeInsets.zero,
                  width: 32,
                  height: 32,
                  onPressed: canPagePrev
                      ? () => setState(() {
                          _yearGridBase = base - _yearsPerPage;
                        })
                      : null,
                  child: const Icon(Icons.chevron_left, size: 18),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '$base – $pageEnd',
                    textAlign: TextAlign.center,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: theme.textTheme.p.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ShadButton.ghost(
                  padding: EdgeInsets.zero,
                  width: 32,
                  height: 32,
                  onPressed: canPageNext
                      ? () => setState(() {
                          _yearGridBase = base + _yearsPerPage;
                        })
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
          itemCount: _yearsPerPage,
          itemBuilder: (context, index) {
            final year = base + index;
            final isInRange = year >= startYear && year <= endYear;
            final isSelected = year == effectiveYear;
            void onPressed() {
              setState(() {
                _pendingYear = year;
                _showYearGrid = false;
              });
            }

            final label = Text(year.toString());
            if (!isInRange) {
              return ShadButton.ghost(
                padding: EdgeInsets.zero,
                child: label,
              );
            }
            if (isSelected) {
              return ShadButton(
                padding: EdgeInsets.zero,
                onPressed: onPressed,
                child: label,
              );
            }
            return ShadButton.ghost(
              padding: EdgeInsets.zero,
              onPressed: onPressed,
              child: label,
            );
          },
        ),
      ],
    );
  }
}
