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
import "ast.dart";

/// Find matching AbstractType for String value.
///
/// {@category ast}
extension AbstractTypeFromString on String {
  /// Returns [StandardType] if match found
  /// in [_standardTypes] or [_standardNullableTypes]
  /// and otherwise a new [CustomType].
  AbstractType abstractType({bool? nullable}) {
    final withPostfix = trim();
    final withoutPostfix = withPostfix.removePostfixIfPresent("?");

    final listType = _listRegex.firstMatch(withoutPostfix);

    if (listType != null) {
      final child = listType.group(3)?.abstractType();

      if (child == null) {
        throw SquintException("Unable to determine List child type: '$this'");
      }

      return (nullable ?? withPostfix.endsWith("?"))
          ? NullableListType(child)
          : ListType(child);
    }

    final mapType = _mapRegex.firstMatch(withoutPostfix);

    if (mapType != null) {
      final matches = <String>[];
      for (var i = 0; i <= mapType.groupCount; i++) {
        matches.add(mapType.group(i) ?? "");
      }

      final key = mapType.group(3)?.abstractType();

      if (key == null) {
        throw SquintException("Unable to determine Map key type: '$this'");
      }

      final value = mapType.group(4)?.abstractType();

      if (value == null) {
        throw SquintException("Unable to determine Map value type: '$this'");
      }

      return (nullable ?? withPostfix.endsWith("?"))
          ? NullableMapType(key: key, value: value)
          : MapType(key: key, value: value);
    }

    final type = (nullable ?? withPostfix.endsWith("?"))
        ? _standardNullableTypes[withoutPostfix]
        : _standardTypes[withoutPostfix];

    return type ?? CustomType(className: withoutPostfix, members: []);
  }
}

/// Regex to match a List from literal value:
///
/// List<...>
///
/// {@category ast}
final _listRegex = RegExp(r"""^(List)(<(.+?)>|)$""");

/// Regex to match a Map from literal value:
///
/// Map<...,...>
///
/// {@category ast}
final _mapRegex = RegExp(r"""^(Map)(<(.+?),(.+?)>|)$""");

/// Map of all standard types.
///
/// {@category ast}
const _standardTypes = {
  "int": IntType(),
  "double": DoubleType(),
  "bool": BooleanType(),
  "String": StringType(),
  "Uint8List": Uint8ListType(),
  "Int32List": Int32ListType(),
  "Int64List": Int64ListType(),
  "Float32List": Float32ListType(),
  "Float64List": Float64ListType(),
};

/// Map of all standard nullable types.
///
/// {@category ast}
const _standardNullableTypes = {
  "int": NullableIntType(),
  "double": NullableDoubleType(),
  "bool": NullableBooleanType(),
  "String": NullableStringType(),
  "Uint8List": NullableUint8ListType(),
  "Int32List": NullableInt32ListType(),
  "Int64List": NullableInt64ListType(),
  "Float32List": NullableFloat32ListType(),
  "Float64List": NullableFloat64ListType(),
};
