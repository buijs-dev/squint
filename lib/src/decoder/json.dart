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

// ignore_for_file: unnecessary_this

import "../ast/ast.dart";
import "../common/common.dart";

/// Decode a JSON String as [JsonObject].
JsonObject toJsonObject(String json) =>
  json.jsonDecode;

/// Decoded a JSON String as [JsonObject].
extension JsonDecoder on String {
  /// Decode a JSON String as [JsonNode]
  JsonObject get jsonDecode {
    var chars = substring(
      indexOf("{") + 1,
      lastIndexOf("}"),
    ).split("").normalizeSpaces;

    final data = <String, JsonNode>{};

    while (chars.isNotEmpty) {
      final pkey = ProcessingKey(chars);
      final key = pkey.key;
      chars = pkey.chars;

      if (key == null) {
        continue;
      }

      final pval = ProcessingValue(key, chars);
      final value = pval.value;
      chars = pval.chars;

      if (value != null) {
        data[key] = value;
      }
    }

    return JsonObject(data: data);
  }
}

///
abstract class JsonProcessingStep {
  ///
  const JsonProcessingStep();
}

///
class ProcessingKey extends JsonProcessingStep {
  ///
  ProcessingKey(List<String> chars) {
    final startIndex = chars.indexOf('"');

    if (startIndex == -1) {
      return;
    }

    final subList = chars.sublist(startIndex + 1, chars.length);
    final endIndex = subList.indexOf('"');

    if (endIndex == -1) {
      return;
    }

    final keyList = subList.sublist(0, endIndex);
    this.key = keyList.join();
    this.chars = subList.sublist(endIndex + 1, subList.length);
  }

  ///
  String? key;

  ///
  List<String> chars = [];
}

///
class ProcessingValue extends JsonProcessingStep {
  ///
  ProcessingValue(String key, List<String> chars) {
    var index = chars.indexOf(":");

    var processing = index != -1;

    index += 1;

    while (processing) {
      final token = chars[index];

      switch (token) {
        case "":
        case " ":
          index += 1;
          continue;
        case '"':
          processing = false;
          final subList = chars.sublist(index + 1, chars.length);
          final endIndex = subList.indexOf('"');
          final valueList = subList.sublist(0, endIndex);
          value = JsonString(key: key, data: valueList.join());
          this.chars = subList.sublist(endIndex + 1, subList.length);
          return;
        case "[":
          processing = false;
          final counter = BracketCount(
            characters: chars,
            startIndex: index,
            openingBracket: "[",
            closingBracket: "]",
          );
          final sublist = counter.contentBetweenBrackets;
          this.value = JsonArray.parse(
            key: key,
            content: sublist.join(),
            depth: counter.totalDepth,
          );
          this.chars = chars.sublist(counter.endIndex, chars.length);
          return;
        case "{":
          processing = false;

          final counter = BracketCount(
            characters: chars,
            startIndex: index,
            openingBracket: "{",
            closingBracket: "}",
          );

          final sublist = counter.contentBetweenBrackets;
          this.value = JsonObject(data: sublist.join().jsonDecode.data, key: key);
          this.chars = chars.sublist(counter.endIndex, chars.length);
          return;
        default:
          processing = false;

          final maybeNumber = _maybeNumber(
            content: chars.sublist(index, chars.length).join(),
            key: key,
          );

          if (maybeNumber != null) {
            this.value = maybeNumber;
            this.chars = [];
            return;
          }

          if (chars.length >= index + 4) {
            if ("NULL" ==
                chars.sublist(index, index + 4).join().toUpperCase()) {
              this.value = JsonNull(key: key);
              this.chars = chars.sublist(index + 4, chars.length);
              return;
            }

            if ("TRUE" ==
                chars.sublist(index, index + 4).join().toUpperCase()) {
              this.value = JsonBoolean(key: key, data: true);
              this.chars = chars.sublist(index + 4, chars.length);
              return;
            }
          }

          if (chars.length >= index + 5) {
            if ("FALSE" ==
                chars.sublist(index, index + 5).join().toUpperCase()) {
              this.value = JsonBoolean(key: key, data: false);
              this.chars = chars.sublist(index + 5, chars.length);
              return;
            }
          }

          final breakers = [" ", "[", "]", "{", "}", ","];

          final subList = [chars[index]];
          index += 1;
          while (index < chars.length) {
            final char = chars[index];

            if (breakers.contains(char)) {
              this.chars = chars.sublist(index, chars.length);
              this.value = _maybeNumber(key: key, content: subList.join());
              return;
            } else {
              subList.add(char);
            }

            index += 1;
          }

          throw SquintException("Failed to parse JSON");
      }
    }
  }

  ///
  JsonNode? value;

  ///
  List<String> chars = [];
}

JsonNode? _maybeNumber({
  required String content,
  required String key,
}) {
  final intValue = int.tryParse(content);

  if (intValue != null) {
    return JsonIntegerNumber(key: key, data: intValue);
  }

  final doubleValue = double.tryParse(content);

  if (doubleValue != null) {
    return JsonFloatingNumber(key: key, data: doubleValue);
  }

  return null;
}

///
class BracketCount {
  ///
  BracketCount({
    required this.characters,
    required this.startIndex,
    required this.openingBracket,
    required this.closingBracket,
  });

  /// List of characters to be processed.
  final List<String> characters;

  /// Index of String where processing should start.
  final int startIndex;

  /// Type of opening bracket, e.g. '[' or ''{.
  final String openingBracket;

  /// Type of closing bracket, e.g. ']' or '}'.
  final String closingBracket;

  /// Deepest depth encountered.
  ///
  /// Example:
  /// ```[[]]``` == depth of 2.
  /// ```[]```   == depth of 1.
  int _totalDepth = 0;

  /// Last index processed.
  int _endIndex = 1;

  ///
  int get totalDepth => _totalDepth;

  ///
  int get endIndex => _endIndex;

  /// List of all characters between opening and closing bracket.
  ///
  /// Example:
  /// [[1,2,3,4],[4,6,8],[1,0,1,1]], "anotherKey": []
  ///
  /// ContentBetweenBrackets == [[1,2,3,4],[4,6,8],[1,0,1,1]].
  List<String> get contentBetweenBrackets {
    _totalDepth = 1;

    final subList = characters.sublist(
      startIndex,
      characters.length,
    );

    var countTotalDepth = true;

    var index = startIndex;

    String token;

    var depth = 1;

    while (depth != 0) {
      index += 1;
      token = characters[index];

      if (token == openingBracket) {
        depth += 1;

        if (countTotalDepth) {
          _totalDepth += 1;
        }
      }

      if (token == closingBracket) {
        depth -= 1;
        countTotalDepth = false;
      }
    }

    _endIndex = index;
    return subList.sublist(0, index);
  }
}
