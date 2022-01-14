// import 'dart:collection';

// import 'package:html/parser.dart';
// import 'package:http/http.dart';
import 'package:html/dom.dart';
// import 'package:quiver/iterables.dart';

// import 'cobweb.dart';
import 'fetch_html.dart';
import 'fetch_local_html.dart' show getLocalDocument;
import 'hours.dart' show Hours, Interval, DiningPeriod;
import 'restaurant.dart';
import 'util.dart';

Future<Map<String, Hours>> fetchHours() async {
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
  Map<String, Hours> locationHoursMap = {};

  for (final row in tableBody.children) {
    final cols = row.children;
    // cols[0] is the info cell
    final location = cols[0].children[0].text;

    // cols.sublist(1) are the hours; either closed elements or open with inner span
    final hourCells = cols.sublist(1);

    if (hourCells.length == 1) {
      // must be closed all day, or be ASUCLA's bullshit thing
      if (hourCells[0].className == "hours-open") {
        final asuclaUrl = hourCells[0].querySelector("a")?.attributes['href'];
        print("'$location' is open today; see ${makeUrl(asuclaUrl!)}");
      } else {
        print("'$location' is closed all day");
        locationHoursMap.putIfAbsent(location, () => Hours.newClosedAllDay());
      }
      continue;
    }

    var hours = Hours();

    // if has children then get the time from the inner span
    // if no children then must be closed
    for (int i = 0; i != mealTimes.length; i++) {
      if (hourCells[i].hasChildNodes()) {
        final timeSpan = hourCells[i].getElementsByClassName("hours-range");

        var period = _getPeriodFromText(mealTimes[i])!;
        Interval? interval;
        // if there are no elements with class "hours-range" then it's closed
        if (timeSpan.isNotEmpty) {
          interval = parseTimeSpan(timeSpan.first.text, period, today: dateStr);
        }
        // print("'$location' at $period: ${interval ?? 'CLOSED'}");
        hours.addInterval(interval);
      }
    }

    locationHoursMap.putIfAbsent(location, () => hours);
  }

  locationHoursMap.forEach((key, value) {
    print("$key: $value");
  });

  return locationHoursMap;
}

// from uclaMenusUrl
Future<Map<String, List<Menu>>> fetchShortMenus() async {
  var doc = await getDocument(uclaMenusUrl);
  // var doc = await getLocalDocument("menus-periods.html");

  // maps location to menus for all periods as available
  Map<String, List<Menu>> placeMenus = {};

  // main content div
  // children: nav-extras, announce, headers, detail link, menublock(cols?)
  var mainContentChildren = doc.getElementById("main-content")!.children;

  var justMenus = mainContentChildren.where((e) {
    return (e.id == "page-header" || e.className.contains("menu-block"));
  }).toList();

  // we have a linked map of periods
  // each period maps period element to a map of menus
  // each map of menus maps location name to shortMenu
  Map<String, List<Element>> periodMenus = {};
  String? period;
  List<Element> placeMenuElements = [];
  for (final e in justMenus) {
    if (e.id == "page-header") {
      // period is null if on first iteration
      if (period != null) {
        periodMenus.putIfAbsent(period, () => List.from(placeMenuElements));
        placeMenuElements.clear();
      }
      period = e.text;
    } else if (e.className.contains("menu-block")) {
      placeMenuElements.add(e);
    }
  }
  if (period != null) {
    periodMenus.putIfAbsent(period, () => placeMenuElements);
  }

  for (final p in periodMenus.entries) {
    var period = _getPeriodFromText(p.key);
    var location = _getLocationFromMenuElement(p.value.first)!;
    var menus = p.value.map((e) {
      var m = _getMenuFromMenuElement(e);
      // * Set the shortMenu's period.
      m.period = period;
      return m;
    }).toList();

    placeMenus.putIfAbsent(location, () => menus);
  }

  return placeMenus;
}

String? _getLocationFromMenuElement(Element e) {
  return e.querySelector(".col-header")?.text;
}

Menu _getMenuFromMenuElement(Element e) {
  var location = _getLocationFromMenuElement(e);

  var menu = Menu(location);

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

DiningPeriod? _getPeriodFromText(String txt) {
  if (txt.contains(RegExp("breakfast", caseSensitive: false))) {
    return DiningPeriod.breakfast;
  } else if (txt.contains(RegExp("lunch", caseSensitive: false))) {
    return DiningPeriod.lunch;
  } else if (txt.contains(RegExp(r"(extended|late)", caseSensitive: false))) {
    return DiningPeriod.beforemidnight;
  } else if (txt.contains(RegExp("dinner", caseSensitive: false))) {
    return DiningPeriod.dinner;
  } else {
    // error();
    return null;
  }
}
