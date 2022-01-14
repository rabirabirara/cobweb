// parses 11 p.m. or 5:30 a.m. into DateTime object.
import 'restaurant.dart' show Interval;
import 'package:jiffy/jiffy.dart';

Jiffy parseTimeStrings(String str, [String? today]) {
  int year, month, day;
  if (today != null) {
    final dt = Jiffy(today, "MMMM dd, yyyy").dateTime;
    year = dt.year;
    month = dt.month;
    day = dt.day;
  } else {
    final rn = DateTime.now();
    year = rn.year;
    month = rn.month;
    day = rn.day;
  }

  var hour = 0;
  var minute = 0;
  if (str.contains(":")) {
    final minsStr = str.replaceAll(RegExp(r"(\s|(a|p)\.m\.)"), '');
    hour = int.parse(minsStr.split(':')[0]);
    minute = int.parse(minsStr.split(':')[1]);
  } else {
    hour = int.parse(str.replaceAll(RegExp(r"\D"), ''));
  }
  if (str.contains('p')) {
    hour += 12;
  } else if (hour == 12) {
    hour = 0;
  }
  return Jiffy([year, month, day, hour, minute]);
}

Interval parseTimeSpan(String timeSpan, String period, {String? today}) {
  final parts = timeSpan.split('-');
  final startStr = parts[0].trim();
  final endStr = parts[1].trim();

  final start = parseTimeStrings(startStr, today);
  final end = parseTimeStrings(endStr, today);

  return Interval(start, end, period);
}
