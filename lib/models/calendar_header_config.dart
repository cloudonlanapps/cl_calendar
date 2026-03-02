/// Configuration for what elements to show in the navigation header.
class CalendarHeaderConfig {
  const CalendarHeaderConfig({
    this.showNavigationArrows = true,
    this.showTodayButton = true,
    this.showYearMonthPicker = true,
    this.showViewToggle = true,
  });

  final bool showNavigationArrows;
  final bool showTodayButton;
  final bool showYearMonthPicker;
  final bool showViewToggle;

  /// Preset for minimal header (arrows only)
  static const minimal = CalendarHeaderConfig(
    showTodayButton: false,
    showYearMonthPicker: false,
    showViewToggle: false,
  );

  /// Preset for full header (all elements)
  static const full = CalendarHeaderConfig();
}
