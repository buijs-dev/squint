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

import "package:squint/src/ast/ast.dart";
import "package:test/test.dart";

void main() {

  test("verify TypeMember toString", () {
    expect(
        const TypeMember(name: "aVariable", type: StringType()).toString(),
        "TypeMember(name='aVariable',type='StandardType(name=String, nullable=false)', annotations =[])"
    );
  });

  test("IntType", () {
    expect(const IntType().className, "int");
    expect(const IntType().nullable, false);
  });

  test("NullableIntType", () {
    expect(const NullableIntType().className, "int");
    expect(const NullableIntType().nullable, true);
  });

  test("DoubleType", () {
    expect(const DoubleType().className, "double");
    expect(const DoubleType().nullable, false);
  });

  test("NullableDoubleType", () {
    expect(const NullableDoubleType().className, "double");
    expect(const NullableDoubleType().nullable, true);
  });

  test("BooleanType", () {
    expect(const BooleanType().className, "bool");
    expect(const BooleanType().nullable, false);
  });

  test("NullableBooleanType", () {
    expect(const NullableBooleanType().className, "bool");
    expect(const NullableBooleanType().nullable, true);
  });

  test("StringType", () {
    expect(const StringType().className, "String");
    expect(const StringType().nullable, false);
  });

  test("NullableStringType", () {
    expect(const NullableStringType().className, "String");
    expect(const NullableStringType().nullable, true);
  });

  test("Uint8ListType", () {
    expect(const Uint8ListType().className, "Uint8List");
    expect(const Uint8ListType().nullable, false);
  });

  test("NullableUint8ListType", () {
    expect(const NullableUint8ListType().className, "Uint8List");
    expect(const NullableUint8ListType().nullable, true);
  });

  test("Int32ListType", () {
    expect(const Int32ListType().className, "Int32List");
    expect(const Int32ListType().nullable, false);
  });

  test("NullableInt32ListType", () {
    expect(const NullableInt32ListType().className, "Int32List");
    expect(const NullableInt32ListType().nullable, true);
  });

  test("Int64ListType", () {
    expect(const Int64ListType().className, "Int64List");
    expect(const Int64ListType().nullable, false);
  });

  test("NullableInt64ListType", () {
    expect(const NullableInt64ListType().className, "Int64List");
    expect(const NullableInt64ListType().nullable, true);
  });

  test("Float32ListType", () {
    expect(const Float32ListType().className, "Float32List");
    expect(const Float32ListType().nullable, false);
  });

  test("NullableFloat32ListType", () {
    expect(const NullableFloat32ListType().className, "Float32List");
    expect(const NullableFloat32ListType().nullable, true);
  });

  test("Float64ListType", () {
    expect(const Float64ListType().className, "Float64List");
    expect(const Float64ListType().nullable, false);
  });

  test("NullableFloat64ListType", () {
    expect(const NullableFloat64ListType().className, "Float64List");
    expect(const NullableFloat64ListType().nullable, true);
  });

  test("ListType", () {
    expect(const ListType(StringType()).className, "List");
    expect(const ListType(StringType()).nullable, false);
    expect(const ListType(StringType()).child, const StringType());
  });

  test("NullableListType", () {
    expect(const NullableListType(StringType()).className, "List");
    expect(const NullableListType(StringType()).nullable, true);
    expect(const ListType(StringType()).child, const StringType());
  });

  test("MapType", () {
    expect(const MapType(key: StringType(), value: IntType()).className, "Map");
    expect(const MapType(key: StringType(), value: IntType()).nullable, false);
    expect(const MapType(key: StringType(), value: IntType()).key, const StringType());
    expect(const MapType(key: StringType(), value: IntType()).value, const IntType());
  });

  test("NullableMapType", () {
    expect(const NullableMapType(key: StringType(), value: IntType()).className, "Map");
    expect(const NullableMapType(key: StringType(), value: IntType()).nullable, true);
    expect(const NullableMapType(key: StringType(), value: IntType()).key, const StringType());
    expect(const NullableMapType(key: StringType(), value: IntType()).value, const IntType());
  });

}
