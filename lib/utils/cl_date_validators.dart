import 'package:flutter/material.dart';

/// Composable validators for `DateTime?` form fields — pair with
/// `CLDatePickerFormField` (or any `FormField<DateTime?>`).
///
/// Each helper returns a `FormFieldValidator<DateTime?>` (i.e.
/// `String? Function(DateTime?)`) so they can be composed via [combine].
///
/// Date comparisons normalise both sides to midnight (local) so a "min:
/// today" rule treats picking *any* time today as valid.
class CLDateValidators {
  CLDateValidators._();

  /// Reject `null` (i.e. nothing picked).
  static FormFieldValidator<DateTime?> required({
    String message = 'Date is required',
  }) {
    return (value) => value == null ? message : null;
  }

  /// Reject dates strictly before [min] (day granularity, local time).
  /// Inclusive of [min].
  static FormFieldValidator<DateTime?> notBefore(
    DateTime min, {
    String? message,
  }) {
    final minDay = _atMidnightLocal(min);
    return (value) {
      if (value == null) return null;
      if (_atMidnightLocal(value).isBefore(minDay)) {
        return message ?? 'Date must be on or after ${_format(min)}';
      }
      return null;
    };
  }

  /// Reject dates strictly after [max] (day granularity, local time).
  /// Inclusive of [max].
  static FormFieldValidator<DateTime?> notAfter(
    DateTime max, {
    String? message,
  }) {
    final maxDay = _atMidnightLocal(max);
    return (value) {
      if (value == null) return null;
      if (_atMidnightLocal(value).isAfter(maxDay)) {
        return message ?? 'Date must be on or before ${_format(max)}';
      }
      return null;
    };
  }

  /// Inclusive range check: `min <= value <= max`. Day granularity.
  static FormFieldValidator<DateTime?> between(
    DateTime min,
    DateTime max, {
    String? message,
  }) {
    final minDay = _atMidnightLocal(min);
    final maxDay = _atMidnightLocal(max);
    return (value) {
      if (value == null) return null;
      final day = _atMidnightLocal(value);
      if (day.isBefore(minDay) || day.isAfter(maxDay)) {
        return message ??
            'Date must be between ${_format(min)} and ${_format(max)}';
      }
      return null;
    };
  }

  /// Run multiple validators in order; return the first non-null message.
  static FormFieldValidator<DateTime?> combine(
    List<FormFieldValidator<DateTime?>> validators,
  ) {
    return (value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  static DateTime _atMidnightLocal(DateTime d) {
    final local = d.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static String _format(DateTime d) {
    final local = d.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}
