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
import 'restaurant.dart';

Future<void> main(List<String> arguments) async {
  var hours = await fetchHours();
  var shortMenus = await fetchShortMenus();
  // var fullMenus = await fetchFullMenus();

  // var rests = [];
  List<DiningHall> halls = [];
  for (final e in shortMenus.entries) {
    var h = hours[e.key];
    var r = DiningHall(e.key, h!);

    // all menus for the location e.key
    var ms = e.value;
    for (final m in ms) {
      var p = m.period!;
      r.putShortMenu(p, m);
    }

    halls.add(r);

    // print(e.key);
    // for (final loc in e.value) {
    //   print(loc.toString());
    // }
  }

  halls.forEach(print);
}
