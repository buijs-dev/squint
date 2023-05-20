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

import "package:dart_style/dart_style.dart";

final _isAlphabeticRegex = RegExp(r"""^[a-zA-Z]$""");

/// String processing utilities.
extension StringUtils on String {
  /// Remove the postfix of a String
  /// if present
  /// or return current String.
  String removePostfixIfPresent(String toRemove) {
    if (!endsWith(toRemove)) {
      return this;
    }

    final lastIndex = lastIndexOf(toRemove);

    return substring(0, lastIndex);
  }

  /// Remove the prefix of a String
  /// if present
  /// or return current String.
  String removePrefixIfPresent(String toRemove) {
    if (!startsWith(toRemove)) {
      return this;
    }

    return replaceFirst(toRemove, "");
  }

  /// Convert a String to camelcase.
  String camelCase({bool capitalize = true}) {
    var hasUnderscore = false;

    final characters = split("");

    var firstCharacter = characters.removeAt(0).toLowerCase();

    if (capitalize) {
      firstCharacter = firstCharacter.toUpperCase();
    }

    final buffer = StringBuffer()..write(firstCharacter);

    for (final char in characters) {
      if (char == "_") {
        hasUnderscore = true;
        continue;
      }

      if (hasUnderscore) {
        hasUnderscore = false;
        buffer.write(char.toUpperCase());
        continue;
      }

      buffer.write(char);
    }

    return buffer.toString();
  }

  /// Convert a String to snake_case
  String get snakeCase {
    final characters = split("");

    final firstCharacter = characters.removeAt(0).toLowerCase();

    final buffer = StringBuffer()..write(firstCharacter);

    for (final char in characters) {
      if (_isAlphabeticRegex.firstMatch(char) != null &&
          char.toUpperCase() == char) {
        buffer
          ..write("_")
          ..write(char.toLowerCase());
      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  /// Utility to print templated Strings.
  ///
  /// Example:
  ///
  /// Given a templated String:
  /// ```
  /// final String foo = """|A multi-line message
  ///                       |is a message
  ///                       |that exists of
  ///                       |multiple lines.
  ///                       |
  ///                       |True story"""";
  /// ```
  ///
  /// Will produce a multi-line String:
  ///
  /// 'A multi-line message
  /// is a message
  /// that exists of
  /// multiple lines.
  ///
  /// True story'
  String get format => replaceAllMapped(
          // Find all '|' char including preceding whitespaces.
          RegExp(r"(\s+?\|)"),
          // Replace them with a single linebreak.
          (_) => "\n")
      .replaceAll(RegExp(r"(!?,)\|"), "")
      .trimLeft()
      .replaceAll(",|", "|");

  /// Format a String as dart code using dart_style DartFormatter.
  String get formattedDartCode => DartFormatter().format(format);
}
