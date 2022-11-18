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

import "dart:typed_data";

import "../common/common.dart";
import "element.dart";

/// Returns a nullable T or throws a [SquintException].
T? squintOrNull<T>(dynamic value) {
  if (value is SquintValue) {
    return squintOrNull<T>(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is T?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType(T.runtimeType.toString(), value);
}

/// Returns a String or throws a [SquintException].
String stringOrThrow(dynamic value, {Exception? e}) {
  final valueOrNull = stringOrNull(value);

  if (valueOrNull == null) {
    throw e ?? SquintException("Value is null.");
  }

  return valueOrNull;
}

/// Returns a nullable String or throws a [SquintException].
String? stringOrNull(dynamic value) {
  if (value is SquintValue) {
    return stringOrNull(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is String?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType("String", value);
}

/// Returns an int or throws a [SquintException].
int intOrThrow(dynamic value, {Exception? e}) {
  final valueOrNull = intOrNull(value);

  if (valueOrNull == null) {
    throw e ?? SquintException("Value is null.");
  }

  return valueOrNull;
}

/// Returns a nullable int or throws a [SquintException].
int? intOrNull(dynamic value) {
  if (value is SquintValue) {
    return intOrNull(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is int?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType("int", value);
}

/// Returns a double or throws a [SquintException].
double doubleOrThrow(dynamic value, {Exception? e}) {
  final valueOrNull = doubleOrNull(value);

  if (valueOrNull == null) {
    throw e ?? SquintException("Value is null.");
  }

  return valueOrNull;
}

/// Returns a double int or throws a [SquintException].
double? doubleOrNull(dynamic value) {
  if (value is SquintValue) {
    return doubleOrNull(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is double?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType("double", value);
}

/// Returns a bool or throws a [SquintException].
bool boolOrThrow(dynamic value, {Exception? e}) {
  final valueOrNull = boolOrNull(value);

  if (valueOrNull == null) {
    throw e ?? SquintException("Value is null.");
  }

  return valueOrNull;
}

/// Returns a bool or throws a [SquintException].
bool? boolOrNull(dynamic value) {
  if (value is SquintValue) {
    return boolOrNull(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is bool?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType("bool", value);
}

/// Returns a List or throws a [SquintException].
List listOrThrow(dynamic value, {Exception? e}) {
  final valueOrNull = listOrNull(value);

  if (valueOrNull == null) {
    throw e ?? SquintException("Value is null.");
  }

  return valueOrNull;
}

/// Returns a List or throws a [SquintException].
List? listOrNull(dynamic value) {
  if (value is SquintValue) {
    return listOrNull(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is List?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType("List", value);
}

/// Returns a Map or throws a [SquintException].
Map mapOrThrow(dynamic value, {Exception? e}) {
  final valueOrNull = mapOrNull(value);

  if (valueOrNull == null) {
    throw e ?? SquintException("Value is null.");
  }

  return valueOrNull;
}

/// Returns a Map or throws a [SquintException].
Map? mapOrNull(dynamic value) {
  if (value is SquintValue) {
    return mapOrNull(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is Map?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType("Map", value);
}

/// Returns a Uint8List or throws a [SquintException].
Uint8List uint8ListOrThrow(dynamic value, {Exception? e}) {
  final valueOrNull = uint8ListOrNull(value);

  if (valueOrNull == null) {
    throw e ?? SquintException("Value is null.");
  }

  return valueOrNull;
}

/// Returns a Uint8List or throws a [SquintException].
Uint8List? uint8ListOrNull(dynamic value) {
  if (value is SquintValue) {
    return uint8ListOrNull(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is Uint8List?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType("Uint8List", value);
}

/// Returns a Int32List or throws a [SquintException].
Int32List int32ListOrThrow(dynamic value, {Exception? e}) {
  final valueOrNull = int32ListOrNull(value);

  if (valueOrNull == null) {
    throw e ?? SquintException("Value is null.");
  }

  return valueOrNull;
}

/// Returns a Int32List or throws a [SquintException].
Int32List? int32ListOrNull(dynamic value) {
  if (value is SquintValue) {
    return int32ListOrNull(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is Int32List?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType("Int32List", value);
}

/// Returns a Int64List or throws a [SquintException].
Int64List int64ListOrThrow(dynamic value, {Exception? e}) {
  final valueOrNull = int64ListOrNull(value);

  if (valueOrNull == null) {
    throw e ?? SquintException("Value is null.");
  }

  return valueOrNull;
}

/// Returns a Int64List or throws a [SquintException].
Int64List? int64ListOrNull(dynamic value) {
  if (value is SquintValue) {
    return int64ListOrNull(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is Int64List?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType("Int64List", value);
}

/// Returns a Float64List or throws a [SquintException].
Float64List float64ListOrThrow(dynamic value, {Exception? e}) {
  final valueOrNull = float64ListOrNull(value);

  if (valueOrNull == null) {
    throw e ?? SquintException("Value is null.");
  }

  return valueOrNull;
}

/// Returns a Float64List or throws a [SquintException].
Float64List? float64ListOrNull(dynamic value) {
  if (value is SquintValue) {
    return float64ListOrNull(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is Float64List?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType("Float64List", value);
}

/// Returns a Float32List or throws a [SquintException].
Float32List float32ListOrThrow(dynamic value, {Exception? e}) {
  final valueOrNull = float32ListOrNull(value);

  if (valueOrNull == null) {
    throw e ?? SquintException("Value is null.");
  }

  return valueOrNull;
}

/// Returns a Float32List or throws a [SquintException].
Float32List? float32ListOrNull(dynamic value) {
  if (value is SquintValue) {
    return float32ListOrNull(value.value);
  }

  if (value is SquintNullValue) {
    return null;
  }

  if (value is Float32List?) {
    return value;
  }

  if (value == null) {
    return null;
  }

  throw _notNullOrType("Float32List", value);
}

SquintException _notNullOrType(String expectedType, dynamic type) =>
    SquintException("Value is neither null nor $expectedType (expected): '$type'");
