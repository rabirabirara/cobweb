// ignore_for_file: unused_import, unused_local_variable

// https://stackoverflow.com/questions/19723063/what-is-the-difference-between-show-and-as-in-an-import-statement
// like in Haskell you can choose what to import; that's what show means.
// as is an aliasing keyword like in other languages.

/* NULL-SAFETY OPERATORS TO KNOW  (convenient Option)
x!      <=> unwraps" a nullable x
a ?? b  <=> if a is null, return b; else evaluate and return a
a?.b    <=> if a is null, then return null; else evaluate and return a.b
a ??= b <=> if a is null, then set it to b; else leave it untouched
*/

// * Consider renaming the app to menucla.

import 'dart:io';

import 'package:jiffy/jiffy.dart';

import 'classes/schedule.dart';
import 'double_map.dart';
import 'scrape/process_html.dart';
import 'scrape/fetch_html.dart';
import 'classes/dining_hall.dart';

Future<void> main(List<String> arguments) async {
  // hours: {Location -> Hours}
  var schedules = await fetchHours();

  // shortMenus: {Location -> {Period -> Menu}}
  var nameToPeriodToShortMenu = await fetchShortMenus();

  // var fullMenus = await fetchFullMenus();

  var dininghalls = makeDiningHalls(schedules, nameToPeriodToShortMenu);

  var dhs = DiningHalls({for (final hall in dininghalls) hall.name: hall});
  dhs.halls.forEach(print);

  var ms = dhs.shortMenusAt(DiningPeriod.dinner);
  ms.values.forEach(print);
}
