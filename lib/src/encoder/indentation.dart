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

/// Length of indentation per level.
///
/// Options:
/// - tab: '    ' e.g. 4 x spaces
/// - space: ' '
/// - doubleSpace: '  ' e.g. 2 x space
enum JsonIndentationSize {
  /// Indentation of 4 spaces.
  ///
  /// Example output:
  ///
  /// ```
  /// {
  ///     "key": "value"
  /// }
  /// ```
  tab(4),

  /// Indentation of a single space.
  ///
  /// Example output:
  ///
  /// ```
  /// {
  ///  "key": "value"
  /// }
  /// ```
  space(1),

  /// Indentation of 2 spaces.
  ///
  /// Example output:
  ///
  /// ```
  /// {
  ///   "key": "value"
  /// }
  /// ```
  doubleSpace(2);

  /// Construct a JsonIndentationSize instance.
  const JsonIndentationSize(this.length);

  /// Length of indentation in spaces.
  final int length;
}
