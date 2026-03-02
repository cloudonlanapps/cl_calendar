import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/custom_reference_datetime.dart';
import '../providers/reference_datetime.dart';
import '../providers/selected_datetime.dart';
import '../providers/use_live_time.dart';

/// Widget for calendar time preferences (live time toggle + custom time picker).
/// Encapsulates useLiveTimeProvider and customReferenceDateTimeUtcProvider.
class CalendarPreferences extends ConsumerWidget {
  const CalendarPreferences({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useLiveTime = ref.watch(useLiveTimeProvider);
    final refDateTime =
        ref.watch(referenceDateTimeUtcProvider) ?? DateTime.now().toUtc();
    final theme = ShadTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Live time toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.sync, color: theme.colorScheme.mutedForeground),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Use Live Time', style: theme.textTheme.list),
                    Text(
                      'Use current system time (production testing)',
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
              ShadSwitch(
                value: useLiveTime,
                onChanged: (value) {
                  ref.read(useLiveTimeProvider.notifier).state = value;
                  if (value) {
                    ref.read(selectedDateTimeProvider.notifier).state =
                        DateTime.now().toUtc();
                  }
                },
              ),
            ],
          ),
        ),
        // Reference date/time picker (disabled when using live time)
        Opacity(
          opacity: useLiveTime ? 0.5 : 1.0,
          child: GestureDetector(
            onTap: useLiveTime
                ? null
                : () => _showDateTimePicker(context, ref, refDateTime),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reference Date & Time',
                          style: theme.textTheme.list,
                        ),
                        Text(
                          _formatDateTime(refDateTime),
                          style: theme.textTheme.muted,
                        ),
                      ],
                    ),
                  ),
                  if (!useLiveTime)
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.mutedForeground,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  void _showDateTimePicker(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) {
    showShadDialog(
      context: context,
      builder: (context) => _DateTimePickerDialog(
        initialDateTime: current,
        onConfirm: (newDateTime) {
          ref.read(customReferenceDateTimeUtcProvider.notifier).state =
              newDateTime;
          ref.read(selectedDateTimeProvider.notifier).state = newDateTime;
        },
      ),
    );
  }
}

/// Dialog for picking date and time.
class _DateTimePickerDialog extends StatefulWidget {
  const _DateTimePickerDialog({
    required this.initialDateTime,
    required this.onConfirm,
  });

  final DateTime initialDateTime;
  final ValueChanged<DateTime> onConfirm;

  @override
  State<_DateTimePickerDialog> createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<_DateTimePickerDialog> {
  late DateTime _selectedDate;
  late ShadTimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final localDateTime = widget.initialDateTime.toLocal();
    _selectedDate = localDateTime;
    _selectedTime = ShadTimeOfDay(
      hour: localDateTime.hour,
      minute: localDateTime.minute,
      second: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Select Date & Time'),
      description: const Text(
        'Choose the reference date and time (local time)',
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () {
            final localDateTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );
            widget.onConfirm(localDateTime.toUtc());
            Navigator.of(context).pop();
          },
          child: const Text('Confirm'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShadDatePicker(
            selected: _selectedDate,
            onChanged: (date) {
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
          const SizedBox(height: 16),
          ShadTimePicker(
            initialValue: _selectedTime,
            onChanged: (time) {
              setState(() => _selectedTime = time);
            },
          ),
        ],
      ),
    );
  }
}
