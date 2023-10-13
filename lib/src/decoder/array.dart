// Copyright (c) 2021 - 2023 Buijs Software
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

/// Utility to construct a nested List structure
/// with strongly typed children.
///
/// {@category decoder}
extension RepeatedBuilder on Map<String, JsonNode> {
  /// Create a (nested) List structure from width-depth notation.
  ///
  /// The key String of this Map is expected to be a dot (.)
  /// separated list of numbers which act as width and depth
  /// coordinates for adding [JsonNode] values to the correct
  /// (sub) List.
  ///
  /// Key is constructed by [JsonArrayDecoder].
  ///
  /// {@category decoder}
  List toList<T, R>({List<T>? valueList}) {
    // List contains one or more null values if true.
    final isNullable = values.any((o) => o is JsonNull);

    // List without any null values to simplify Type determination.
    final valuesNotNull = values.where((o) => o is! JsonNull);

    if (valuesNotNull.every((node) => node is JsonString)) {
      return isNullable ? _toNullableStringList : _toStringList;
    }

    if (valuesNotNull.every((node) => node is JsonIntegerNumber)) {
      return isNullable ? _toNullableIntegerList : _toIntegerList;
    }

    if (valuesNotNull.every((node) => node is JsonFloatingNumber)) {
      return isNullable ? _toNullableDoubleList : _toDoubleList;
    }

    /// If a List contains both integers and floating point numbers,
    /// then all integers should be cast to a floating point.
    if (valuesNotNull.every(
        (node) => node is JsonFloatingNumber || node is JsonIntegerNumber)) {
      return map((key, value) => MapEntry(
              key,
              value is JsonIntegerNumber
                  ? JsonFloatingNumber(key: key, data: value.data.toDouble())
                  : value))
          .toList(valueList: isNullable ? <double?>[] : <double>[]);
    }

    if (valuesNotNull.every((node) => node is JsonBoolean)) {
      return isNullable ? _toNullableBooleanList : _toBooleanList;
    }

    if (valuesNotNull.every((node) => node is JsonObject)) {
      return _toObjectList(valueList: valueList ?? []);
    }

    if (valuesNotNull.every((node) => node is CustomJsonNode)) {
      if (valueList == null) {
        throw SquintException(
            "Unable to build a List because not Type is specified for CustomJsonNode.");
      }
      return _toCustomObjectList<T>(valueList: valueList);
    }

    throw SquintException(
        "Unable to build a List because not all children are of the same Type.");
  }

  /// Return a (nested) List of String.
  List get _toStringList => _toTypedList<String>(valueList: <String>[]);

  /// Return a (nested) List of String.
  List get _toNullableStringList =>
      _toTypedList<String?>(valueList: <String?>[]);

  /// Return a (nested) List of bool.
  List get _toBooleanList => _toTypedList<bool>(valueList: <bool>[]);

  /// Return a (nested) List of bool.
  List get _toNullableBooleanList => _toTypedList<bool?>(valueList: <bool?>[]);

  /// Return a (nested) List of int.
  List get _toIntegerList => _toTypedList<int>(valueList: <int>[]);

  /// Return a (nested) List of int.
  List get _toNullableIntegerList => _toTypedList<int?>(valueList: <int?>[]);

  /// Return a (nested) List of double.
  List get _toDoubleList => _toTypedList<double>(valueList: <double>[]);

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
      if (node != null) {
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
      if (node != null) {
        _insertAt<T>(
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
    final sizing = keys.map((key) => key.position).toList();

    final structure = buildListStructure(sizing, valueList: valueList);

    for (final key in keys) {
      final node = this[key];
      if (node != null) {
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

      var value = <String, dynamic>{};

      if (node != null) {
        if (value.values.any((val) => val is JsonNode)) {
          value = value.map<String, dynamic>((key, value) {
            return MapEntry<String, dynamic>(key, value.data);
          });
        }

        final valueType = node.valuesAllOfSameType;

        if (valueType != null) {
          switch (valueType.className) {
            case "String":
              value = node.toStringMap.dataTyped;
              break;
            case "double":
              value = node.toFloatMap.dataTyped;
              break;
            case "int":
              value = node.toIntegerMap.dataTyped;
              break;
            case "bool":
              value = node.toBooleanMap.dataTyped;
              break;
          }
        } else {
          value = node.getDataAsMap();
        }

        // Remove final number because width does not matter here.
        _insertAt(
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
    final sizing = keys.map((key) => key.position).toList();

    final structure = buildListStructure<T>(sizing, valueList: valueList);

    for (final key in keys) {
      final node = this[key];
      if (node != null) {
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

      if (node != null) {
        _insertAt<T>(
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

void _insertAt<T>({
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
    while (number >= temp.length) {
      // If true then list to be added contains T,
      // so we need to add <T>[].
      // if not then we can not specify the Type as T,
      // because there could be more Lists in between.
      if (index + 1 == position.length) {
        temp.add(List.of(valueList));
      } else {
        final tempListRuntimeType = temp.runtimeType.toString();
        final tempListDepth = "List".allMatches(tempListRuntimeType).length;
        final valueListDepth = "List".allMatches(valueListRuntimeType).length;
        final depth = tempListDepth - valueListDepth;
        if (depth > 0) {
          temp.add(getNestedList<T>(
              depth: depth - 1, valueList: List.of(valueList)));
        } else {
          throw SquintException(
              "valueList won't ever be a child of tempList because it's depth is deeper: $depth");
        }
      }
    }
    temp = temp[number] as List;
  });
}

extension on String {
  List<int> get position => substring(0, lastIndexOf("."))
      .split(".")
      .where((o) => o != "")
      .map(int.parse)
      .toList();
}

/// Decode a JSON Array String.
///
/// {@category decoder}
extension JsonArrayDecoder on String {
  /// Decode JSON String containing (sub) List(s)
  /// by saving each value and storing
  /// their position as width/depth coordinates.
  ///
  /// Example:
  ///
  /// Given a JSON Array:
  /// ```dart
  /// [[[ "hello", "goodbye" ], ["Sam", "Hanna"]]]
  /// ```
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
      if (previousToken is ListOpeningBracketToken &&
          currentToken is ListClosingBracketToken) {
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
  _PlaceHolder({required super.key}) : super(data: "");
}

/// Decode a Dart List.
///
/// {@category decoder}
extension ListDecoder on List {
  /// Decode List(s) by saving each value
  /// as [JsonNode] and storing
  /// their position as width/depth coordinates.
  ///
  /// Example:
  ///
  /// Given a List:
  /// ```dart
  /// [[[ "hello", "goodbye" ], ["Sam", "Hanna"]]]
  /// ```
  ///
  /// Would result in the following Map:
  /// ".0.0.0.0" : "hello"
  /// ".0.0.0.1" : "goodbye"
  /// ".0.0.1.1" : "Sam"
  /// ".0.0.1.2" : "Hanna"
  Map<String, JsonNode> get decodeList {
    var depth = 1;
    var nextChild = runtimeType.toString();
    while (nextChild.startsWith("List<")) {
      nextChild =
          nextChild.removePrefixIfPresent("List<").removePostfixIfPresent(">");
      depth += 1;
    }

    return JsonArray(key: "foo", data: this)
        .stringify
        .replaceFirstMapped(RegExp('(^"[^"]+?":)'), (match) => "")
        .decodeJsonArray(maxDepth: depth);
  }
}

/// Representation of an opening bracket, e.g. '['.
class ListOpeningBracketToken extends _Token {
  /// Construct a new instance.
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

/// Representation of a closing bracket, e.g. '['.
class ListClosingBracketToken extends _Token {
  /// Construct a new instance.
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

/// Representation of a opening squiggly bracket, e.g. '{'.
class ObjectOpeningBracketToken extends _Token {
  /// Construct a new instance.
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

/// Representation of characters who separate values inside a List, e.g. a comma: ','.
class ListValueSeparatorToken extends _Token {
  /// Construct a new instance.
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
  /// Construct a new instance.
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
      output[currentKey] =
          JsonObject(data: strObject.jsonDecode.data, key: currentKey);
      currentKey = keygen.incrementWidth;
    }

    return characters.length;
  } else {
    final counter = BracketCounter(
      characters: characters,
      startIndex: index,
      openingBracket: "{",
      closingBracket: "}",
    );

    final sublist = counter.contentBetweenBrackets;
    output[keygen.currentKey] = JsonObject(
        data: sublist.join().jsonDecode.data, key: keygen.currentKey);
    return counter.endIndex;
  }
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

/// Generate a key which describes the exact position of a value inside a nested List.
///
/// {@category decoder}
class ArrayDecodingKeyGenerator {
  /// Construct a new generator instance with key '.0'.
  ArrayDecodingKeyGenerator([this.currentKey = ".0"]);

  /// The current key.
  String currentKey;

  /// Determine the next key value depending on the last encountered token.
  String nextKey(List<String> keys, Type token) {
    switch (token) {
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

  /// Determine width value, e.g. position inside a List.
  String get incrementWidth {
    final strWidth = currentKey.substring(
        currentKey.lastIndexOf(".") + 1, currentKey.length);
    final intWidth = int.parse(strWidth) + 1;
    final prefix = currentKey.substring(0, currentKey.lastIndexOf("."));
    return currentKey = "$prefix.$intWidth";
  }
}

/// Build a nested List which has all required children to set all values.
///
/// Doing this beforehand makes it possible to make every (sub) List strongly typed.
/// Values can then be set without checking if a List is present/large enought etc.
///
/// {@category decoder}
List buildListStructure<T>(List<List<int>> positions, {List<T>? valueList}) {
  positions.sort((a, b) => a.length.compareTo(b.length));
  if (positions.isEmpty) {
    return [];
  }

  final maxDepth = positions.last.length - 1;
  final maxEntriesForEachDepth = <int>[];

  for (var i = 0; i <= maxDepth; i++) {
    final indexes = <int>[];
    for (final position in positions) {
      if (position.length > i) {
        indexes.add(position[i]);
      }
    }
    indexes.sort((int a, int b) => a.compareTo(b));
    maxEntriesForEachDepth.add(indexes.last);
  }
  maxEntriesForEachDepth.sort((a, b) => a.compareTo(b));
  return getNestedList<T>(
    depth: maxDepth,
    valueList: valueList ?? <T>[],
  );
}

/// Get a List<T> with 0 or more parent lists.
///
/// Specify [depth] to added one or more parent Lists.
///
/// Example:
/// [depth] 0 = List<T>
/// [depth] 2 = List<List<List<T>>>.
List getNestedList<T>({
  required int depth,
  required List<T> valueList,
}) {
  if (depth == 0) {
    return valueList;
  }

  return getNestedList(depth: depth - 1, valueList: _addParent(valueList));
}

/// Add another List arround the given List and keep the it strongly typed.
List<List<T>> _addParent<T>(List<T> list) => [list];

/// Get a List<String> with 0 or more parent lists.
///
/// Specify [depth] to added one or more parent Lists.
///
/// Example:
/// [depth] 0 = List<String>
/// [depth] 2 = List<List<List<String>>>.
List getNestedStringList(int depth) =>
    getNestedList<String>(depth: depth, valueList: <String>[]);

/// Get nested List with a nullable String child. See [getNestedStringList].
List getNestedNullableStringList(int depth) =>
    getNestedList<String?>(depth: depth, valueList: <String?>[]);

/// Get a List<int> with 0 or more parent lists.
///
/// Specify [depth] to added one or more parent Lists.
///
/// Example:
/// [depth] 0 = List<int>
/// [depth] 2 = List<List<List<int>>>.
List getNestedIntList(int depth) =>
    getNestedList<int>(depth: depth, valueList: <int>[]);

/// Get nested List with a nullable int child. See [getNestedIntList].
List getNestedNullableIntList(int depth) =>
    getNestedList<int?>(depth: depth, valueList: <int?>[]);

/// Get a List<double> with 0 or more parent lists.
///
/// Specify [depth] to added one or more parent Lists.
///
/// Example:
/// [depth] 0 = List<double>
/// [depth] 2 = List<List<List<double>>>.
List getNestedDoubleList(int depth) =>
    getNestedList<double>(depth: depth, valueList: <double>[]);

/// Get nested List with a nullable double child. See [getNestedDoubleList].
List getNestedNullableDoubleList(int depth) =>
    getNestedList<double?>(depth: depth, valueList: <double?>[]);

/// Get a List<bool> with 0 or more parent lists.
///
/// Specify [depth] to added one or more parent Lists.
///
/// Example:
/// [depth] 0 = List<bool>
/// [depth] 2 = List<List<List<bool>>>.
List getNestedBoolList(int depth) =>
    getNestedList<bool>(depth: depth, valueList: <bool>[]);

/// Get nested List with a nullable bool child. See [getNestedBoolList].
List getNestedNullableBoolList(int depth) =>
    getNestedList<bool?>(depth: depth, valueList: <bool?>[]);
