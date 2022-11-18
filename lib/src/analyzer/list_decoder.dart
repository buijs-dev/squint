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

import "../common/normalize_spaces.dart";

///
extension RepeatedBuilder on Map<String,String> {

  ///
  Map<String,dynamic> toMap() {
    // TODO
    return <String,dynamic>{};
  }

  ///
  List<dynamic> toList() {
    final list = <dynamic>[];

    for(final key in keys) {

      // The value to be stored in a List.
      final value = this[key];

      // Remove final number because width does not matter here.
      // Then split on . (dot) to index of each list.
      final position = key
          .substring(0, key.lastIndexOf("."))
          .split(".")
          .where((o) => o != "")
          .map(int.parse)
          .toList();

      var _list = list;

      for(final index in position) {
        while(index >= _list.length) {
          _list.add(<dynamic>[]);
        }

        _list = _list[index] as List<dynamic>;
      }

      _list.add(value);
    }

    return list[0] as List<dynamic>;
  }
}

/// Utilities to parse a list value from JSON content.
extension ParseUtil on String {

  ///
  Map<String,String> unwrapObject({

    /// Can be set to true for testing purposes.
    ///
    /// The squint json decode method will normalize
    /// the entire JSON content before calling any methods.
    bool normalizeSpaces = false,
  }) {

    // TODO
    return {};
  }

  ///
  Map<String,String> unwrapList({
    required int maxDepth,

    /// Can be set to true for testing purposes.
    ///
    /// The squint json decode method will normalize
    /// the entire JSON content before calling any methods.
    bool normalizeSpaces = false,
  }) {

    var depth = 0;

    var size = <int,int>{};

    for(var i = 0; i <= maxDepth; i++) {
      size[i] = 0;
    }

    final output = <String, String>{};

    var key = ".0";

    var value = "";

    final chars = normalizeSpaces
        ? split("").normalizeSpaces
        : split("");

    for(final char in chars) {
      final token = _Token.fromChar(
        character: char,
        currentSize: size,
        currentDepth: depth,
        currentKey: key,
        currentValue: value,
        output: output,
      );
      key = token.key;
      value = token.value;
      depth = token.depth;
      size = token.size;
    }

    return output;
  }
}

///
class ListOpeningBracketToken extends _Token {

  ///
  ListOpeningBracketToken({
    required Map<int,int> currentSize,
    required int currentDepth,
    required String currentKey,
    required String currentValue,
  }): super(
    depth: currentDepth +1,
    size: currentSize,
    value: currentValue,
    key: "$currentKey.${currentSize[currentDepth]}"
  ) ;

}

///
class ListClosingBracketToken extends _Token {

  ///
  ListClosingBracketToken({
    required Map<int,int> currentSize,
    required int currentDepth,
    required String currentKey,
    required String currentValue,
    required Map<String, String> output,
  }): super(
      depth: currentDepth -1,
      size: _size(currentSize, currentDepth),
      value: _value(currentValue: currentValue, currentKey: currentKey, output: output),
      key: currentKey.substring(0, currentKey.lastIndexOf(".")),
  ) ;

}

///
class ListValueSeparatorToken extends _Token {

  ///
  ListValueSeparatorToken({
    required Map<int,int> currentSize,
    required int currentDepth,
    required String currentKey,
    required String currentValue,
    required Map<String, String> output,
  }): super(
    depth: currentDepth,
    size: _size(currentSize, currentDepth),
    value: _value(
        currentValue: currentValue,
        currentKey: currentKey,
        output: output
    ),
    key: currentKey.incrementWidth,
  ) ;

  static Map<int,int> _size(Map<int,int> currentSize, int depth) {
    final output = currentSize;
    final width = output[depth]!;
    output[depth] = width +1;
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
    required Map<int,int> currentSize,
    required int currentDepth,
    required String currentKey,
    required String currentValue,
    required String currentCharacter,
  }): super(
    depth: currentDepth,
    size: currentSize,
    value: "$currentValue$currentCharacter",
    key: currentKey,
  ) ;

}

String _value({
  required String currentValue,
  required String currentKey,
  required Map<String,String> output,
}) {
  var value = currentValue;

  if(value == "") {
    return value;
  }

  value = value.trim();

  if(value.startsWith('"')) {
    value = value.substring(1, value.length);
  }

  if(value.endsWith('"')) {
    value = value.substring(0, value.length-1);
  }

  output[currentKey] = value;
  return "";

}

Map<int,int> _size(Map<int,int> currentSize, int depth) {
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
  });

  factory _Token.fromChar({
    required String character,
    required Map<int,int> currentSize,
    required int currentDepth,
    required String currentKey,
    required String currentValue,
    required Map<String, String> output,
  }) {
    switch(character) {
      case "[" :
        return ListOpeningBracketToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          currentKey: currentKey,
          currentValue: currentValue,
        );
      case "]" :
        return ListClosingBracketToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          currentKey: currentKey,
          currentValue: currentValue,
          output: output,
        );
      case "," :
        return ListValueSeparatorToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          currentKey: currentKey,
          currentValue: currentValue,
          output: output,
        );
      default :
        return ListValueToken(
          currentDepth: currentDepth,
          currentSize: currentSize,
          currentKey: currentKey,
          currentValue: currentValue,
          currentCharacter: character,
        );
    }

  }

  final Map<int, int> size;

  final String key;

  final String value;

  final int depth;

}