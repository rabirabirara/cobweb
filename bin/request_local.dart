import 'dart:io';

import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;

Future<Document?> getLocalDocument(String path) async {
  final filepath = path;
  final file = File(filepath);
  if (await file.exists()) {
    final contents = await file.readAsString();
    return parse(contents);
  } else {
    print("couldn't find file! $filepath");
  }
}
