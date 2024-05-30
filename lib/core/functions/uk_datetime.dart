import 'package:timezone/timezone.dart' as tz;

final _uk = tz.getLocation("Europe/London");

DateTime ukDateTimeNow() {
  return tz.TZDateTime.now(_uk);
}

DateTime ukDateTimeParse(DateTime date) {
  return tz.TZDateTime(
    _uk,
    date.year,
    date.month,
    date.day,
    date.hour,
    date.minute,
    date.second
  );
}
