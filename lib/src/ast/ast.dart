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

// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

library ast;

import "dart:io";

import "../common/common.dart";
import "../decoder/decoder.dart";
import "ast.dart";

export "json.dart";
export "types.dart";

/// Parent for all types in the ast package.
abstract class AbstractType {
  /// Construct a new AbstractType.
  const AbstractType(this.className);

  /// Name of this class.
  final String className;
}

/// Parent for all types in the ast package.
class StandardType extends AbstractType {
  /// Construct a new AbstractType.
  const StandardType({
    required String className,
    required this.nullable,
  }) : super(className);

  /// Bool indicator if null is allowed.
  final bool nullable;

  @override
  bool operator ==(dynamic other) =>
      other is StandardType &&
      className == other.className &&
      nullable == other.nullable;

  @override
  int get hashCode => className.hashCode + nullable.hashCode;
}

/// A custom class definition.
class CustomType extends AbstractType {
  /// Construct a new CustomType.
  const CustomType({
    required String className,
    required this.members,
  }) : super(className);

  /// Fields of this class.
  final List<TypeMember> members;
}

/// A class type member (field).
class TypeMember {
  /// Construct a new TypeMember.
  const TypeMember({
    required this.name,
    required this.type,
  });

  /// Name of this field.
  final String name;

  /// Type of this field.
  final AbstractType type;

  @override
  String toString() => "TypeMember('$type' '$name')";
}

///
extension CustomTypeFromDebugFile on File {
  ///
  CustomType? get customType {
    final json = readAsStringSync().jsonDecode;

    final className = json.string("className").data;

    final dynamic data = json.array<dynamic>("members").data;

    final members = <TypeMember>[];

    for (final object in data) {
      // if (object.length != 3) {
      //   throw SquintException(
      //       "JSON content incomplete. Expected 3 elements but found: '$object'");
      // }

      final name = object["name"] as String;
      final type = object["type"] as String;
      final nullable = object["nullable"] as bool;

      members.add(
        TypeMember(
          name: name,
          type: type.abstractType(nullable: nullable),
        ),
      );
    }

    return CustomType(
      className: className,
      members: members,
    );
  }
}

/// Find matching AbstractType for String value.
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

final _listRegex = RegExp(r"""^(List)(<(.+?)>|)$""");

final _mapRegex = RegExp(r"""^(Map)(<(.+?),(.+?)>|)$""");

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
