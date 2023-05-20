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

// ignore_for_file: avoid_annotating_with_dynamic
/// Utility to parse command line arguments
extension ArgParserUtil on dynamic {
  /// Return bool value if current value is a bool or String bool.
  /// Return null if current value is not a bool or String bool.
  bool? get asBoolOrNull => dynamicToBoolOrNull(this);

  /// Return the argument value without -- postfix and in lowercase.
  String get lowercase => "$this".substring(2, "$this".length).toLowerCase();
}

/// Return [boolOrNot] as bool value if:
/// - it is a bool
/// - it is a String containing a bool (not case-sensitive)
///
/// Otherwise return null.
bool? dynamicToBoolOrNull(dynamic boolOrNot) {
  final upperCaseString = "$boolOrNot".trim().toUpperCase();
  if (upperCaseString == "TRUE") {
    return true;
  }

  if (upperCaseString == "FALSE") {
    return false;
  }

  return null;
}
