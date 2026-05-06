import 'package:cl_calendar/cl_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(const ProviderScope(child: DatePickerPopoverExampleApp()));
}

class DatePickerPopoverExampleApp extends StatelessWidget {
  const DatePickerPopoverExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'cl_calendar — Date Picker Popover',
      themeMode: ThemeMode.light,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadSlateColorScheme.light(),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _picked1;
  DateTime? _picked2;

  String _format(DateTime? d) {
    if (d == null) return '— (none yet)';
    final local = d.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Date Picker Popover demo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Two independent pickers — selection state is isolated per popover.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: 32),
            _Row(
              label: 'Icon trigger:',
              picked: _format(_picked1),
              picker: DatePickerPopover(
                onDateSelected: (d) => setState(() => _picked1 = d),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(LucideIcons.calendar, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _Row(
              label: 'Button trigger:',
              picked: _format(_picked2),
              picker: DatePickerPopover(
                initialDate: DateTime.now().toUtc(),
                onDateSelected: (d) => setState(() => _picked2 = d),
                child: IgnorePointer(
                  child: ShadButton.outline(
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.calendarDays, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _picked2 == null ? 'Pick a date' : _format(_picked2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.picked,
    required this.picker,
  });

  final String label;
  final String picked;
  final Widget picker;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      children: [
        SizedBox(width: 140, child: Text(label, style: theme.textTheme.p)),
        picker,
        const SizedBox(width: 16),
        Text('Selected: $picked', style: theme.textTheme.muted),
      ],
    );
  }
}
