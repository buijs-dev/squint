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

import "ast.dart";

/// A Integer [StandardType].
class IntType extends StandardType {
  /// Construct a new [IntType].
  const IntType() : super(className: "int", nullable: false);
}

/// A nullable Integer [StandardType].
class NullableIntType extends StandardType {
  /// Construct a new [NullableIntType].
  const NullableIntType() : super(className: "int", nullable: true);
}

/// A double [StandardType].
class DoubleType extends StandardType {
  /// Construct a new [DoubleType].
  const DoubleType() : super(className: "double", nullable: false);
}

/// A nullable double [StandardType].
class NullableDoubleType extends StandardType {
  /// Construct a new [NullableDoubleType].
  const NullableDoubleType() : super(className: "double", nullable: true);
}

/// A Boolean [StandardType].
class BooleanType extends StandardType {
  /// Construct a new [BooleanType].
  const BooleanType() : super(className: "bool", nullable: false);
}

/// A nullable Boolean [StandardType].
class NullableBooleanType extends StandardType {
  /// Construct a new [NullableBooleanType].
  const NullableBooleanType() : super(className: "bool", nullable: true);
}

/// A String [StandardType].
class StringType extends StandardType {
  /// Construct a new [StringType].
  const StringType() : super(className: "String", nullable: false);
}

/// A nullable String [StandardType].
class NullableStringType extends StandardType {
  /// Construct a new [NullableStringType].
  const NullableStringType() : super(className: "String", nullable: true);
}

/// A Uint8List [StandardType].
class Uint8ListType extends StandardType {
  /// Construct a new [Uint8ListType].
  const Uint8ListType() : super(className: "Uint8List", nullable: false);
}

/// A nullable Uint8List [StandardType].
class NullableUint8ListType extends StandardType {
  /// Construct a new [NullableUint8ListType].
  const NullableUint8ListType() : super(className: "Uint8List", nullable: true);
}

/// A Int32List [StandardType].
class Int32ListType extends StandardType {
  /// Construct a new [Int32ListType].
  const Int32ListType() : super(className: "Int32List", nullable: false);
}

/// A nullable Int32List [StandardType].
class NullableInt32ListType extends StandardType {
  /// Construct a new [NullableInt32ListType].
  const NullableInt32ListType() : super(className: "Int32List", nullable: true);
}

/// A Int64List [StandardType].
class Int64ListType extends StandardType {
  /// Construct a new [Int64ListType].
  const Int64ListType() : super(className: "Int64List", nullable: false);
}

/// A nullable Int64List [StandardType].
class NullableInt64ListType extends StandardType {
  /// Construct a new [NullableInt64ListType].
  const NullableInt64ListType() : super(className: "Int64List", nullable: true);
}

/// A Float32List [StandardType].
class Float32ListType extends StandardType {
  /// Construct a new [Float32ListType].
  const Float32ListType() : super(className: "Float32List", nullable: false);
}

/// A nullable Float32List [StandardType].
class NullableFloat32ListType extends StandardType {
  /// Construct a new [Float32ListType].
  const NullableFloat32ListType()
      : super(className: "Float32List", nullable: true);
}

/// A Float64List [StandardType].
class Float64ListType extends StandardType {
  /// Construct a new [Float64ListType].
  const Float64ListType() : super(className: "Float64List", nullable: false);
}

/// A nullable Float64List [StandardType].
class NullableFloat64ListType extends StandardType {
  /// Construct a new [NullableFloat64ListType].
  const NullableFloat64ListType()
      : super(className: "Float64List", nullable: true);
}

/// A List [StandardType].
class ListType extends StandardType {
  /// Construct a new [ListType].
  const ListType(this.child) : super(className: "List", nullable: false);

  /// List child element.
  final AbstractType child;
}

/// A nullable List [StandardType].
class NullableListType extends StandardType {
  /// Construct a new [NullableListType].
  const NullableListType(this.child) : super(className: "List", nullable: true);

  /// List child element.
  final AbstractType child;
}

/// A Map [StandardType].
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
