import 'package:flutter/material.dart';

import '../models/view_range/month_view_range.dart';
import 'cell_wrapper.dart';

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    required this.range,
    required this.width,
    required this.rowHeight,
    required this.dateBuilder,
    super.key,
    this.cellBorder,
  });

  final MonthViewRange range;
  final double width;
  final double rowHeight;
  final Widget Function(DateTime date, Size size) dateBuilder;
  final BorderSide? cellBorder;

  @override
  Widget build(BuildContext context) {
    final grid = range.buildGrid();
    final cellWidth = width / 7;
    final borderWidth = cellBorder?.width ?? 0;
    final contentSize = Size(
      cellWidth - borderWidth * 2,
      rowHeight - borderWidth * 2,
    );

    return Column(
      children: grid.map((week) {
        return SizedBox(
          height: rowHeight,
          child: Row(
            children: week.map((date) {
              final child = date != null
                  ? dateBuilder(date, contentSize)
                  : const SizedBox();
              return CellWrapper(
                width: cellWidth,
                height: rowHeight,
                border: cellBorder,
                child: child,
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
