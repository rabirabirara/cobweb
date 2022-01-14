import 'package:jiffy/jiffy.dart';

import 'food_place.dart' show ToString;

// dining period and interval don't match up perfectly, but
// intervals *are* included in dining periods.
// there *is* a meaningful difference between them, and periods win out.
// refer to AskHousing. https://ask.housing.ucla.edu/app/answers/detail/a_id/821/kw/meal%20periods/session/L3RpbWUvMTQwMjIxMzUyMi9zaWQvMmtBQmxoV2w%3D
// however, even that is misleading; periods are not tied to times at all. food trucks
// break those rules this year.
enum DiningPeriod { breakfast, lunch, dinner, beforemidnight, aftermidnight }

// Defines a schedule for a place that serves food.
class Hours {
  // null Interval means it's closed then
  final List<Interval?> _timeIntervals = [];

  List<Interval?> get ints {
    return _timeIntervals;
  }

  Hours();
  Hours.newClosedAllDay();

  Interval? getIntervalAtPeriod(DiningPeriod dp) {
    for (final intval in _timeIntervals) {
      if (intval != null && intval.period == dp) {
        return intval;
      }
    }
    return null;
  }

  bool isClosedAllDay() {
    return _timeIntervals.isEmpty || _timeIntervals.every((e) => e == null);
  }

  bool isOpenNow() {
    final rn = Jiffy();
    for (final intval in _timeIntervals) {
      if (intval != null && intval.includes(rn)) {
        return true;
      }
    }
    return false;
  }

  // TODO: fetch tomorrow's hours too, and rewrite this to nextOpeningTime.
  Jiffy? nextOpeningTimeToday() {
    final rn = Jiffy();
    for (final intval in _timeIntervals) {
      if (intval != null && intval.start.isAfter(rn)) {
        return intval.start;
      }
    }
    return null;
  }

  void addInterval(Interval? i) {
    _timeIntervals.add(i);
  }

  @override
  String toString() {
    if (isClosedAllDay()) {
      return "CLOSED";
    } else {}
    return _timeIntervals.map((e) {
      if (e != null) {
        return e.toString();
      } else {
        return "CLOSED";
      }
    }).join(' ');
  }
}

class Interval {
  Jiffy start;
  Jiffy end;
  DiningPeriod period;
  Interval(this.start, this.end, this.period);

  bool includes(Jiffy time) {
    return time.isBetween(start, end);
  }

  @override
  String toString() {
    // if (period != null) {
    return "${period.toPrettyString()}: ${start.format("jm")} - ${end.format("jm")}";
    // } else {
    //   return "${start.format("jm")} - ${end.format("jm")}";
    // }
  }
}
