import 'food_place.dart' show FoodPlace;
import 'schedule.dart' show DiningPeriod, Schedule, ToString;

// Need to implement double indexing:
// I know period, show me all halls; show me menu of h. (Common case)
// I know hall, show me all periods; show me menu at p.
// But when we first fetch data, we fetch hours by location...
// class DiningHallTable {}

class DiningHall extends FoodPlace {
  // maps period to short menu, as in residential overview
  Map<DiningPeriod, Menu> shortMenus = {};
  // maps period to full menu, as in detailed menu
  Map<DiningPeriod, Menu> fullMenus = {};

  DiningHall(String name, Schedule hours) : super(name, hours);

  void putShortMenu(DiningPeriod p, Menu m) {
    shortMenus.putIfAbsent(p, () => m);
  }

  @override
  String toString() {
    String out = "";
    out += "== $name ==\n";
    out += schedule.toString();
    for (final e in shortMenus.entries) {
      out += e.key.toPrettyString() + " ::\n";
      out += e.value.toString();
    }
    return out;
  }
}

// [categories]
// category -> [dishes]
// Hot Cereals -> [Oatmeal, Quinoa Flakes & Brown Rice Cereal]
// use Menu as a data class; an enhanced map.
class Menu {
  String name; // name of the dining location
  DiningPeriod period; // dining period where the menu applies
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

  Menu(this.name, this.period);

  void putCategoryAndDishes(String cat, List<Dish> dishes) {
    _m.putIfAbsent(cat, () => dishes);
  }

  @override
  String toString() {
    var out = "";
    out += "Location: $name\n...at time: ${period.toPrettyString()}\n";

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
