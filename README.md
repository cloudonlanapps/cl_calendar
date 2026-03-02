# cl_calendar

A Flutter calendar widget supporting month, week, and day views with Riverpod state management.

## Features

- **Month/Week/Day views** with seamless switching
- **Navigation** with previous/next controls
- **Selected date** tracking with callbacks
- **Customizable builders** for headers, day cells, and time slots
- **Works out of the box** with sensible defaults

## Usage

```dart
import 'package:cl_calendar/cl_calendar.dart';

// Minimal - uses all defaults
GetCalendarViewRange(
  builder: (controller, range, selectedDate, onSelectDate) {
    return SimpleCalendarView(
      controller: controller,
      range: range,
    );
  },
)

// Customized
GetCalendarViewRange(
  builder: (controller, range, selectedDate, onSelectDate) {
    return SimpleCalendarView(
      controller: controller,
      range: range,
      dateBuilder: (date, size) => MyCustomDayCell(date: date),
      slotBuilder: (slotTime, size) => MyCustomSlot(time: slotTime),
    );
  },
)
```

## Exports

| Symbol | Type | Description |
|--------|------|-------------|
| `GetCalendarViewRange` | Builder | Provides range, controller, and selected date |
| `GetSelectedDate` | Builder | Provides selected date and callback only |
| `SimpleCalendarView` | Widget | The calendar widget |
| `CalendarPreferences` | Widget | Time settings UI (live time toggle, custom time) |
| `CalendarViewRange` | Model | Base class for view ranges |
| `MonthViewRange` | Model | Month view configuration |
| `WeekViewRange` | Model | Week view configuration |
| `referenceDateTimeUtcProvider` | Provider | Current reference time |
