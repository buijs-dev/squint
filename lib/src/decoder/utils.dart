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
import "../common/common.dart";
import "../converters/undetermined.dart";

/// Find matching AbstractType for String value.
///
/// {@category decoder}
extension AbstractTypeFromString on String {
  /// Returns [StandardType] if match found
  /// in [standardTypes] or [standardNullableTypes]
  /// and otherwise a new [CustomType].
  AbstractType toAbstractType({bool? nullable}) {
    final withPostfix = trim();

    final withoutPostfix = withPostfix.removePostfixIfPresent("?");

    final isNullable = nullable ?? withPostfix != withoutPostfix;

    final listType = _listType(
      strType: withoutPostfix,
      nullable: isNullable,
    );

    if (listType != null) {
      return listType;
    }

    final mapType = _mapType(
      strType: withoutPostfix,
      nullable: isNullable,
    );

    if (mapType != null) {
      return mapType;
    }

    final type = isNullable
        ? standardNullableTypes[withoutPostfix]
        : standardTypes[withoutPostfix];

    if (type != null) {
      return type;
    }

    final customType = withoutPostfix._toCustomTypeOrNull;

    if (customType != null) {
      return customType;
    }

    if (this == "dynamic") {
      return const UndeterminedAsDynamic();
    }

    throw SquintException("Unable to determine type: '$this'");
  }

  CustomType? get _toCustomTypeOrNull {
    final hasMatch = _customClassNameRegex.hasMatch(this);
    return hasMatch ? CustomType(className: this, members: []) : null;
  }
}

AbstractType? _listType({
  required String strType,
  required bool nullable,
}) {
  final listType = _listRegex.firstMatch(strType);

  if (listType == null) {
    return null;
  }

  final child = listType.group(3)?.toAbstractType();

  if (child == null) {
    throw SquintException(
      "Unable to determine List child type: '$strType'",
    );
  }

  if (nullable) {
    return NullableListType(child);
  }

  return ListType(child);
}

AbstractType? _mapType({
  required String strType,
  required bool nullable,
}) {
  final mapType = mapRegex.firstMatch(strType);

  if (mapType == null) {
    return null;
  }

  final matches = <String>[];

  for (var i = 0; i <= mapType.groupCount; i++) {
    matches.add(mapType.group(i) ?? "");
  }

  final key = mapType.group(3)?.toAbstractType();

  if (key == null) {
    throw SquintException("Unable to determine Map key type: '$strType'");
  }

  // If key is not null then neither can value be null.
  // Regex always returns either key + value or neither.
  final value = mapType.group(4)!.toAbstractType();

  return nullable
      ? NullableMapType(key: key, value: value)
      : MapType(key: key, value: value);
}

/// Regex to match a List from literal value:
///
/// List<...>
///
/// {@category decoder}
final _listRegex = RegExp(r"""^(List)(<(.+?)>|)$""");

/// Regex to match a Map from literal value:
///
/// Map<...,...>
///
/// {@category decoder}
final mapRegex = RegExp(r"""^(Map)(<(.+?),(.+?)>|)$""");

/// Regex to verify a literal value is a valid class name:
///
/// Rules (lenient):
/// - Should start with underscore or uppercase letter.
/// - May contain letters (uppercase/lowercase), numbers, underscores or dollar sign.
/// - Should end with letter (uppercase/lowercase), number or underscore.
///
/// {@category decoder}
final _customClassNameRegex =
    RegExp(r"""^[$_A-Z][$_a-zA-Z0-9]+[_a-zA-Z0-9]$""");

/// Map of all standard types.
///
/// {@category ast}
const standardTypes = {
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
const standardNullableTypes = {
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
