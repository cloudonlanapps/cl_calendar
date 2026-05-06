import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'cl_date_picker.dart';

/// A `ShadForm`-compatible date picker that wraps [CLDatePicker].
///
/// Drop into any `ShadForm` like the other Shad form fields — the form
/// framework owns the value (keyed by [id]), validation, dirty state, and
/// reset. Selecting a date in the popover calls `field.didChange(date)`.
///
/// The trigger is rendered by this widget (a bordered, input-style row
/// showing the formatted date or a placeholder, with a calendar icon on the
/// right). Tapping it opens the [CLDatePicker] popover.
class CLDatePickerFormField extends ShadFormBuilderField<DateTime?> {
  CLDatePickerFormField({
    super.key,
    super.id,
    super.label,
    super.description,
    super.error,
    super.enabled,
    super.initialValue,
    super.validator,
    super.onChanged,
    super.onReset,
    super.onSaved,
    super.autovalidateMode,
    super.forceErrorText,
    Widget? placeholder,
    String Function(DateTime)? formatDate,
    int yearsBefore = 50,
    int yearsAfter = 50,
    double width = 320,
  }) : super(
         builder: (state) {
           final formatted =
               formatDate ?? (d) => DateFormat('d MMM yyyy').format(d);
           final value = state.value;
           final isEnabled = state.widget.enabled;
           final theme = ShadTheme.of(state.context);

           Widget label;
           if (value != null) {
             label = Text(
               formatted(value),
               style: theme.textTheme.small.copyWith(
                 color: theme.colorScheme.foreground,
               ),
             );
           } else {
             label =
                 placeholder ??
                 Text(
                   'Pick a date',
                   style: theme.textTheme.small.copyWith(
                     color: theme.colorScheme.mutedForeground,
                   ),
                 );
           }

           final trigger = Opacity(
             opacity: isEnabled ? 1 : 0.5,
             child: Container(
               padding: const EdgeInsets.symmetric(
                 horizontal: 12,
                 vertical: 8,
               ),
               decoration: BoxDecoration(
                 border: Border.all(color: theme.colorScheme.border),
                 borderRadius: BorderRadius.circular(6),
                 color: theme.colorScheme.background,
               ),
               child: Row(
                 children: [
                   Expanded(child: label),
                   const SizedBox(width: 8),
                   Icon(
                     LucideIcons.calendar,
                     size: 16,
                     color: theme.colorScheme.mutedForeground,
                   ),
                 ],
               ),
             ),
           );

           if (!isEnabled) {
             // Render the trigger but don't open the popover.
             return IgnorePointer(child: trigger);
           }

           return CLDatePicker(
             initialDate: value,
             yearsBefore: yearsBefore,
             yearsAfter: yearsAfter,
             width: width,
             onDateSelected: state.didChange,
             child: trigger,
           );
         },
       );
}
