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

import "indentation.dart";

///
class JsonFormattingOptions {
  /// Construct a [JsonFormattingOptions] instance.
  const JsonFormattingOptions({
    required this.indentation,
    required this.colonPadding,
  });

  /// Length of indentation per level.
  final int indentation;

  /// Padding size arround colons.
  final int colonPadding;
}

/// Default JSON formatting options.
const standardJsonFormatting = JsonFormattingOptions(
  indentation: 4,
  colonPadding: 1,
);

///
extension JsonFormattingOptionsBuilder on JsonFormattingOptions {
  ///
  JsonFormattingOptions copyWith([
    JsonIndentationSize? indentationSize,
    int? indentationSizeInt,
    int? colonPadding,
  ]) =>
      JsonFormattingOptions(
        indentation:
            indentationSize?.length ?? indentationSizeInt ?? indentation,
        colonPadding: colonPadding ?? this.colonPadding,
      );
}
