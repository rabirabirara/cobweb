import 'package:jiffy/jiffy.dart';

enum RestaurantType { dinein, takeout, truck, misc }
// dining period and interval don't match up perfectly, but
// intervals *are* included in dining periods.
// there *is* a meaningful difference between them, and periods win out.
// refer to AskHousing. https://ask.housing.ucla.edu/app/answers/detail/a_id/821/kw/meal%20periods/session/L3RpbWUvMTQwMjIxMzUyMi9zaWQvMmtBQmxoV2w%3D
// however, even that is misleading; periods are not tied to times at all. food trucks
// break those rules this year.
enum DiningPeriod { breakfast, lunch, dinner, beforemidnight, aftermidnight }

// * Extensions are a really nice feature of the language.
// Rust never had this; instead you had to make a wrapper.
// Kotlin has this though. Kotlin is pretty cool.  Okay in my book.
extension ToString on DiningPeriod {
  String toPrettyString() {
    switch (this) {
      case DiningPeriod.breakfast:
        return "Breakfast";
      case DiningPeriod.lunch:
        return "Lunch";
      case DiningPeriod.dinner:
        return "Dinner";
      case DiningPeriod.beforemidnight:
        return "Late-night";
      case DiningPeriod.aftermidnight:
        return "Post-midnight";
    }
  }
}

class Restaurant {
  String name;
  RestaurantType type;
  // List<Menu?> shortMenu; // produced from the residential overview
  // List<Menu?> fullMenu; // produced from the specific menu page
  Hours? hours;
  // maps period to short menu, as in residential overview
  Map<DiningPeriod, Menu?>? shortMenus;
  // maps period to full menu, as in detailed menu
  Map<DiningPeriod, Menu?>? fullMenus;
  // Map<String, Menu?>? fullMenus;
  Restaurant(this.name, this.type);
  //{this.shortMenu = const [], this.fullMenu = const [], this.hours});
}

// [categories]
// category -> [dishes]
// Hot Cereals -> [Oatmeal, Quinoa Flakes & Brown Rice Cereal]
// use Menu as a data class; an enhanced map.
class Menu {
  String? location; // name of the dining location
  DiningPeriod? period; // dining period where the menu applies
  final Map<String, List<Dish>> _m = {};

  Map<String, List<Dish>> get menu {
    return _m;
  }

  // String get period {
  //   return _p ?? "";
  // }

  DiningPeriod? get getPeriod {
    return period;
  }

  set setPeriod(DiningPeriod dp) {
    period = dp;
  }

  Menu(this.location);

  // Menu({this.location, String? period}) {
  // _p = period;
  // }

  void putCategoryAndDishes(String cat, List<Dish> dishes) {
    _m.putIfAbsent(cat, () => dishes);
  }

  @override
  String toString() {
    var out = "";
    out += "Location: " + (location ?? "N/A") + '\n';

    for (final e in _m.entries) {
      out += "Category: " + e.key + '\n';
      for (final dish in e.value) {
        out += '____ ' + dish.toString() + '\n';
      }
      out += '\n';
    }

    return out;
  }
}

// TODO: Right now, a Dish is just a string, but we might later add the icons and stuff.
// No links though.  I don't give a shit about supporting that.
class Dish {
  String name;
  String? description;
  // Element? elem;
  Dish(this.name, [this.description]);

  @override
  String toString() {
    return name + ": " + (description ?? "n/a");
  }
}

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
      if 
    }
  }

  bool isClosedAllDay() {
    return _timeIntervals.isEmpty || _timeIntervals.every((e) => e == null);
  }

  bool isOpenNow() {
    final rn = Jiffy();
    for (final interval in _timeIntervals) {
      if (interval != null) {
        if (interval.includes(rn)) {
          return true;
        }
      }
    }
    return false;
  }

  // TODO: fetch tomorrow's hours too, and rewrite this to nextOpeningTime.
  Jiffy? nextOpeningTimeToday() {
    final rn = Jiffy();
    for (final interval in _timeIntervals) {
      if (interval != null) {
        if (interval.start.isAfter(rn)) {
          return interval.start;
        }
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
