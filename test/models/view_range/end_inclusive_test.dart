import 'package:cl_calendar/cl_calendar.dart';
import 'package:cl_calendar/models/view_range/day_view_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Issue 2: view-range end is end-of-day inclusive', () {
    test(
      'Issue 2: MonthViewRange end is last day at 23:59:59.999',
      () {
        final range = MonthViewRange(year: 2026, month: 5);
        expect(range.start, DateTime(2026, 5));
        expect(range.end, DateTime(2026, 5, 31, 23, 59, 59, 999));
      },
    );

    test(
      'Issue 2: MonthViewRange dayCount unchanged after end-of-day fix',
      () {
        expect(MonthViewRange(year: 2026, month: 5).dayCount, 31);
        expect(MonthViewRange(year: 2026, month: 2).dayCount, 28);
        expect(MonthViewRange(year: 2024, month: 2).dayCount, 29);
        expect(MonthViewRange(year: 2026, month: 4).dayCount, 30);
      },
    );

    test(
      'Issue 2: MonthViewRange daysInMonth unchanged after end-of-day fix',
      () {
        expect(MonthViewRange(year: 2026, month: 5).daysInMonth, 31);
        expect(MonthViewRange(year: 2026, month: 2).daysInMonth, 28);
        expect(MonthViewRange(year: 2024, month: 2).daysInMonth, 29);
      },
    );

    test(
      'Issue 2: MonthViewRange end includes events later in the last day',
      () {
        final range = MonthViewRange(year: 2026, month: 5);
        final lastDayEvent = DateTime(2026, 5, 31, 6);
        expect(lastDayEvent.isBefore(range.end), isTrue);
      },
    );

    test(
      'Issue 2: WeekViewRange end is Sunday at 23:59:59.999',
      () {
        // 2026-05-27 is a Wednesday → week is Mon 2026-05-25 to Sun 2026-05-31.
        final range = WeekViewRange.fromDate(DateTime(2026, 5, 27));
        expect(range.start, DateTime(2026, 5, 25));
        expect(range.end, DateTime(2026, 5, 31, 23, 59, 59, 999));
        expect(range.dayCount, 7);
      },
    );

    test(
      'Issue 2: DayViewRange end is same day at 23:59:59.999',
      () {
        final range = DayViewRange.fromDate(DateTime(2026, 5, 31));
        expect(range.start, DateTime(2026, 5, 31));
        expect(range.end, DateTime(2026, 5, 31, 23, 59, 59, 999));
        expect(range.dayCount, 1);
      },
    );

    test(
      'Issue 2: DayViewRange end includes events later in the day',
      () {
        final range = DayViewRange.fromDate(DateTime(2026, 5, 31));
        final eveningEvent = DateTime(2026, 5, 31, 22, 30);
        expect(eveningEvent.isBefore(range.end), isTrue);
      },
    );

    test('Issue 2: MonthViewRange equality holds for same year/month', () {
      expect(
        MonthViewRange(year: 2026, month: 5),
        equals(MonthViewRange(year: 2026, month: 5)),
      );
    });

    test('Issue 2: WeekViewRange equality holds for same week', () {
      expect(
        WeekViewRange.fromDate(DateTime(2026, 5, 27)),
        equals(WeekViewRange.fromDate(DateTime(2026, 5, 30))),
      );
    });

    test('Issue 2: DayViewRange equality holds for same date', () {
      expect(
        DayViewRange.fromDate(DateTime(2026, 5, 31)),
        equals(DayViewRange.fromDate(DateTime(2026, 5, 31))),
      );
    });
  });
}
