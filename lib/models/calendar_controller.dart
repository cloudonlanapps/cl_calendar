/// Calendar controller interface - pure navigation commands.
abstract class CalendarController {
  void jumpTo(DateTime day);
  void next();
  void previous();
}
