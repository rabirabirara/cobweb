import 'package:jiffy/jiffy.dart';

import 'hours.dart' show DiningPeriod, Hours;

// enum PlaceType { dinein, takeout, truck, misc }

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

// class UCLA {
//   List<DiningHall> halls;
//   List<TakeOut> takeouts;
//   List<FoodTruck> trucks;
//   List<FoodPlace> extras;
// }

// Every food place has a name (location) and a schedule.
class FoodPlace {
  String name;
  // Both hours and menus should be indexable by period.
  Hours hours;
  FoodPlace(this.name, this.hours);
}
