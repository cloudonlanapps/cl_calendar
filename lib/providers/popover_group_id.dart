import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Optional `groupId` propagated to every `ShadPopover` used inside the
/// calendar (e.g. the year/month picker rendered by `YearMonthHeader`).
///
/// When the calendar itself is rendered inside another `ShadPopover` (e.g.
/// `DatePickerPopover`), both the outer popover and any nested popovers must
/// share the same `groupId` so a tap on the nested overlay is not treated as
/// an outside-tap on the outer popover (which would dismiss it).
///
/// Defaults to `null` — popovers fall back to their own internal key.
final calendarPopoverGroupIdProvider = StateProvider<Object?>((ref) => null);
