// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes
//
// Copyright (c) 2021 - 2022 Buijs Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions extends
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

/// Main type parent implemented by:
/// - [StandardType]
/// - [CustomType]
///
/// {@category ast}
abstract class AbstractType {
  /// Construct a new AbstractType.
  const AbstractType(this.className);

  /// Name of this class.
  final String className;
}

/// A standard Dart type being one of:
/// - [IntType] int
/// - [NullableIntType] int?
/// - [DoubleType] double
/// - [NullableDoubleType] double?
/// - [StringType] String
/// - [NullableStringType] String?
/// - [BooleanType] bool
/// - [NullableBooleanType] bool?
/// - [ListType] List
/// - [NullableListType] List?
/// - [MapType] Map
/// - [NullableMapType] Map?
/// - [Uint8ListType] Uint8List
/// - [NullableUint8ListType] Uint8List?
/// - [Int32ListType] Int32List
/// - [Int32ListType] Int32List?
/// - [Int64ListType] Int64List
/// - [Int64ListType] Int64List?
/// - [Float32ListType] Float32List
/// - [NullableFloat32ListType] Float32List?
/// - [Float64ListType] Float64List
/// - [NullableFloat64ListType] Float64List?
///
/// {@category ast}
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

  @override
  String toString() => "StandardType(name=$className, nullable=$nullable)";
}

/// A custom class definition.
///
/// {@category ast}
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
///
/// {@category ast}
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
  String toString() => "TypeMember(name='$name',type='$type')";
}

/// A Integer [StandardType].
///
/// {@category ast}
class IntType extends StandardType {
  /// Construct a new [IntType].
  const IntType() : super(className: "int", nullable: false);
}

/// A nullable Integer [StandardType].
///
/// {@category ast}
class NullableIntType extends StandardType {
  /// Construct a new [NullableIntType].
  const NullableIntType() : super(className: "int", nullable: true);
}

/// A double [StandardType].
///
/// {@category ast}
class DoubleType extends StandardType {
  /// Construct a new [DoubleType].
  const DoubleType() : super(className: "double", nullable: false);
}

/// A nullable double [StandardType].
///
/// {@category ast}
class NullableDoubleType extends StandardType {
  /// Construct a new [NullableDoubleType].
  const NullableDoubleType() : super(className: "double", nullable: true);
}

/// A Boolean [StandardType].
///
/// {@category ast}
class BooleanType extends StandardType {
  /// Construct a new [BooleanType].
  const BooleanType() : super(className: "bool", nullable: false);
}

/// A nullable Boolean [StandardType].
///
/// {@category ast}
class NullableBooleanType extends StandardType {
  /// Construct a new [NullableBooleanType].
  const NullableBooleanType() : super(className: "bool", nullable: true);
}

/// A String [StandardType].
///
/// {@category ast}
class StringType extends StandardType {
  /// Construct a new [StringType].
  const StringType() : super(className: "String", nullable: false);
}

/// A nullable String [StandardType].
///
/// {@category ast}
class NullableStringType extends StandardType {
  /// Construct a new [NullableStringType].
  const NullableStringType() : super(className: "String", nullable: true);
}

/// A Uint8List [StandardType].
///
/// {@category ast}
class Uint8ListType extends StandardType {
  /// Construct a new [Uint8ListType].
  const Uint8ListType() : super(className: "Uint8List", nullable: false);
}

/// A nullable Uint8List [StandardType].
///
/// {@category ast}
class NullableUint8ListType extends StandardType {
  /// Construct a new [NullableUint8ListType].
  const NullableUint8ListType() : super(className: "Uint8List", nullable: true);
}

/// A Int32List [StandardType].
///
/// {@category ast}
class Int32ListType extends StandardType {
  /// Construct a new [Int32ListType].
  const Int32ListType() : super(className: "Int32List", nullable: false);
}

/// A nullable Int32List [StandardType].
///
/// {@category ast}
class NullableInt32ListType extends StandardType {
  /// Construct a new [NullableInt32ListType].
  const NullableInt32ListType() : super(className: "Int32List", nullable: true);
}

/// A Int64List [StandardType].
///
/// {@category ast}
class Int64ListType extends StandardType {
  /// Construct a new [Int64ListType].
  const Int64ListType() : super(className: "Int64List", nullable: false);
}

/// A nullable Int64List [StandardType].
///
/// {@category ast}
class NullableInt64ListType extends StandardType {
  /// Construct a new [NullableInt64ListType].
  const NullableInt64ListType() : super(className: "Int64List", nullable: true);
}

/// A Float32List [StandardType].
///
/// {@category ast}
class Float32ListType extends StandardType {
  /// Construct a new [Float32ListType].
  const Float32ListType() : super(className: "Float32List", nullable: false);
}

/// A nullable Float32List [StandardType].
///
/// {@category ast}
class NullableFloat32ListType extends StandardType {
  /// Construct a new [Float32ListType].
  const NullableFloat32ListType()
      : super(className: "Float32List", nullable: true);
}

/// A Float64List [StandardType].
///
/// {@category ast}
class Float64ListType extends StandardType {
  /// Construct a new [Float64ListType].
  const Float64ListType() : super(className: "Float64List", nullable: false);
}

/// A nullable Float64List [StandardType].
///
/// {@category ast}
class NullableFloat64ListType extends StandardType {
  /// Construct a new [NullableFloat64ListType].
  const NullableFloat64ListType()
      : super(className: "Float64List", nullable: true);
}

/// A List [StandardType].
///
/// {@category ast}
class ListType extends StandardType {
  /// Construct a new [ListType].
  const ListType(this.child) : super(className: "List", nullable: false);

  /// List child element.
  final AbstractType child;
}

/// A nullable List [StandardType].
///
/// {@category ast}
class NullableListType extends StandardType {
  /// Construct a new [NullableListType].
  const NullableListType(this.child) : super(className: "List", nullable: true);

  /// List child element.
  final AbstractType child;
}

/// A Map [StandardType].
///
/// {@category ast}
class MapType extends StandardType {
  /// Construct a new [MapType].
  const MapType({
    required this.key,
    required this.value,
  }) : super(className: "Map", nullable: false);

  /// Map key element.
  final AbstractType key;

  /// Map value element.
  final AbstractType value;
}

/// A nullable Map [StandardType].
///
/// {@category ast}
class NullableMapType extends StandardType {
  /// Construct a new [NullableMapType].
  const NullableMapType({
    required this.key,
    required this.value,
  }) : super(className: "Map", nullable: true);

  /// Map key element.
  final AbstractType key;

  /// Map value element.
  final AbstractType value;
}
