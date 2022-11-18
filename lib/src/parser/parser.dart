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

///
library parser;

import "dart:typed_data";

import "../common/common.dart";
import "caster.dart";
import "element.dart";

export "caster.dart";
export "element.dart";

///
extension JsonMapParser on Map<String, dynamic> {
  /// Return a squint-annotated CustomType value or throw an Exception.
  T squintValueOrThrow<T>({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<T>(squintValueOrNull(key: key), e: e);

  /// Return a squint-annotated CustomType value or null.
  T? squintValueOrNull<T>({required String key}) =>
      _valueOrNull(key: key, cast: squintOrNull);

  /// Return an String value or throw an Exception.
  String stringValueOrThrow({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<String>(stringValueOrNull(key: key), e: e);

  /// Return an String value or null.
  String? stringValueOrNull({required String key}) =>
      _valueOrNull(key: key, cast: stringOrNull);

  /// Return an int value or throw an Exception.
  int intValueOrThrow({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<int>(intValueOrNull(key: key), e: e);

  /// Return an int value or null.
  int? intValueOrNull({required String key}) =>
      _valueOrNull(key: key, cast: (o) => int.parse(o.value.toString()));

  /// Return an double value or throw an Exception.
  double doubleValueOrThrow({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<double>(doubleValueOrNull(key: key), e: e);

  /// Return an double value or null.
  double? doubleValueOrNull({required String key}) =>
      _valueOrNull(key: key, cast: (o) => double.parse(o.value.toString()));

  /// Return an bool value or null.
  bool? boolValueOrNull({required String key}) => _valueOrNull(
      key: key,
      cast: (o) {
        final dynamic valueNullable = o.value;

        if (valueNullable == null) {
          return null;
        }

        final value = "${o.value}".trim().toUpperCase();

        if (value == "TRUE") {
          return true;
        }

        if (value == "FALSE") {
          return false;
        }

        return null;
      });

  /// Return an bool value or throw an Exception.
  bool boolValueOrThrow({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<bool>(boolValueOrNull(key: key), e: e);

  /// Return a List dynamic or throw an Exception.
  List<dynamic> listValueOrThrow({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<List<dynamic>>(listValueOrNull(key: key), e: e);

  /// Return an List dynamic or null.
  List<dynamic>? listValueOrNull({required String key}) =>
      _valueOrNull(key: key, cast: (o) => o.value as List<dynamic>);

  /// Return a Map dynamic:dynamic or throw an Exception.
  Map<dynamic, dynamic> mapValueOrThrow({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<Map<dynamic, dynamic>>(mapValueOrNull(key: key), e: e);

  /// Return a Map dynamic or null.
  Map<dynamic, dynamic>? mapValueOrNull({required String key}) =>
      _valueOrNull(key: key, cast: (o) => o.value as Map<dynamic, dynamic>);

  /// Return a Uint8List or throw an Exception.
  Uint8List uint8ListValueOrThrow({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<Uint8List>(uint8ListValueOrNull(key: key), e: e);

  /// Return a Uint8List or null.
  Uint8List? uint8ListValueOrNull({required String key}) =>
      _valueOrNull(key: key, cast: (o) => o.value as Uint8List);

  /// Return a Int32List or throw an Exception.
  Int32List int32ListValueOrThrow({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<Int32List>(int32ListValueOrNull(key: key), e: e);

  /// Return a Int32List or null.
  Int32List? int32ListValueOrNull({required String key}) =>
      _valueOrNull(key: key, cast: (o) => o.value as Int32List);

  /// Return a Int64List or throw an Exception.
  Int64List int64ListValueOrThrow({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<Int64List>(int64ListValueOrNull(key: key), e: e);

  /// Return a Int64List or null.
  Int64List? int64ListValueOrNull({required String key}) =>
      _valueOrNull(key: key, cast: (o) => o.value as Int64List);

  /// Return a Float32List or throw an Exception.
  Float32List float32ListValueOrThrow({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<Float32List>(float32ListValueOrNull(key: key), e: e);

  /// Return a Float32List or null.
  Float32List? float32ListValueOrNull({required String key}) =>
      _valueOrNull(key: key, cast: (o) => o.value as Float32List);

  /// Return a Float64List or throw an Exception.
  Float64List float64ListValueOrThrow({
    required String key,
    Exception? e,
  }) =>
      _valueOrThrow<Float64List>(float64ListValueOrNull(key: key), e: e);

  /// Return a Float64List or null.
  Float64List? float64ListValueOrNull({required String key}) =>
      _valueOrNull(key: key, cast: (o) => o.value as Float64List);

  /// Return a value of Type?.
  T? _valueOrNull<T>({
    required String key,
    required T? Function(SquintValue o) cast,
  }) {
    final element = _getElement(key: key);

    if (element is SquintValue) {
      return cast(element);
    }

    return null;
  }

  SquintElement _getElement({required String key}) {
    if (!containsKey(key)) {
      "Key not found in JSON map: '$key'".log(context: this);
      return const UnknownKey();
    }

    final dynamic value = this[key];

    if (value == null) {
      "Value is null for key: '$key'".log(context: this);
      return const SquintNullValue();
    }

    return SquintValue(this[key]);
  }
}

extension on dynamic {
  T _valueOrThrow<T>(T? value, {Exception? e}) {
    if (value == null) {
      throw e ??
          SquintException("Forced unwrapping failed because value is null.");
    }

    return value;
  }
}
