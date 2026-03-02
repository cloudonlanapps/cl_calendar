import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/view_range/day_view_range.dart';
import '../providers/reference_datetime.dart';

/// Width of the time label column.
const double kTimeLabelWidth = 50.0;

/// Number of 30-minute slots in a day.
const int kSlotsPerDay = 48;

/// Minimum number of hours to display in visible area.
/// Set to 4 to make cells taller (double height compared to 8 hours)
const int kMinVisibleHours = 4;

/// Day grid showing a single day with hourly time slots.
/// Each slot is rendered using the provided slotBuilder.
/// The slot height is calculated to fit at least [kMinVisibleHours] hours in the visible area.
class DayGrid extends ConsumerStatefulWidget {
  const DayGrid({
    super.key,
    required this.range,
    required this.width,
    required this.rowHeight,
    required this.slotBuilder,
    this.cellBorder,
  });

  final DayViewRange range;
  final double width;

  /// Available height for the grid (used to calculate slot height)
  final double rowHeight;

  /// Builder for each 30-minute time slot.
  /// Receives the slot's DateTime and available size.
  final Widget Function(DateTime slotTime, Size size) slotBuilder;

  final BorderSide? cellBorder;

  @override
  ConsumerState<DayGrid> createState() => _DayGridState();
}

class _DayGridState extends ConsumerState<DayGrid> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToTime = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    if (_hasScrolledToTime) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients || !mounted) return;

      final refDate =
          (ref.read(referenceDateTimeUtcProvider) ?? DateTime.now().toUtc())
              .toLocal();
      final targetMinutes = refDate.hour * 60 + refDate.minute;

      final slotHeight = widget.rowHeight / (kMinVisibleHours * 2);
      final totalHeight = kSlotsPerDay * slotHeight;

      final targetOffset =
          (targetMinutes * slotHeight / 30) - (widget.rowHeight / 3);
      final clampedOffset = targetOffset.clamp(
        0.0,
        totalHeight - widget.rowHeight,
      );

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(clampedOffset);
        _hasScrolledToTime = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final refDate =
        ref.watch(referenceDateTimeUtcProvider) ?? DateTime.now().toUtc();

    final contentWidth = widget.width - kTimeLabelWidth;
    final slotHeight = widget.rowHeight / (kMinVisibleHours * 2);
    final totalHeight = kSlotsPerDay * slotHeight;

    final isToday = DateUtils.isSameDay(widget.range.date, refDate.toLocal());
    final currentTimeMinutes =
        refDate.toLocal().hour * 60 + refDate.toLocal().minute;

    _scrollToCurrentTime();

    return SingleChildScrollView(
      controller: _scrollController,
      child: SizedBox(
        height: totalHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time labels column
            SizedBox(
              width: kTimeLabelWidth,
              child: _buildTimeLabels(theme, slotHeight),
            ),
            // Day content area
            Expanded(
              child: Stack(
                children: [
                  _buildDayColumn(widget.range.date, contentWidth, slotHeight),
                  // Current time marker (only for today)
                  if (isToday)
                    _buildCurrentTimeMarker(
                      theme,
                      currentTimeMinutes,
                      slotHeight,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLabels(ShadThemeData theme, double slotHeight) {
    return Column(
      children: List.generate(24, (hour) {
        final timeText = '${hour.toString().padLeft(2, '0')}:00';
        return SizedBox(
          height: slotHeight * 2,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 4, top: 2),
              child: Text(
                timeText,
                style: theme.textTheme.muted.copyWith(fontSize: 10),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayColumn(
    DateTime date,
    double contentWidth,
    double slotHeight,
  ) {
    final cellSize = Size(contentWidth, slotHeight);
    final borderWidth = widget.cellBorder?.width ?? 0;

    return Column(
      children: List.generate(kSlotsPerDay, (slotIndex) {
        final slotHour = slotIndex ~/ 2;
        final slotMinute = (slotIndex % 2) * 30;
        final slotTime = DateTime(
          date.year,
          date.month,
          date.day,
          slotHour,
          slotMinute,
        );

        return Container(
          width: contentWidth,
          height: slotHeight,
          decoration: widget.cellBorder != null
              ? BoxDecoration(
                  border: Border.all(
                    color: widget.cellBorder!.color,
                    width: borderWidth,
                  ),
                )
              : null,
          child: widget.slotBuilder(slotTime, cellSize),
        );
      }),
    );
  }

  Widget _buildCurrentTimeMarker(
    ShadThemeData theme,
    int currentTimeMinutes,
    double slotHeight,
  ) {
    final borderWidth = widget.cellBorder?.width ?? 0;
    final top = currentTimeMinutes * slotHeight / 30 + borderWidth;

    return Positioned(
      top: top - 5,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: theme.colorScheme.destructive,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(height: 2, color: theme.colorScheme.destructive),
          ),
        ],
      ),
    );
  }
}
