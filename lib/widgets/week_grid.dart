import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/view_range/week_view_range.dart';
import '../providers/reference_datetime.dart';

/// Width of the time label column.
const double kTimeLabelWidth = 50.0;

/// Number of 30-minute slots in a day.
const int kSlotsPerDay = 48;

/// Minimum number of hours to display in visible area.
/// Set to 4 to make cells taller (double height compared to 8 hours)
const int kMinVisibleHours = 4;

/// Week grid showing 7 day columns with hourly time slots.
/// Each day column renders slots using the provided slotBuilder.
/// The slot height is calculated to fit at least [kMinVisibleHours] hours in the visible area.
class WeekGrid extends ConsumerStatefulWidget {
  const WeekGrid({
    super.key,
    required this.range,
    required this.width,
    required this.rowHeight,
    required this.slotBuilder,
    this.cellBorder,
  });

  final WeekViewRange range;
  final double width;

  /// Available height for the grid (used to calculate slot height)
  final double rowHeight;

  /// Builder for each 30-minute time slot.
  /// Receives the slot's DateTime and available size.
  final Widget Function(DateTime slotTime, Size size) slotBuilder;

  final BorderSide? cellBorder;

  @override
  ConsumerState<WeekGrid> createState() => _WeekGridState();
}

class _WeekGridState extends ConsumerState<WeekGrid> {
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

      final refDate = ref.read(referenceDateTimeUtcProvider).toLocal();
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
    final refDate = ref.watch(referenceDateTimeUtcProvider);

    final contentWidth = widget.width - kTimeLabelWidth;
    final columnWidth = contentWidth / 7;
    final slotHeight = widget.rowHeight / (kMinVisibleHours * 2);
    final totalHeight = kSlotsPerDay * slotHeight;

    final currentTimeMinutes =
        refDate.toLocal().hour * 60 + refDate.toLocal().minute;

    _scrollToCurrentTime();

    return SingleChildScrollView(
      controller: _scrollController,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time labels column
                SizedBox(
                  width: kTimeLabelWidth,
                  child: _buildTimeLabels(theme, slotHeight),
                ),
                // Day columns
                ...widget.range.days.map((date) {
                  return SizedBox(
                    width: columnWidth,
                    child: _buildDayColumn(date, columnWidth, slotHeight),
                  );
                }),
              ],
            ),
            // Current time marker
            _buildCurrentTimeMarker(theme, currentTimeMinutes, slotHeight),
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

  Widget _buildDayColumn(DateTime date, double columnWidth, double slotHeight) {
    final cellSize = Size(columnWidth, slotHeight);
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
          width: columnWidth,
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
      left: kTimeLabelWidth - 5,
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
            child: Container(height: 1, color: theme.colorScheme.destructive),
          ),
        ],
      ),
    );
  }
}
