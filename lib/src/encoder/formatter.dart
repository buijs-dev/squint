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

import "../common/common.dart";
import "options.dart";

/// Utilities to format a JSON String,
///
/// {@category encoder}
extension JsonFormatter on String {
  /// Get JSON String formatted.
  ///
  /// {@category encoder}
  String formatJson([
    JsonFormattingOptions options = standardJsonFormatting,
  ]) {
    final indenting = options.indentation;

    final colonPadding = options.colonPadding;

    final characters = split("").normalizeSpaces;

    final output = <String>[];

    var depth = 0;

    for (final character in characters) {
      final buffer = StringBuffer();
      if (character == "{") {
        depth += 1;
        buffer.write("{\n");
        for (var i = 0; i < depth; i++) {
          for (var y = 0; y < indenting; y++) {
            buffer.write(" ");
          }
        }
        output.add(buffer.toString());
      } else if (character == "}") {
        buffer.write("\n");
        depth -= 1;
        for (var i = 0; i < depth; i++) {
          for (var y = 0; y < indenting; y++) {
            buffer.write(" ");
          }
        }
        buffer.write("}");
        output.add(buffer.toString());
      } else if (character == "[") {
        depth += 1;
        buffer.write("[\n");
        for (var i = 0; i < depth; i++) {
          for (var y = 0; y < indenting; y++) {
            buffer.write(" ");
          }
        }
        output.add(buffer.toString());
      } else if (character == "]") {
        buffer.write("\n");
        depth -= 1;
        for (var i = 0; i < depth; i++) {
          for (var y = 0; y < indenting; y++) {
            buffer.write(" ");
          }
        }
        buffer.write("]");
        output.add(buffer.toString());
      } else if (character == ":") {
        for (var i = 0; i < colonPadding; i++) {
          output.add(" ");
        }

        output.add(":");
        for (var i = 0; i < colonPadding; i++) {
          output.add(" ");
        }
      } else if (character == ",") {
        buffer.write(",\n");
        for (var i = 0; i < depth; i++) {
          for (var y = 0; y < indenting; y++) {
            buffer.write(" ");
          }
        }
        output.add(buffer.toString());
      } else {
        output.add(character);
      }
    }
    return output.join();
  }

  /// Get JSON String without indentation line breaks.
  String get unformatted => split("").normalizeSpaces.join();
}
