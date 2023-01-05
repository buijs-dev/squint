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

import "../ast/json.dart";
import "../common/exception.dart";

///
T when<T>(
  dynamic value, {
  required T Function(JsonIntegerNumber json) caseInt,
  required T Function(JsonFloatingNumber json) caseDouble,
  required T Function(JsonString json) caseString,
  required T Function(JsonArray json) caseList,
  required T Function(JsonObject json) caseMap,
  required T Function(JsonNull json) caseNull,
  T Function()? orElse,
}) =>
    _JsonNodeSwitcher<T>(
      caseInt: caseInt,
      caseDouble: caseDouble,
      caseString: caseString,
      caseList: caseList,
      caseMap: caseMap,
      caseNull: caseNull,
    ).when(value, orElse: orElse);

/// Utility to build a switch statement which covers all possible
/// JsonNode implementations.
///
/// Inspired by 'when' in the Kotlin programming language.
class _JsonNodeSwitcher<T> {
  ///
  const _JsonNodeSwitcher({
    required this.caseInt,
    required this.caseDouble,
    required this.caseString,
    required this.caseList,
    required this.caseMap,
    required this.caseNull,
  });

  ///
  T when(dynamic value, {T Function()? orElse}) {
    if (value is JsonIntegerNumber) {
      return caseInt.call(value);
    }

    if (value is JsonFloatingNumber) {
      return caseDouble.call(value);
    }

    if (value is JsonString) {
      return caseString.call(value);
    }

    if (value is JsonArray) {
      return caseList.call(value);
    }

    if (value is JsonObject) {
      return caseMap.call(value);
    }

    if (value is JsonNull) {
      return caseNull.call(value);
    }

    if (orElse != null) {
      return orElse.call();
    }

    throw SquintException("Unhandled value: $value");
  }

  ///
  final T Function(JsonIntegerNumber json) caseInt;

  ///
  final T Function(JsonFloatingNumber json) caseDouble;

  ///
  final T Function(JsonString json) caseString;

  ///
  final T Function(JsonArray json) caseList;

  ///
  final T Function(JsonObject json) caseMap;

  ///
  final T Function(JsonNull json) caseNull;
}
