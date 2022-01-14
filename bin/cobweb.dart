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
import "request_data.dart";
import 'restaurant.dart';

Future<void> main(List<String> arguments) async {
  // var document = await getDocument(uclaUrl);
  var hours = await fetchHours();
  var shortMenus = await fetchShortMenus();
  // var fullMenus = await fetchFullMenus();

  var rn = Jiffy();
  var rests = [];
  for (final e in shortMenus.entries) {
    var r = Restaurant(e.key, RestaurantType.dinein);
    var h = hours[e.key];

    // all menus for the location e.key
    var ms = e.value;
    for (final m in ms) {
      var p = m.period;
    }

    print(e.key);
    for (final loc in e.value) {
      print(loc.toString());
    }
  }

  // Where the food information is stored
  // var mainContent = document.getElementById("main-content");
  // var links = mainContent?.querySelectorAll("a"); // returns [Element]
  // var mainUnits = mainContent?.getElementsByClassName("unit-name");

  // if (links != null) {
  //   for (final n in links) {
  //     var newlink = n.attributes['href'] ??
  //         "could not find 'href' attribute of link '${n.text}'";
  //     print("'${n.text}': ${makeUrl(newlink)!}");
  //   }
  // } else {
  //   print(
  //       "either document was not found, or main-content did not contain any 'a' elements!");
  // }

  // Now: for each thing that is open:
}
