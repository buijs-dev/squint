// Copyright (c) 2021 - 2022 Buijs Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


// ignore_for_file: avoid_annotating_with_dynamic

import "../ast/ast.dart";
import "../common/common.dart";
import "../converters/converters.dart";
import "../decoder/decoder.dart";
import "lists.dart";

/// Utility to construct a nested List structure
/// with strongly typed children.
extension RepeatedBuilder on Map<String, JsonNode> {
  /// Create a (nested) List structure from width-depth notation.
  ///
  /// The key String of this Map is expected to be a dot (.)
  /// separated list of numbers which act as width and depth
  /// coordinates for adding [JsonNode] values to the correct
  /// (sub) List.
  ///
  /// Key is constructed by [JsonArrayDecoder].
  List toList<T,R>({List<T>? valueList}) {

    // List contains one or more null values if true.
    final isNullable = values.any((o) => o is JsonNull);

    // List without any null values to simplify Type determination.
    final valuesNotNull = values.where((o) => o is! JsonNull);

    if(valuesNotNull.every((node) => node is JsonString)) {
      return isNullable ? _toNullableStringList : _toStringList;
    }

    if(valuesNotNull.every((node) => node is JsonIntegerNumber)) {
      return isNullable ? _toNullableIntegerList : _toIntegerList;
    }

    if(valuesNotNull.every((node) => node is JsonFloatingNumber)) {
      return isNullable ? _toNullableDoubleList : _toDoubleList;
    }

    /// If a List contains both integers and floating point numbers,
    /// then all integers should be cast to a floating point.
    if(valuesNotNull.every((node) => node is JsonFloatingNumber || node is JsonIntegerNumber)) {
      return map((key, value) => MapEntry(
          key,
          value is JsonIntegerNumber
              ? JsonFloatingNumber(key: key, data: value.data.toDouble())
              : value)).toList(valueList: isNullable ? <double?>[] : <double>[]);
    }

    if(valuesNotNull.every((node) => node is JsonBoolean)) {
      return isNullable ? _toNullableBooleanList : _toBooleanList;
    }

    if(valuesNotNull.every((node) => node is JsonObject)) {
      return _toObjectList(valueList: valueList ?? []);
    }

    if(valuesNotNull.every((node) => node is CustomJsonNode)) {
      if(valueList == null) {
        throw SquintException(
            "Unable to build a List because not Type is specified for CustomJsonNode.");
      }
      return _toCustomObjectList<T>(valueList: valueList);
    }

    throw SquintException("Unable to build a List because not all children are of the same Type.");

  }

  /// Return a (nested) List of String.
  List get _toStringList =>
      _toTypedList<String>(valueList: <String>[]);

  /// Return a (nested) List of String.
  List get _toNullableStringList =>
      _toTypedList<String?>(valueList: <String?>[]);

  /// Return a (nested) List of bool.
  List get _toBooleanList =>
      _toTypedList<bool>(valueList: <bool>[]);

  /// Return a (nested) List of bool.
  List get _toNullableBooleanList =>
      _toTypedList<bool?>(valueList: <bool?>[]);

  /// Return a (nested) List of int.
  List get _toIntegerList =>
      _toTypedList<int>(valueList: <int>[]);

  /// Return a (nested) List of int.
  List get _toNullableIntegerList =>
      _toTypedList<int?>(valueList: <int?>[]);

  /// Return a (nested) List of double.
  List get _toDoubleList =>
      _toTypedList<double>(valueList: <double>[]);

  /// Return a (nested) List of double.
  List get _toNullableDoubleList =>
      _toTypedList<double?>(valueList: <double?>[]);

  List _toTypedList<T>({
    required List<T> valueList,
  }) {
    final sizing = keys.map((key) => key.position).toList();
    final structure = buildListStructure<T>(sizing);

    for (final key in keys) {
      final node = this[key];
      if(node != null) {
        _prefill<T>(
          value: node.data as T,
          // Remove first index because you always start
          // adding inside a List (first index == parent List).
          position: key.position..removeAt(0),
          valueList: valueList,
          structure: structure,
        );
      }
    }

    for (final key in keys) {
      final node = this[key];
      if(node != null) {
        insertAt<T>(
          value: node.data as T,
          // Remove first index because you always start
          // adding inside a List (first index == parent List).
          position: key.position..removeAt(0),
          valueList: valueList,
          structure: structure,
        );
      }
    }

    return structure;
  }

  List _toObjectList({
    required List valueList,
  }) {

    final sizing =
      keys.map((key) => key.position).toList();

    final structure =
      buildListStructure(sizing, valueList: valueList);

    for (final key in keys) {
      final node = this[key];
      if(node != null) {
        _prefill(
          value: node.data,
          // Remove first index because you always start
          // adding inside a List (first index == parent List).
          position: key.position..removeAt(0),
          valueList: valueList,
          structure: structure,
        );
      }
    }

    for (final key in keys) {
      final node = this[key] as JsonObject?;

      var value = <String,dynamic>{};

      if(node != null) {
        if (value.values.any((val) => val is JsonNode)) {
          value = value.map<String, dynamic>((key, value) {
            return MapEntry<String, dynamic>(key, value.data);
          });
        }

        final valueType = node.valuesAllOfSameType;

        if(valueType != null) {
          switch (valueType.className) {
            case "String":
              value = node.toStringMap.rawData;
              break;
            case "double":
              value = node.toFloatMap.rawData;
              break;
            case "int":
              value = node.toIntegerMap.rawData;
              break;
            case "bool":
              value = node.toBooleanMap.rawData;
              break;
          }
        } else {
          value = node.rawData();
        }

        // Remove final number because width does not matter here.
        insertAt(
          value: value,
          position: key.position..removeAt(0),
          valueList: valueList,
          structure: structure,
        );
      }

    }
    return structure;
  }

  List _toCustomObjectList<T>({
    required List<T> valueList,
  }) {

    final sizing =
      keys.map((key) => key.position).toList();

    final structure =
      buildListStructure<T>(sizing, valueList: valueList);

    for (final key in keys) {
      final node = this[key];
      if(node != null) {
        _prefill<T>(
          value: node.data as T,
          // Remove first index because you always start
          // adding inside a List (first index == parent List).
          position: key.position..removeAt(0),
          valueList: valueList,
          structure: structure,
        );
      }
    }

    for (final key in keys) {
      final node = this[key] as CustomJsonNode?;

      if(node != null) {
        insertAt<T>(
          value: node.data as T,
          position: key.position..removeAt(0),
          valueList: valueList,
          structure: structure,
        );
      }
    }

    return structure as List<T>;
  }
}

///
void insertAt<T>({
  required T value,
  required List<int> position,
  required List<T> valueList,
  required List structure,
}) {

  var temp = structure;

  position.asMap().forEach((index, number) {
    temp = temp[number] as List;
  });

  temp.add(value);
}

void _prefill<T>({
  required T value,
  required List<int> position,
  required List<T> valueList,
  required List structure,
}) {

  final valueListRuntimeType = valueList.runtimeType.toString();

  var temp = structure;

  position.asMap().forEach((index, number) {
    while(number >= temp.length) {
      // If true then list to be added contains T,
      // so we need to add <T>[].
      // if not then we can not specify the Type as T,
      // because there could be more Lists in between.
      if (index + 1 == position.length) {
        temp.add(List.of(valueList));
      } else {
        final tempListRuntimeType = temp.runtimeType.toString();
        final tempListDepth = "List"
            .allMatches(tempListRuntimeType)
            .length;
        final valueListDepth = "List"
            .allMatches(valueListRuntimeType)
            .length;
        final depth = tempListDepth - valueListDepth;
        if (depth > 0) {
          temp.add(getNestedList<T>(depth: depth-1, valueList: List.of(valueList)));
        } else {
          throw SquintException(
              "valueList won't ever be a child of tempList because it's depth is deeper: $depth"
          );
        }
      }
    }
    temp = temp[number] as List;
  });

}

extension on String {
  List<int> get position =>
      substring(0, lastIndexOf("."))
          .split(".")
          .where((o) => o != "")
          .map(int.parse)
          .toList();
}

/// Decode a JSON Array String.
extension JsonArrayDecoder on String {
  /// Decode JSON String containing (sub) List(s)
  /// by saving each value and storing
  /// their position as width/depth coordinates.
  ///
  /// Example:
  ///
  /// Given a JSON Array:
  /// [[[ "hello", "goodbye" ], ["Sam", "Hanna"]]]
  ///
  /// Would result in the following Map:
  /// ".0.0.0.0" : "hello"
  /// ".0.0.0.1" : "goodbye"
  /// ".0.0.1.1" : "Sam"
  /// ".0.0.1.2" : "Hanna"
  Map<String, JsonNode> decodeJsonArray({
    required int maxDepth,

    /// Can be set to true for testing purposes.
    ///
    /// The squint json decode method will normalize
    /// the entire JSON content before calling any methods.
    bool normalizeSpaces = false,
  }) {
    var size = <int, int>{};

    for (var i = 0; i <= maxDepth; i++) {
      size[i] = 0;
    }

    final output = <String, JsonNode>{};

    final input = normalizeSpaces ? split("").normalizeSpaces : split("");

    var currentDepth = 0;

    final keygen = ArrayDecodingKeyGenerator();

    var currentValue = "";

    _Token? previousToken;

    _Token? currentToken;

    var i = 0;

    while (i < input.length) {
      if(previousToken is ListOpeningBracketToken && currentToken is ListClosingBracketToken) {
        output[keygen.currentKey] = _PlaceHolder(key: keygen.currentKey);
      }
      previousToken = currentToken;
      currentToken = _Token.fromChar(
        previousToken: previousToken,
        characters: input,
        currentSize: size,
        currentDepth: currentDepth,
        keygen: keygen,
        currentValue: currentValue,
        output: output,
        index: i,
      );

      i = currentToken.index;
      size = currentToken.size;
      currentDepth = currentToken.depth;
      currentValue = currentToken.value;
    }

    return output..removeWhere((key, value) => value is _PlaceHolder);
  }
}

class _PlaceHolder extends JsonNode {
  _PlaceHolder({required super.key}): super(data: "");
}

/// Decode a Dart List.
extension ListDecoder on List {
  /// Decode List(s) by saving each value
  /// as [JsonNode] and storing
  /// their position as width/depth coordinates.
  ///
  /// Example:
  ///
  /// Given a List:
  /// [[[ "hello", "goodbye" ], ["Sam", "Hanna"]]]
  ///
  /// Would result in the following Map:
  /// ".0.0.0.0" : "hello"
  /// ".0.0.0.1" : "goodbye"
  /// ".0.0.1.1" : "Sam"
  /// ".0.0.1.2" : "Hanna"
  Map<String, JsonNode> get decodeList {
    var depth = 1;
    var nextChild = runtimeType.toString();
    while(nextChild.startsWith("List<")) {
      nextChild = nextChild
          .removePrefixIfPresent("List<")
          .removePostfixIfPresent(">");
      depth +=1;
    }

    return JsonArray(key: "foo", data: this).stringify
        .replaceFirstMapped(RegExp('(^"[^"]+?":)'), (match) => "")
        .decodeJsonArray(maxDepth: depth);
  }

}

///
class ListOpeningBracketToken extends _Token {
  ///
  ListOpeningBracketToken({
    required Map<int, int> currentSize,
    required int currentDepth,
    required ArrayDecodingKeyGenerator keygen,
    required String currentValue,
    required Map<String, JsonNode> output,
    required int index,
  }) : super(
            index: index,
            depth: currentDepth + 1,
            size: currentSize,
            value: currentValue,
            key: keygen.nextKey(output.keys.toList(), ListOpeningBracketToken),
  );

}


///
class ListClosingBracketToken extends _Token {
  ///
  ListClosingBracketToken({
    required Map<int, int> currentSize,
    required int currentDepth,
    required ArrayDecodingKeyGenerator keygen,
    required String currentValue,
    required Map<String, JsonNode> output,
    required int index,
  }) : super(
          index: index,
          depth: currentDepth - 1,
          size: _size(currentSize, currentDepth),
          value: _simpleValue(
              currentValue: currentValue,
              currentKey: keygen.currentKey,
              output: output,
          ),
    key: keygen.nextKey(output.keys.toList(), ListClosingBracketToken),
  );
}

///
class ObjectOpeningBracketToken extends _Token {
  ///
  ObjectOpeningBracketToken({
    required Map<int, int> currentSize,
    required int currentDepth,
    required ArrayDecodingKeyGenerator keygen,
    required int index,
    required Map<String, JsonNode> output,
    required List<String> characters,
    required bool nestedInList,
  }) : super(
          index: _setObjectValueAndReturnRemainder(
            nestedInList: nestedInList,
            output: output,
            characters: characters,
            index: index,
            keygen: keygen,
          ),
          depth: currentDepth,
          size: currentSize,
          value: "",
          key: keygen.currentKey,
        );
}

int _setObjectValueAndReturnRemainder({
  required ArrayDecodingKeyGenerator keygen,
  required int index,
  required Map<String, JsonNode> output,
  required List<String> characters,
  required bool nestedInList,
}) {
  if (nestedInList) {
    final sublist = characters.sublist(1, characters.length - 1);

    final stringObjects = sublist
        .join()
        .split("},")
        .map((str) => str.endsWith("}") ? str : "$str}");

    var currentKey = keygen.currentKey;
    for (final strObject in stringObjects) {
      output[currentKey] = JsonObject(strObject.jsonDecode.data, currentKey);
      currentKey = keygen.incrementWidth;
    }

    return characters.length;
  } else {
    final counter = BracketCount(
      characters: characters,
      startIndex: index,
      openingBracket: "{",
      closingBracket: "}",
    );

    final sublist = counter.contentBetweenBrackets;
    output[keygen.currentKey] = JsonObject(sublist.join().jsonDecode.data, keygen.currentKey);
    return counter.endIndex;
  }
}

///
class ListValueSeparatorToken extends _Token {
  ///
  ListValueSeparatorToken({
    required Map<int, int> currentSize,
    required int currentDepth,
    required ArrayDecodingKeyGenerator keygen,
    required String currentValue,
    required Map<String, JsonNode> output,
    required int index,
  }) : super(
          index: index,
          depth: currentDepth,
          size: _size(currentSize, currentDepth),
          value: _simpleValue(
            currentValue: currentValue,
            currentKey: keygen.currentKey,
            output: output,
          ),
          key: keygen.nextKey(output.keys.toList(), ListValueSeparatorToken),
        );

  static Map<int, int> _size(Map<int, int> currentSize, int depth) {
    final output = currentSize;
    final width = output[depth] ?? 0;
    output[depth] = width + 1;
    return output;
  }
}

/// A token representing a character inside a List value.
///
/// Example:
///
/// ```
/// ["a", "bcd", "ez"]
/// ```
/// ", a, ", b, c, d, ", ", e, z and " are all ListValueTokens.
///
class ListValueToken extends _Token {
  ///
  ListValueToken({
    required Map<int, int> currentSize,
    required int currentDepth,
    required ArrayDecodingKeyGenerator keygen,
    required String currentValue,
    required String currentCharacter,
    required int index,
  }) : super(
          index: index,
          depth: currentDepth,
          size: currentSize,
          value: "$currentValue$currentCharacter",
          key: keygen.currentKey,
        );
}

String _simpleValue({
  required String currentValue,
  required String currentKey,
  required Map<String, JsonNode> output,
}) {
  final value = currentValue.trim();

  if (value == "") {
    return "";
  }

  /// String
  if (value.startsWith('"') && value.endsWith('"')) {
    output[currentKey] = JsonString(
      key: currentKey,
      data: value.substring(1, value.length).substring(0, value.length - 2),
    );
    return "";
  }

  /// - Boolean TRUE
  if (value.toUpperCase() == "TRUE") {
    output[currentKey] = JsonBoolean(
      key: currentKey,
      data: true,
    );
    return "";
  }

  /// - Boolean TRUE
  if (value.toUpperCase() == "FALSE") {
    output[currentKey] = JsonBoolean(
      key: currentKey,
      data: false,
    );
    return "";
  }

  /// - NULL
  if (value.toUpperCase() == "NULL") {
    output[currentKey] = JsonNull(
      key: currentKey,
    );
    return "";
  }

  /// - Integer Number
  final intValue = int.tryParse(value);

  if (intValue != null) {
    output[currentKey] = JsonIntegerNumber(key: currentKey, data: intValue);
    return "";
  }

  /// - Floating Number
  final doubleValue = double.tryParse(value);

  if (doubleValue != null) {
    output[currentKey] = JsonFloatingNumber(key: currentKey, data: doubleValue);
    return "";
  }

  throw SquintException(
    "Unsupported JSON value: '$value'. Not a String, Boolean, Null or Number value.",
  );
}

Map<int, int> _size(Map<int, int> currentSize, int depth) {
  final output = currentSize;
  final width = output[depth]! + 1;
  output[depth] = width;
  return output;
}

abstract class _Token {
  _Token({
    required this.size,
    required this.key,
    required this.value,
    required this.depth,
    required this.index,
  });

  factory _Token.fromChar({
    required List<String> characters,
    required Map<int, int> currentSize,
    required int currentDepth,
    required ArrayDecodingKeyGenerator keygen,
    required String currentValue,
    required Map<String, JsonNode> output,
    required int index,
    required _Token? previousToken,
  }) {
    switch (characters[index]) {
      case "[":
        return ListOpeningBracketToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          keygen: keygen,
          currentValue: currentValue,
          output: output,
          index: index + 1,
        );
      case "]":
        return ListClosingBracketToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          keygen: keygen,
          currentValue: currentValue,
          output: output,
          index: index + 1,
        );
      case "{":
        return ObjectOpeningBracketToken(
          nestedInList: previousToken is ListOpeningBracketToken,
          characters: characters,
          currentDepth: currentDepth,
          currentSize: currentSize,
          keygen: keygen,
          output: output,
          index: index + 1,
        );
      case ",":
        return ListValueSeparatorToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          keygen: keygen,
          currentValue: currentValue,
          output: output,
          index: index + 1,
        );
      default:
        return ListValueToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          keygen: keygen,
          currentValue: currentValue,
          currentCharacter: characters[index],
          index: index + 1,
        );
    }
  }

  final Map<int, int> size;

  final String value;

  final int depth;

  final int index;

  final String key;
}

///
class ArrayDecodingKeyGenerator {
  ///
  ArrayDecodingKeyGenerator([this.currentKey = ".0"]);

  ///
  String currentKey;

  ///
  String nextKey(List<String> keys, Type token) {
    switch(token) {
      case ListOpeningBracketToken:
        currentKey = "$currentKey.0";
        break;
      case ListClosingBracketToken:
        currentKey = currentKey.substring(0, currentKey.lastIndexOf("."));
        break;
      case ListValueSeparatorToken:
        incrementWidth;
    }

    return currentKey;
  }

  ///
  String get incrementWidth {
    final strWidth = currentKey.substring(currentKey.lastIndexOf(".") + 1, currentKey.length);
    final intWidth = int.parse(strWidth) + 1;
    final prefix = currentKey.substring(0, currentKey.lastIndexOf("."));
    return currentKey = "$prefix.$intWidth";

  }

}