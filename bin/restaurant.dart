import 'package:jiffy/jiffy.dart';

enum RestaurantType { dinein, takeout, truck, misc }

class Restaurant {
  String name;
  RestaurantType type;
  // List<Menu?> shortMenu; // produced from the residential overview
  // List<Menu?> fullMenu; // produced from the specific menu page
  Hours? hours;
  // maps period to menu, as in residential overview
  Map<String, Menu?>? shortMenus;
  // Map<String, Menu?>? fullMenus;
  Restaurant(this.name, this.type);
  //{this.shortMenu = const [], this.fullMenu = const [], this.hours});
}

// [categories]
// category -> [dishes]
// Hot Cereals -> [Oatmeal, Quinoa Flakes & Brown Rice Cereal]
class Menu {
  String? location;
  String? _p;
  Interval? interval;
  final Map<String, List<Dish>> _m = {};

  Map<String, List<Dish>> get menu {
    return _m;
  }

  String get period {
    return _p ?? "";
  }

  Menu({this.location, String? period}) {
    _p = period;
  }

  void putCategoryAndDishes(String cat, List<Dish> dishes) {
    _m.putIfAbsent(cat, () => dishes);
  }

  @override
  String toString() {
    var out = "";
    out += "Location: " + (location ?? "Unknown") + '\n';

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

  int get periodCount {
    return _timeIntervals.length;
  }

  Hours();
  Hours.newClosedAllDay();

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
  String? period;
  Interval(this.start, this.end, this.period);

  bool includes(Jiffy time) {
    return time.isBetween(start, end);
  }

  @override
  String toString() {
    if (period != null) {
      return "$period: ${start.format("jm")} - ${end.format("jm")}";
    } else {
      return "${start.format("jm")} - ${end.format("jm")}";
    }
  }
}
