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

/// Utility to remove all meaningless spaces from a JSON String.
///
/// Any space outside a quoted String has no meaning and will be removed.
extension UnquotedSpaceRemover on List<String> {
  /// Delete all unnecessary spaces.
  ///
  /// Any space outside quotation marks is deleted.
  List<String> get normalizeSpaces {
    final output = <String>[];

    /// Current (list of) values is preceded by a single quotation mark.
    ///
    /// Example:
    /// ```
    /// {
    ///   "x": "foo"
    /// }
    /// ```
    ///
    /// The characters x, f, o and o are between single quotation marks.
    var insideQuotationMarks = false;

    /// Previous processed token.
    var previous = "";

    for (final char in this) {
      final token = _Token.fromChar(
        current: char,
        previous: previous,
      );

      if (token.shouldSkip(insideQuotationMarks)) {
        continue;
      }

      output.add(char);

      previous = char;

      insideQuotationMarks = token.isInsideQuotationMarks(insideQuotationMarks);
    }

    return output;
  }
}

class _Token {
  const _Token({
    required this.isEscapedValue,
    required this.isQuotationMark,
    required this.isEmptyCharacter,
  });

  factory _Token.fromChar({
    required String current,
    required String previous,
  }) =>
      _Token(
        isEscapedValue: previous == r"\",
        isQuotationMark: current == '"',
        isEmptyCharacter: current.trim().isEmpty,
      );

  /// Bool value indicating the current character
  /// is escaped by the previous character.
  final bool isEscapedValue;

  /// Bool value indicating the current character
  /// is a quotation mark e.g. => ".
  final bool isQuotationMark;

  /// Bool value indicating the current character
  /// is empty e.g. => " ".
  final bool isEmptyCharacter;

  /// If token is empty and not inside quotation marks
  /// then it should be skipped.
  bool shouldSkip(bool insideQuotationMarks) {
    if (!isEmptyCharacter) {
      return false;
    }

    if (insideQuotationMarks) {
      return false;
    }

    return true;
  }

  /// Return bool value indicating the next token to be processed
  /// is between quotation marks or not.
  bool isInsideQuotationMarks(bool insideQuotationMarks) {
    if (!isQuotationMark) {
      return insideQuotationMarks;
    }

    if (isEscapedValue) {
      return insideQuotationMarks;
    }

    return !insideQuotationMarks;
  }
}
