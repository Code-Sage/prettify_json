import 'dart:convert' show jsonDecode;
import 'dart:math';

/// Checking if element is a valid JSON Data Type, as per https://www.w3schools.com/js/js_json_datatypes.asp
bool _isValidJSONType(dynamic elem) {
  return (elem is String || elem is num || elem is bool || elem == null || elem is List || elem is Map);
}

/// Returns formatted JSON string generated from [json] with [indentSize]
///
/// Throws an [ArgumentError] if [json] isn't of one of these types: String, num, bool, null, List, Map.
String prettifyJSON(json, {int indentSize = 2}) {
  if (!_isValidJSONType(json)) {
    throw ArgumentError("Parameter 'json' cannot be of type ${json.runtimeType.toString()}!");
  }
  if (json is String) {
    json = jsonDecode(json);
  }

  return _prettifyJSON(
    json,
    indentSize: indentSize,
    indentLevel: 0,
  );
}

/// Recursive helper function for generating prettified JSON string.
String _prettifyJSON(
  jsonElement, {
  required int indentSize,
  required int indentLevel,
}) {
  // Generate JSON string of [jsonElement] if its type is valid.
  if (_isValidJSONType(jsonElement)) {
    // Variable for storing prettified JSON string
    String prettifiedJSON = "";

    // Sized spaces
    String indentSpace = ' ' * ((indentLevel + 1) * indentSize);
    String levelSpace = ' ' * (indentLevel * indentSize);

    if (jsonElement is Map) {
      Map jsonMap = jsonElement;
      int keysRemaining = jsonMap.length;

      // Variable for storing prettified JSON string of object/map
      String mapJSON = "";

      // Space between key and value of JSON object properties
      String propSpace = ' ' * min(indentSize, 2);

      jsonMap.forEach((key, value) {
        if (_isValidJSONType(value)) {
          mapJSON += indentSpace;
          if (value is String) {
            mapJSON += "\"$key\":$propSpace\"$value\"";
          } else {
            mapJSON += "\"$key\":$propSpace${_prettifyJSON(value, indentSize: indentSize, indentLevel: indentLevel + 1)}";
          }

          // Append "\n" if this was the last entry in [jsonMap], otherwise ",\n"
          mapJSON += --keysRemaining > 0 ? ",\n" : "\n";
        } else {
          // Skip string generation/concatenation for JSON-incompatible data-types
          --keysRemaining;
        }
      });

      prettifiedJSON += "{";
      if (mapJSON.isNotEmpty) {
        prettifiedJSON += "\n$mapJSON$levelSpace";
      }
      prettifiedJSON += "}";
    } else if (jsonElement is List) {
      List jsonList = jsonElement;
      int elemsRemaining = jsonList.length;

      // Variable for storing prettified JSON string of array
      String listJSON = "";

      for (var e in jsonList) {
        if (_isValidJSONType(e)) {
          listJSON += indentSpace;
          if (e is String) {
            listJSON += "\"$e\"";
          } else {
            listJSON += _prettifyJSON(e, indentSize: indentSize, indentLevel: indentLevel + 1);
          }

          // Append "\n" if this was the last element in [jsonList], otherwise ",\n"
          listJSON += --elemsRemaining > 0 ? ",\n" : "\n";
        } else {
          // Skip string generation/concatenation for JSON-incompatible data-types
          --elemsRemaining;
        }
      }

      prettifiedJSON += "[";
      if (listJSON.isNotEmpty) {
        prettifiedJSON += "\n$listJSON$levelSpace";
      }
      prettifiedJSON += "]";
    } else {
      prettifiedJSON = jsonElement.toString();
    }
    return prettifiedJSON;
  } else {
    // ignore JSON-incompatible data-types
    return "";
  }
}

/// Removes all unneceaary white-spaces from [jsonStr], returning minified JSON string.
String minifyJSON(String jsonStr) {
  // RegEx credits: https://stackoverflow.com/questions/73319317/regex-remove-whitespace-from-json-ignoring-values
  RegExp extraWhiteSpaceRegex = RegExp(r'\s+(?=(?:(?:[^"]*"){2})*[^"]*$)');
  return jsonStr.replaceAll(extraWhiteSpaceRegex, "");
}
