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

import "../ast/ast.dart";

/// Return a quoted String value for JSON if the current value is a String.
///
/// Example:
///
/// Given a [String] value foo will return:
///
/// ```
///   "foo"
/// ```
///
/// Given an [int] value 10 will return:
///
/// ```
///   10
/// ```
///
/// {@category encoder}
dynamic maybeAddQuotes(dynamic value) {
  if (value is List) {
    return value.map<dynamic>(maybeAddQuotes).toList();
  }

  if (value is String) {
    return '"$value"';
  }

  if (value is JsonElement) {
    return value.data.maybeAddQuotes;
  }

  return value;
}
