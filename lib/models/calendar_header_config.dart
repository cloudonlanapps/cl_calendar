/// Configuration for what elements to show in the navigation header.
class CalendarHeaderConfig {
  const CalendarHeaderConfig({
    this.showNavigationArrows = true,
    this.showTodayButton = true,
    this.showYearMonthPicker = true,
    this.showViewToggle = true,
    this.reserveViewToggleSpace = false,
    this.yearsBefore = 2,
    this.yearsAfter = 4,
  });

  final bool showNavigationArrows;
  final bool showTodayButton;
  final bool showYearMonthPicker;
  final bool showViewToggle;

  /// When [showViewToggle] is false but this flag is true, the header reserves
  /// the same horizontal slot for the toggle and renders it invisibly. This
  /// keeps the three-section header layout (left / centre / right) balanced.
  final bool reserveViewToggleSpace;

  /// How many years before the reference date the year/month picker can
  /// navigate to.
  final int yearsBefore;

  /// How many years after the reference date the year/month picker can
  /// navigate to.
  final int yearsAfter;

  /// Preset for minimal header (arrows only)
  static const minimal = CalendarHeaderConfig(
    showTodayButton: false,
    showYearMonthPicker: false,
    showViewToggle: false,
  );

  /// Preset for full header (all elements)
  static const full = CalendarHeaderConfig();

  /// Preset for the date-picker popover: arrows + Today + year/month picker,
  /// view toggle hidden but its slot reserved so the layout stays balanced.
  static const datePicker = CalendarHeaderConfig(
    showViewToggle: false,
    reserveViewToggleSpace: true,
  );
}
