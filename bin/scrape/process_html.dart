// import 'dart:collection';

// import 'package:html/parser.dart';
// import 'package:http/http.dart';
import 'package:html/dom.dart';
// import 'package:quiver/iterables.dart';

// import 'cobweb.dart';
import 'fetch_html.dart';
// import 'fetch_local_html.dart' show getLocalDocument;
import '../classes/schedule.dart'
    show DiningPeriod, Schedule, Interval, parseTimeSpan;
import '../classes/dining_hall.dart';

Future<Map<String, Schedule>> fetchHours() async {
  var doc = await getDocument(uclaHoursUrl);
  // var doc = await getLocalDocument("hours.html");

  // Hours of operation: "Day", MMMM dd, yyyy
  var bigHeader = doc.getElementById("page-header");
  final dateStr =
      bigHeader!.text.split(' ').reversed.take(3).toList().reversed.join(' ');

  // table of hours. we could hardcode this, but make it dynamic
  // by putting everything into a list of names.  e.g. nbsp at list[0],
  // breakfast at list[1], lunch at list[2]...
  var hoursTable = doc.getElementsByClassName("hours-table").first;

  var tableHead = hoursTable.children[0];
  var tableBody = hoursTable.children[1];

  // should be <tr>...</tr> element
  var headerRow = tableHead.children[0];
  // list of <th> cells
  var headerRowTabs = headerRow.children;

  // mealtimes without the corner cell
  final mealTimes = headerRowTabs.map((elem) => elem.text).toList().sublist(1);

  // for now, let's convert table to map, with 0th col as key and rest as [value]
  // one row is <tr> element
  // has mealTimes.length + 1 columns
  // 0th column is information
  // rest are hours, which if null mean closed, and otherwise are converted to times (what representation?)
  Map<String, Schedule> locationHoursMap = {};

  for (final row in tableBody.children) {
    final cols = row.children;
    // cols[0] is the info cell
    final location = cols[0].children[0].text;

    // cols.sublist(1) are the hours; either closed elements or open with inner span
    final hourCells = cols.sublist(1);

    if (hourCells.length == 1) {
      // if only one cell, either closed all day or ASUCLA's special row
      if (hourCells[0].className == "hours-open") {
        // final asuclaUrl = hourCells[0].querySelector("a")?.attributes['href'];
        // print("'$location' is open today; see ${makeUrl(asuclaUrl!)}");
      } else {
        // print("'$location' is closed all day");
        locationHoursMap.putIfAbsent(
            location, () => Schedule.newClosedAllDay());
      }
      continue;
    }

    var hours = Schedule();

    for (int i = 0; i != mealTimes.length; i++) {
      if (hourCells[i].hasChildNodes()) {
        final timeSpan = hourCells[i].getElementsByClassName("hours-range");

        var period = _getPeriodFromText(mealTimes[i]);
        Interval? interval;

        // If there are no elements with class "hours-range", then it's closed.
        if (timeSpan.isNotEmpty) {
          interval = parseTimeSpan(timeSpan.first.text, period, today: dateStr);
        }
        hours.addInterval(interval);
      }
    }

    locationHoursMap[location] = hours;
  }

  return locationHoursMap;
}

// from uclaMenusUrl
Future<Map<String, Map<DiningPeriod, Menu>>> fetchShortMenus() async {
  var doc = await getDocument(uclaMenusUrl);
  // var doc = await getLocalDocument("menus-periods.html");

  // maps location to menus for all periods as available
  // we will fill this out and at the end return it.
  Map<String, Map<DiningPeriod, Menu>> placeMenus = {};

  // main content div
  // children: nav-extras, announce, headers, detail link, menublock(cols?)
  var mainContentChildren = doc.getElementById("main-content")!.children;

  // Remove elements that aren't page headers or menu-block divs.
  var justMenus = mainContentChildren.where((e) {
    return (e.id == "page-header" || e.className.contains("menu-block"));
  }).toList();

  // we have a linked map of periods
  // each period maps period element to a map of menus
  // each map of menus maps location name to shortMenu
  Map<String, List<Element>> periodMenus = {};
  String? tempPeriodStr;
  List<Element> tempElements = [];
  for (final e in justMenus) {
    if (e.id == "page-header") {
      // period is null if on first iteration
      if (tempPeriodStr != null) {
        periodMenus.putIfAbsent(tempPeriodStr, () => List.from(tempElements));
        tempElements.clear();
      }
      tempPeriodStr = e.text;
    } else if (e.className.contains("menu-block")) {
      tempElements.add(e);
    }
  }
  if (tempPeriodStr != null) {
    periodMenus.putIfAbsent(tempPeriodStr, () => tempElements);
  }

  // p.key = page-header (period), p,value = menu-block siblings
  // get from a menu block: location, shortMenu
  for (final p in periodMenus.entries) {
    var period = _getPeriodFromText(p.key);

    // p.values is a list of items (menu-blocks) for a period p.
    // Each menu-block is a different location and menu.
    for (final val in p.value) {
      var location = _getLocationFromMenuElement(val);

      // First, produce a list of short menus from the menu-item elements.
      // These menus have a period and a short menu.
      // Period and location are set in the function.
      var m = _getMenuFromMenuElement(val, period);

      // Second, map: period -> menu in the placeMenus.
      placeMenus.update(location, (v) {
        v[period] = m;
        return v;
      }, ifAbsent: () {
        return {period: m};
      });
      // if in loc map, update map with these period maps; if not, place it in.

      // We end with map: Location -> Periods -> Menus.
    }
  }

  return placeMenus;
}

List<DiningHall> makeDiningHalls(Map<String, Schedule> locToHours, shortMenus) {
  List<DiningHall> halls = [];
  for (final e in shortMenus.entries) {
    // e: Location name -> {Period -> Menu}

    // Build the DiningHall first with location and hours; add menus next.
    var r = DiningHall(e.key, locToHours[e.key]!);

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
  return halls;
}

String _getLocationFromMenuElement(Element e) {
  return e.querySelector(".col-header")!.text;
}

Menu _getMenuFromMenuElement(Element e, DiningPeriod dp) {
  var location = _getLocationFromMenuElement(e);

  var menu = Menu(location, dp);

  var ul = e.querySelector("ul")!;
  for (final li in ul.children) {
    // * So a node is actually represented in the HTML source.
    // The li has a text node as its firstChild, and then ensuing children, etc.
    var cat = li.firstChild!.text!;
    // getbyname('menu-item') instead for more information, like tooltips and icons.
    var items = li.querySelector("ul")!.getElementsByClassName("menu-item");

    List<Dish> dishes = [];
    for (final item in items) {
      var dishname = item.querySelector(".recipelink")!.text.trim();
      var description = item.querySelector(".tt-description")?.text.trim();
      dishes.add(Dish(dishname, description));
    }

    menu.putCategoryAndDishes(cat.trim(), dishes);
  }

  return menu;
}

DiningPeriod _getPeriodFromText(String txt) {
  if (txt.contains(RegExp("breakfast", caseSensitive: false))) {
    return DiningPeriod.breakfast;
  } else if (txt.contains(RegExp("lunch", caseSensitive: false))) {
    return DiningPeriod.lunch;
  } else if (txt.contains(RegExp(r"(extended|late)", caseSensitive: false))) {
    return DiningPeriod.beforemidnight;
  } else if (txt.contains(RegExp("dinner", caseSensitive: false))) {
    return DiningPeriod.dinner;
  } else {
    throw Exception("could not identify DiningPeriod from text: $txt");
    // return null;
  }
}
