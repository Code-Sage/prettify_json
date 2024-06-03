import 'package:flutter_test/flutter_test.dart';
import 'dart:io' show File, Directory;
import 'dart:convert' show jsonDecode;

import 'package:prettify_json/prettify_json.dart' show prettifyJSON, minifyJSON;

void main() {
  test('Prettufy a JSON string, then minify it; print both!', () async {
    String input = await File("${Directory.current.path}/test/test.json").readAsString();
    var json = jsonDecode(input);
    input = input.trim();

    String prettified = prettifyJSON(json, indentSize: 4);
    String minified = minifyJSON(prettified);

    if (prettified != input) {
      expect(minified, input, reason: "JSON string was (probably) minified in file, and is now prettified!");
    }
    if (minified != input) {
      expect(prettified, input, reason: "JSON string was (probably) prettified in file, and is now minified!");
    }
  });
}
