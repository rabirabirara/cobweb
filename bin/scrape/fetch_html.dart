import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' show Document;
import 'package:http/http.dart' as http;

const uclaUrl = "https://menu.dining.ucla.edu";
const uclaMenusUrl = uclaUrl + "/Menus";
const uclaHoursUrl = uclaUrl + "/Hours";
const httpPrefix = "http://";
const httpsPrefix = "https://";

String? makeUrl(String url) {
  // if it begins with a slash, append it to uclaURL
  if (url.startsWith('/')) {
    return uclaUrl + url;
  } else if (url.startsWith(httpsPrefix) || url.startsWith(httpPrefix)) {
    return url;
  } else {
    throw Exception("$url seems to be neither child link nor absolute path!");
    // return null;
  }
}

Future<Document> getDocument(String url) async {
  var uri = Uri.parse(url);
  var response = await http.post(uri);
  return parse(response.body);
}
