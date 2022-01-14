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

import 'handle_documents.dart';
import 'fetch_html.dart';
import 'dining_hall.dart';

Future<void> main(List<String> arguments) async {
  // hours: {Location -> Hours}
  var hours = await fetchHours();
  // shortMenus: {Location -> {Period -> Menu}}
  var shortMenus = await fetchShortMenus();
  // var fullMenus = await fetchFullMenus();

  List<DiningHall> halls = [];
  for (final e in shortMenus.entries) {
    // e: Location name -> {Period -> Menu}

    // Build the DiningHall first with location and hours; add menus next.
    var r = DiningHall(e.key, hours[e.key]!);

    // Add menus to the dining hall, mapped by period -> menu (per location).
    // e.value = all period>menus at location: e.key
    var periodToMenus = e.value;
    for (final m in periodToMenus.entries) {
      // m.value = all menus for period m.key at location e.key
      r.putShortMenu(m.key, m.value);
    }

    // Add the DiningHall to our collection of DiningHalls.
    halls.add(r);
  }

  halls.forEach(print);
}
