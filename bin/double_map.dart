// a map indexable by two keys, one at a time.
import 'classes/dining_hall.dart' show DiningHall, Menu;
import 'classes/schedule.dart' show DiningPeriod;

typedef Name = String;

class DiningHalls {
  Map<Name, DiningHall> dhs;

  Iterable<DiningHall> get halls {
    return dhs.values;
  }

  List<DiningHall> get openNow {
    List<DiningHall> open = [];
    for (final dh in dhs.values) {
      if (dh.schedule.isOpenNow()) {
        open.add(dh);
      }
    }
    return open;
  }

  // Given a DiningPeriod, return a map of locations to short menus.
  Map<Name, Menu> shortMenusAt(DiningPeriod dp) {
    Map<Name, Menu> shortMenuMap = {};
    // for each dining hall:
    for (final dh in dhs.values) {
      // for each period > shortmenu:
      var m = dh.shortMenus[dp];
      if (m != null) {
        shortMenuMap[m.name] = m;
      }
    }
    return shortMenuMap;
  }

  // Given a DiningPeriod, find all food places that list as open.
  // Refer to uclaHoursUrl.
  List<DiningHall> openAt(DiningPeriod dp) {
    List<DiningHall> open = [];
    for (final dh in dhs.values) {
      if (dh.schedule.getIntervalAtPeriod(dp) != null) {
        open.add(dh);
      }
    }
    return open;
  }

  DiningHalls(this.dhs);
}
