import 'package:cl_calendar/cl_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(const ProviderScope(child: CLDatePickerExampleApp()));
}

class CLDatePickerExampleApp extends StatelessWidget {
  const CLDatePickerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'cl_calendar — CLDatePicker demo',
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

  final _formKey = GlobalKey<ShadFormState>();
  String? _submittedSummary;

  String _format(DateTime? d) {
    if (d == null) return '— (none yet)';
    final local = d.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  void _submitForm() {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.saveAndValidate()) {
      setState(() => _submittedSummary = '✗ validation failed');
      return;
    }
    final values = form.value;
    final dob = values['dateOfBirth'] as DateTime?;
    final event = values['eventDate'] as DateTime?;
    setState(() {
      _submittedSummary =
          'Submitted → dateOfBirth: ${_format(dob)}  ·  eventDate: ${_format(event)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('cl_calendar demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Section 1: standalone CLDatePicker ---------------------
            Text('CLDatePicker (standalone)', style: theme.textTheme.h4),
            const SizedBox(height: 8),
            Text(
              'Two independent pickers — selection state is isolated per popover.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: 16),
            _Row(
              label: 'Icon trigger:',
              picked: _format(_picked1),
              picker: CLDatePicker(
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
            const SizedBox(height: 16),
            _Row(
              label: 'Button trigger:',
              picked: _format(_picked2),
              picker: CLDatePicker(
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

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 24),

            // -- Section 2: CLDatePickerFormField inside a ShadForm -----
            Text(
              'CLDatePickerFormField (inside ShadForm)',
              style: theme.textTheme.h4,
            ),
            const SizedBox(height: 8),
            Text(
              'Form-managed value, validation, dirty tracking. Submit prints '
              'the form value.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ShadForm(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CLDatePickerFormField(
                      id: 'dateOfBirth',
                      label: const Text('Date of birth'),
                      placeholder: const Text('Select date of birth'),
                      yearsBefore: 100,
                      yearsAfter: 0,
                      validator: (value) =>
                          value == null ? 'Date of birth is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CLDatePickerFormField(
                      id: 'eventDate',
                      label: const Text('Event date'),
                      placeholder: const Text('When does it happen?'),
                      description: const Text('Up to 5 years from today.'),
                      yearsBefore: 1,
                      yearsAfter: 5,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ShadButton(
                          onPressed: _submitForm,
                          child: const Text('Submit'),
                        ),
                        const SizedBox(width: 12),
                        ShadButton.outline(
                          onPressed: () {
                            _formKey.currentState?.reset();
                            setState(() => _submittedSummary = null);
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    if (_submittedSummary != null) ...[
                      const SizedBox(height: 16),
                      Text(_submittedSummary!, style: theme.textTheme.small),
                    ],
                  ],
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
  const _Row({required this.label, required this.picked, required this.picker});

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
