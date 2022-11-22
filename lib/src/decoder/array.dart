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

import "../../squint.dart";
import "../common/common.dart";

///
extension RepeatedBuilder on Map<String, JsonElement> {
  ///
  List<dynamic> toList() {
    final list = <dynamic>[];

    final isNullable = values.any((o) => o is JsonNull);

    for (final key in keys) {
      final element = this[key];

      // The value to be stored in a List.
      dynamic value = element?.data;

      if (value is Map && value.values.first is JsonElement) {
        value = value.map<String, dynamic>((dynamic key, dynamic value) {
          return MapEntry<String, dynamic>("$key", value.data);
        });
      }

      // Remove final number because width does not matter here.
      // Then split on . (dot) to index of each list.
      final position = key
          .substring(0, key.lastIndexOf("."))
          .split(".")
          .where((o) => o != "")
          .map(int.parse)
          .toList();

      var _list = list;

      final maxDepth = position.length;

      var currentDepth = 0;

      for (final index in position) {
        currentDepth += 1;

        while (index > _list.length) {
          _list.add(<dynamic>[]);
        }

        if (index == _list.length) {
          if (currentDepth == maxDepth) {
            if (isNullable) {
              if (element is JsonNumber) {
                _list.add(<double?>[]);
              } else if (element is JsonString) {
                _list.add(<String?>[]);
              } else if (element is JsonBoolean) {
                _list.add(<bool?>[]);
              }
            } else {
              if (element is JsonNumber) {
                _list.add(<double>[]);
              } else if (element is JsonString) {
                _list.add(<String>[]);
              } else if (element is JsonBoolean) {
                _list.add(<bool>[]);
              } else if (element is JsonObject) {
                _list.add(<Map<String, dynamic>>[]);
              }
            }
          } else {
            _list.add(<dynamic>[]);
          }
        }

        _list = _list[index] as List;
      }

      _list.add(value);
    }

    return list[0] as List;
  }
}

/// Utilities to parse a list value from JSON content.
extension ParseUtil on String {
  ///
  Map<String, JsonElement> unwrapList({
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

    final output = <String, JsonElement>{};

    final input = normalizeSpaces ? split("").normalizeSpaces : split("");

    var currentDepth = 0;

    var currentKey = ".0";

    var currentValue = "";

    _Token? previousToken;

    _Token? currentToken;

    var i = 0;

    while (i < input.length) {
      previousToken = currentToken;
      currentToken = _Token.fromChar(
        previousToken: previousToken,
        characters: input,
        currentSize: size,
        currentDepth: currentDepth,
        currentKey: currentKey,
        currentValue: currentValue,
        output: output,
        index: i,
      );

      i = currentToken.index;
      size = currentToken.size;
      currentDepth = currentToken.depth;
      currentKey = currentToken.key;
      currentValue = currentToken.value;
    }

    return output;
  }
}

///
class ListOpeningBracketToken extends _Token {
  ///
  ListOpeningBracketToken({
    required Map<int, int> currentSize,
    required int currentDepth,
    required String currentKey,
    required String currentValue,
    required int index,
  }) : super(
            index: index,
            depth: currentDepth + 1,
            size: currentSize,
            value: currentValue,
            key: "$currentKey.${currentSize[currentDepth]!}");
}

///
class ListClosingBracketToken extends _Token {
  ///
  ListClosingBracketToken({
    required Map<int, int> currentSize,
    required int currentDepth,
    required String currentKey,
    required String currentValue,
    required Map<String, JsonElement> output,
    required int index,
  }) : super(
          index: index,
          depth: currentDepth - 1,
          size: _size(currentSize, currentDepth),
          value: _simpleValue(
              currentValue: currentValue,
              currentKey: currentKey,
              output: output),
          key: currentKey.substring(0, currentKey.lastIndexOf(".")),
        );
}

///
class ObjectOpeningBracketToken extends _Token {
  ///
  ObjectOpeningBracketToken({
    required Map<int, int> currentSize,
    required int currentDepth,
    required String currentKey,
    required int index,
    required Map<String, JsonElement> output,
    required List<String> characters,
    required bool nestedInList,
  }) : super(
          index: _setObjectValueAndReturnRemainder(
            nestedInList: nestedInList,
            output: output,
            characters: characters,
            index: index,
            key: currentKey.incrementWidth,
          ),
          depth: currentDepth,
          size: currentSize,
          value: "",
          key: currentKey.substring(0, currentKey.lastIndexOf(".")),
        );
}

int _setObjectValueAndReturnRemainder({
  required String key,
  required int index,
  required Map<String, JsonElement> output,
  required List<String> characters,
  required bool nestedInList,
}) {
  if (nestedInList) {
    final sublist = characters.sublist(1, characters.length - 1);

    final stringObjects = sublist
        .join()
        .split("},")
        .map((str) => str.endsWith("}") ? str : "$str}");

    var currentKey = key;
    for (final strObject in stringObjects) {
      final value = strObject.jsonDecode;
      output[currentKey] = value;
      currentKey = currentKey.incrementWidth;
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

    final value = sublist.join().jsonDecode;

    output[key] = value;
    return counter.endIndex;
  }
}

///
class ListValueSeparatorToken extends _Token {
  ///
  ListValueSeparatorToken({
    required Map<int, int> currentSize,
    required int currentDepth,
    required String currentKey,
    required String currentValue,
    required Map<String, JsonElement> output,
    required int index,
  }) : super(
          index: index,
          depth: currentDepth,
          size: _size(currentSize, currentDepth),
          value: _simpleValue(
            currentValue: currentValue,
            currentKey: currentKey,
            output: output,
          ),
          key: currentKey.incrementWidth,
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
    required String currentKey,
    required String currentValue,
    required String currentCharacter,
    required int index,
  }) : super(
          index: index,
          depth: currentDepth,
          size: currentSize,
          value: "$currentValue$currentCharacter",
          key: currentKey,
        );
}

String _simpleValue({
  required String currentValue,
  required String currentKey,
  required Map<String, JsonElement> output,
}) {
  var value = currentValue;

  if (value == "") {
    return "";
  }

  value = value.trim();

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

  /// - Number
  final doubleValue = double.tryParse(value);

  if (doubleValue != null) {
    output[currentKey] = JsonNumber(key: currentKey, data: doubleValue);
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

extension on String {
  String get incrementWidth {
    final depthKey = substring(0, lastIndexOf("."));
    final width = substring(lastIndexOf(".") + 1, length);
    return "$depthKey.${int.parse(width) + 1}";
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
    required String currentKey,
    required String currentValue,
    required Map<String, JsonElement> output,
    required int index,
    required _Token? previousToken,
  }) {
    switch (characters[index]) {
      case "[":
        return ListOpeningBracketToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          currentKey: currentKey,
          currentValue: currentValue,
          index: index + 1,
        );
      case "]":
        return ListClosingBracketToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          currentKey: currentKey,
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
          currentKey: currentKey,
          output: output,
          index: index + 1,
        );
      case ",":
        return ListValueSeparatorToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          currentKey: currentKey,
          currentValue: currentValue,
          output: output,
          index: index + 1,
        );
      default:
        return ListValueToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          currentKey: currentKey,
          currentValue: currentValue,
          currentCharacter: characters[index],
          index: index + 1,
        );
    }
  }

  final Map<int, int> size;

  final String key;

  final String value;

  final int depth;

  final int index;
}
