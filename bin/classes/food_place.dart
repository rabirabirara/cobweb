// import 'package:jiffy/jiffy.dart';

import 'schedule.dart' show Schedule;

// enum PlaceType { dinein, takeout, truck, misc }

// * Extensions are a really nice feature of the language.
// Rust never had this; instead you had to make a wrapper.
// Kotlin has this though. Kotlin is pretty cool.  Okay in my book.

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
  Schedule schedule;
  FoodPlace(this.name, this.schedule);
}
