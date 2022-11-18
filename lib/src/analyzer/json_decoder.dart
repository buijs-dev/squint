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

import "../../squint.dart";
import "../common/normalize_spaces.dart";
import "json_elements.dart";

/// Decoded a JSON String to a [ParsedJsonElement] and/or [Map].
extension JsonDecoder on String {

  /// Decode a JSON String to [JsonElement]
  JsonObject get jsonDecode {

    var chars = substring(indexOf("{") + 1, lastIndexOf("}"))
        .split("")
        .normalizeSpaces;

    final data = <String, JsonElement>{};

    while(chars.isNotEmpty) {
      final procesKey = ProcessingKey(chars);
      final key = procesKey.key;
      chars = procesKey.chars;

      if(key == null) {
        break;
      }

      final procesValue = ProcessingValue(key, chars);
      final value = procesValue.value;
      chars = procesValue.chars;

      if(value != null) {
        data[key] = value;
      }

    }

    return JsonObject(data);

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

    if(startIndex == -1) {
      return;
    }

    final subList = chars.sublist(startIndex+1, chars.length);
    final endIndex = subList.indexOf('"');

    if(endIndex == -1) {
      return;
    }

    final keyList = subList.sublist(0, endIndex);
    key = keyList.join();
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

    index +=1;

    while(processing) {
      var token = chars[index];

      switch(token) {
        case "":
        case " ":
          index +=1;
          continue;
        case '"':
          processing = false;
          final subList = chars.sublist(index+1, chars.length);
          final endIndex = subList.indexOf('"');
          final valueList = subList.sublist(0, endIndex);
          value = JsonString(key: key, data: valueList.join());
          this.chars = subList.sublist(endIndex + 1, subList.length);
          return;
        case "[":
          processing = false;

          final counter = _BracketCount(
            characters: chars,
            startIndex: index,
            openingBracket: "[",
            closingBracket: "]",
          );

          final sublist =
              counter.contentBetweenBrackets;

          this.value = JsonArray.parse(
              key: key,
              content: sublist.join(),
              depth: counter.totalDepth,
          );

          this.chars = chars.sublist(counter.endIndex, chars.length);

          return;
        case "{":
          processing = false;

          final counter = _BracketCount(
            characters: chars,
            startIndex: index,
            openingBracket: "{",
            closingBracket: "}",
          );

          final sublist = counter.contentBetweenBrackets;
          this.value = sublist.join().jsonDecode;
          this.chars = chars.sublist(counter.endIndex, chars.length);
          return;
        default:
          processing = false;

          if("NULL" == chars.sublist(index, index + 4).join().toUpperCase()) {
            this.value = JsonNull(key: key);
            this.chars = chars.sublist(index + 4, chars.length);
            return;
          }

          if("TRUE" == chars.sublist(index, index + 4).join().toUpperCase()) {
            this.value = JsonBoolean(key: key, data: true);
            this.chars = chars.sublist(index + 4, chars.length);
            return;
          }

          if("FALSE" == chars.sublist(index, index + 5).join().toUpperCase()) {
            this.value = JsonBoolean(key: key, data: false);
            this.chars = chars.sublist(index + 5, chars.length);
            return;
          }

          final breakers = [" ", "[", "]", "{", "}", ","];

          final subList = [chars[index]];

          while(index < chars.length) {
            index +=1;

            final char = chars[index];

            if(breakers.contains(char)) {
              this.chars = chars.sublist(index, chars.length);
              this.value = JsonNumber.parse(
                key: key,
                data: subList.join(),
              );
              return;
            } else {
              subList.add(char);
            }
          }

          throw SquintException("Failed to parse JSON");
      }

    }

  }

  ///
  JsonElement? value;

  ///
  List<String> chars = [];

}

class _BracketCount {

  _BracketCount({
    required this.characters,
    required this.startIndex,
    required this.openingBracket,
    required this.closingBracket,
  });

  final List<String> characters;

  final int startIndex;

  final String openingBracket;

  final String closingBracket;

  int _totalDepth = 1;

  int _endIndex = 1;

  int get totalDepth => _totalDepth;

  int get endIndex => _endIndex;

  List<String> get contentBetweenBrackets {
    final subList = characters.sublist(startIndex, characters.length);

    _totalDepth = 1;

    var depth = 1;

    var countTotalDepth = true;

    var index = startIndex;

    String token;

    while(depth != 0) {
      index += 1;
      token = characters[index];

      if(token == openingBracket) {
        _totalDepth = countTotalDepth
            ? _totalDepth + 1
            : _totalDepth;
        depth += 1;
      }

      if(token == closingBracket) {
        depth -= 1;
        countTotalDepth = false;
      }
    }

    _endIndex = index;
    return subList.sublist(0, index);
  }

}