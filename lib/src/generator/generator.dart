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

import "../../squint.dart";
import "../ast/ast.dart";
import "../ast/types.dart";

///
String generateMethods({
  required CustomType type,
}) =>
    """
${type.className} deserialize${type.className}(String json) =>
    deserialize${type.className}Map(jsonDecode(json) as Map<String, dynamic>);
    
    ${type.className} deserialize${type.className}Map(Map<String, dynamic> data) =>
      ${type.className}(
          ${type.members.map(_generateTypeMemberDeserializer).join(",\n")}
      );
""";

String _generateTypeMemberDeserializer(TypeMember typeMember) =>
    typeMember.generateTypeMemberDeserializer();

extension on TypeMember {
  String generateTypeMemberDeserializer() {
    if (type is CustomType) {
      return (type as CustomType).generateTypeMemberDeserializer(name);
    }

    if (type is StandardType) {
      return (type as StandardType).generateTypeMemberDeserializer(name);
    }

    throw SquintException(
        "TypeMember type is not supported! Failed to generate deserializer: $this");
  }
}

extension on CustomType {
  String generateTypeMemberDeserializer(String name) {
    return """$name: data.squintValueOrThrow<$className>(key: "$name")""";
  }
}

extension on StandardType {
  String generateTypeMemberDeserializer(String name) {
    if (this is ListType) {
      return """$name: data.listValueOrThrow(key: "$name")${(this as ListType).child.generateListTypeMapper}.toList()""";
    }

    if (this is NullableListType) {
      return """$name: data.listValueOrThrow(key: "$name")?${(this as ListType).child.generateListTypeMapper}.toList()""";
    }

    if (this is MapType) {
      //TODO
    }

    if (this is NullableMapType) {
      //TODO
    }

    return """$name: data.${_deserializerMethod[this]}(key: "$name")""";
  }
}

extension on AbstractType {
  String get generateListTypeMapper {
    if (this is ListType) {
      //TODO
    }

    if (this is NullableListType) {
      //TODO
    }

    if (this is MapType) {
      //TODO
    }

    if (this is NullableMapType) {
      //TODO
    }

    final method = _unwrappingMethod[this];

    if (method == null) {
      throw SquintException("Failed to generateListTypeMapper: $this");
    }

    return method;
  }
}

/// Method to get a [StandardType] value from a JSON map.
final _deserializerMethod = {
  const IntType(): "intValueOrThrow",
  const DoubleType(): "doubleValueOrThrow",
  const BooleanType(): "boolValueOrThrow",
  const StringType(): "stringValueOrThrow",
  const Uint8ListType(): "uint8ListValueOrThrow",
  const Int32ListType(): "int32ListValueOrThrow",
  const Int64ListType(): "int64ListValueOrThrow",
  const Float32ListType(): "float32ListValueOrThrow",
  const Float64ListType(): "float64ListValueOrThrow",
  const NullableIntType(): "intValueOrNull",
  const NullableDoubleType(): "doubleValueOrNull",
  const NullableBooleanType(): "boolValueOrNull",
  const NullableStringType(): "stringValueOrNull",
  const NullableUint8ListType(): "uint8ListValueOrNull",
  const NullableInt32ListType(): "int32ListValueOrNull",
  const NullableInt64ListType(): "int64ListValueOrNull",
  const NullableFloat32ListType(): "float32ListValueOrNull",
  const NullableFloat64ListType(): "float64ListValueOrNull",
};

/// Mapping method to call after retrieving a value from a JSON map
/// which requires a map call to unwrap it's child element.
///
/// Example:
///
/// An int value (not wrapped) can be retrieved with [_deserializerMethod] only:
/// - foo: data.intValueOrThrow(key: "foo") // returns the value of foo with type int.
///
/// A List<int> value (wrapped) requires a mapping postfix:
/// - foo: data.listValueOrThrow(key: "foo")
///            .map<int>(intOrThrow).toList() // returns the value of foo with type List<int>.
final _unwrappingMethod = {
  const IntType(): ".map<int>(intOrThrow)",
  const DoubleType(): ".map<double>(doubleOrThrow)",
  const BooleanType(): ".map<bool>(boolOrThrow)",
  const StringType(): ".map<String>(stringOrThrow)",
  const NullableIntType(): ".map<int?>(intOrNull)",
  const NullableDoubleType(): ".map<double?>(doubleOrNull)",
  const NullableBooleanType(): ".map<bool?>(boolOrNull)",
  const NullableStringType(): ".map<String?>(stringOrNull)",
};
