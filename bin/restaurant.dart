import 'package:jiffy/jiffy.dart';

import 'food_place.dart' show FoodPlace;
import 'hours.dart' show DiningPeriod, Hours;

class DiningHall extends FoodPlace {
  // maps period to short menu, as in residential overview
  Map<DiningPeriod, Menu?> shortMenus = {};
  // maps period to full menu, as in detailed menu
  Map<DiningPeriod, Menu?> fullMenus = {};
  // Map<String, Menu?>? fullMenus;
  DiningHall(String name, Hours hours) : super(name, hours);
  //{this.shortMenu = const [], this.fullMenu = const [], this.hours});

  void putShortMenu(DiningPeriod p, Menu m) {
    shortMenus.putIfAbsent(p, () => m);
  }
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
