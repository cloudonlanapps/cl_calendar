import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/calendar_view_mode.dart';

/// Simple toggle button for Month/Week view.
class ViewToggle extends StatelessWidget {
  const ViewToggle({
    super.key,
    required this.currentViewMode,
    required this.onViewModeChanged,
    required this.theme,
  });

  final CalendarViewMode currentViewMode;
  final void Function(CalendarViewMode mode) onViewModeChanged;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isMonth = currentViewMode == CalendarViewMode.month;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            label: 'M',
            isSelected: isMonth,
            onTap: () => onViewModeChanged(CalendarViewMode.month),
          ),
          _buildToggleButton(
            label: 'W',
            isSelected: !isMonth,
            onTap: () => onViewModeChanged(CalendarViewMode.week),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.muted : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: theme.textTheme.small.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
