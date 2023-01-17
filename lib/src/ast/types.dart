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

import "../common/common.dart";

/// Main type parent implemented by:
/// - [StandardType]
/// - [CustomType]
/// - [EnumType]
///
/// {@category ast}
abstract class AbstractType {
  /// Construct a new AbstractType.
  const AbstractType({
    required this.className,
  });

  /// Name of this class.
  final String className;

  /// Bool indicator if null is allowed.
  bool get nullable;
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
abstract class StandardType extends AbstractType {
  /// Construct a new AbstractType.
  const StandardType({
    required String className,
  }) : super(className: className);

  @override
  bool operator ==(Object other) =>
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
    this.nullable = false,
  }) : super(className: className);

  /// Fields of this class.
  final List<TypeMember> members;

  @override
  final bool nullable;

  @override
  bool operator ==(Object other) =>
      other is CustomType &&
      className == other.className &&
      nullable == other.nullable &&
      members.length == other.members.length &&
      members.every((element) => other.members.contains(element));

  @override
  int get hashCode => className.hashCode + nullable.hashCode;

  @override
  String toString() =>
      "CustomType(name=$className, nullable=$nullable, members=$members)";
}

/// A custom enumeration definition.
///
/// {@category ast}
class EnumType extends AbstractType {
  /// Construct a new CustomType.
  const EnumType(
      {required String className,
      required this.values,
      required this.valuesJSON})
      : super(className: className);

  /// Fields of this class.
  final List<String> values;

  /// Fields of this class.
  final List<String> valuesJSON;

  @override
  bool operator ==(Object other) =>
      other is EnumType &&
      className == other.className &&
      nullable == other.nullable &&
      values.length == other.values.length &&
      valuesJSON.length == other.valuesJSON.length &&
      values.every((element) => other.values.contains(element)) &&
      valuesJSON.every((element) => other.valuesJSON.contains(element));

  @override
  int get hashCode => className.hashCode + nullable.hashCode;

  @override
  String toString() =>
      "EnumType(name=$className, values=$values, valuesJSON=$valuesJSON)";

  @override
  bool get nullable => false;
}

/// A class type member (field).
///
/// {@category ast}
class TypeMember {
  /// Construct a new TypeMember.
  const TypeMember({
    required this.name,
    required this.type,
    this.annotations = const <TypeAnnotation>[],
  });

  /// Name of this field.
  final String name;

  /// Type of this field.
  final AbstractType type;

  /// Type annotations
  final List<TypeAnnotation> annotations;

  /// Return value of @JsonValue annotation 'name'
  /// if present otherwise null.
  String get jsonNodeKey {
    bool predicate(TypeAnnotation annotation) => annotation.name == "JsonValue";
    return annotations.firstBy(predicate)?.data["tag"] ?? name;
  }

  @override
  bool operator ==(Object other) =>
      other is TypeMember &&
      name == other.name &&
      type == other.type &&
      annotations.length == other.annotations.length &&
      annotations.toString() == other.annotations.toString();

  @override
  int get hashCode => type.hashCode + type.hashCode;

  @override
  String toString() =>
      "TypeMember(name='$name',type='$type', annotations =$annotations)";

  /// Create a copy of this [TypeMember] and override with given values.
  TypeMember copyWith({
    /// Name of this field.
    String? name,

    /// Type of this field.
    AbstractType? type,

    /// Type annotations
    List<TypeAnnotation>? annotations,
  }) => TypeMember(
    name: name ?? this.name,
    type: type ?? this.type,
    annotations: annotations ?? this.annotations,
  );

}

/// Annotation data.
///
/// {@category ast}
class TypeAnnotation {
  /// Construct a new TypeAnnotation.
  const TypeAnnotation({
    required this.name,
    this.data = const <String, String>{},
  });

  /// Name of this annotation.
  final String name;

  /// All key-value data.
  final Map<String, String> data;

  @override
  bool operator ==(Object other) =>
      other is TypeAnnotation && name != other.name && data != other.data;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => "TypeAnnotation(name='$name',data=$data)";
}

/// A Integer [StandardType].
///
/// {@category ast}
class IntType extends StandardType {
  /// Construct a new [IntType].
  const IntType() : super(className: "int");

  @override
  bool get nullable => false;
}

/// A nullable Integer [IntType].
///
/// {@category ast}
class NullableIntType extends IntType {
  /// Construct a new [NullableIntType].
  const NullableIntType();

  @override
  bool get nullable => true;
}

/// A double [StandardType].
///
/// {@category ast}
class DoubleType extends StandardType {
  /// Construct a new [DoubleType].
  const DoubleType() : super(className: "double");

  @override
  bool get nullable => false;
}

/// A nullable double [StandardType].
///
/// {@category ast}
class NullableDoubleType extends DoubleType {
  /// Construct a new [NullableDoubleType].
  const NullableDoubleType();

  @override
  bool get nullable => true;
}

/// A Boolean [StandardType].
///
/// {@category ast}
class BooleanType extends StandardType {
  /// Construct a new [BooleanType].
  const BooleanType() : super(className: "bool");

  @override
  bool get nullable => false;
}

/// A nullable Boolean [StandardType].
///
/// {@category ast}
class NullableBooleanType extends BooleanType {
  /// Construct a new [NullableBooleanType].
  const NullableBooleanType();

  @override
  bool get nullable => true;
}

/// A String [StandardType].
///
/// {@category ast}
class StringType extends StandardType {
  /// Construct a new [StringType].
  const StringType() : super(className: "String");

  @override
  bool get nullable => false;
}

/// A nullable String [StandardType].
///
/// {@category ast}
class NullableStringType extends StringType {
  /// Construct a new [NullableStringType].
  const NullableStringType();

  @override
  bool get nullable => true;
}

/// A Uint8List [StandardType].
///
/// {@category ast}
class Uint8ListType extends StandardType {
  /// Construct a new [Uint8ListType].
  const Uint8ListType() : super(className: "Uint8List");

  @override
  bool get nullable => false;
}

/// A nullable Uint8List [StandardType].
///
/// {@category ast}
class NullableUint8ListType extends Uint8ListType {
  /// Construct a new [NullableUint8ListType].
  const NullableUint8ListType();

  @override
  bool get nullable => true;
}

/// A Int32List [StandardType].
///
/// {@category ast}
class Int32ListType extends StandardType {
  /// Construct a new [Int32ListType].
  const Int32ListType() : super(className: "Int32List");

  @override
  bool get nullable => false;
}

/// A nullable Int32List [StandardType].
///
/// {@category ast}
class NullableInt32ListType extends Int32ListType {
  /// Construct a new [NullableInt32ListType].
  const NullableInt32ListType();

  @override
  bool get nullable => true;
}

/// A Int64List [StandardType].
///
/// {@category ast}
class Int64ListType extends StandardType {
  /// Construct a new [Int64ListType].
  const Int64ListType() : super(className: "Int64List");

  @override
  bool get nullable => false;
}

/// A nullable Int64List [StandardType].
///
/// {@category ast}
class NullableInt64ListType extends Int64ListType {
  /// Construct a new [NullableInt64ListType].
  const NullableInt64ListType();

  @override
  bool get nullable => true;
}

/// A Float32List [StandardType].
///
/// {@category ast}
class Float32ListType extends StandardType {
  /// Construct a new [Float32ListType].
  const Float32ListType() : super(className: "Float32List");

  @override
  bool get nullable => false;
}

/// A nullable Float32List [StandardType].
///
/// {@category ast}
class NullableFloat32ListType extends Float32ListType {
  /// Construct a new [Float32ListType].
  const NullableFloat32ListType();

  @override
  bool get nullable => true;
}

/// A Float64List [StandardType].
///
/// {@category ast}
class Float64ListType extends StandardType {
  /// Construct a new [Float64ListType].
  const Float64ListType() : super(className: "Float64List");

  @override
  bool get nullable => false;
}

/// A nullable Float64List [StandardType].
///
/// {@category ast}
class NullableFloat64ListType extends Float64ListType {
  /// Construct a new [NullableFloat64ListType].
  const NullableFloat64ListType();

  @override
  bool get nullable => true;
}

/// A List [StandardType].
///
/// {@category ast}
class ListType extends StandardType {
  /// Construct a new [ListType].
  const ListType(this.child) : super(className: "List");

  /// List child element.
  final AbstractType child;

  @override
  bool get nullable => false;
}

/// A nullable List [StandardType].
///
/// {@category ast}
class NullableListType extends ListType {
  /// Construct a new [NullableListType].
  const NullableListType(super.child);

  @override
  bool get nullable => true;
}

/// A Map [StandardType].
///
/// {@category ast}
class MapType extends StandardType {
  /// Construct a new [MapType].
  const MapType({
    required this.key,
    required this.value,
  }) : super(className: "Map");

  /// Map key element.
  final AbstractType key;

  /// Map value element.
  final AbstractType value;

  @override
  bool get nullable => false;
}

/// A nullable Map [MapType].
///
/// {@category ast}
class NullableMapType extends MapType {
  /// Construct a new [NullableMapType].
  const NullableMapType({
    required super.key,
    required super.value,
  });

  @override
  bool get nullable => true;
}
