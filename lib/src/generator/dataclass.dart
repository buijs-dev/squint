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

/// Convert a [JsonObject] String to a [CustomType].
extension Json2CustomType on JsonObject {
  /// Convert a [JsonObject] to a [CustomType].
  CustomType toCustomType({
    required String className,
  }) =>
      CustomType(
        className: className,
        members: data.toTypeMembers,
      );
}

extension on Map<String, JsonElement> {
  List<TypeMember> get toTypeMembers {
    final output = <TypeMember>[];

    forEach((key, value) {
      output.add(
        TypeMember(
          name: key,
          type: value.toAbstractType(key),
        ),
      );
    });

    return output;
  }
}

/// Convert a [JsonElement] String to an [AbstractType].
extension on JsonElement {
  AbstractType toAbstractType(String key) {
    if (this is JsonString) {
      return const StringType();
    }

    if (this is JsonBoolean) {
      return const BooleanType();
    }

    if (this is JsonNumber) {
      return const DoubleType();
    }

    if (this is JsonArray) {
      return (this as JsonArray).toListType;
    }

    if (this is JsonObject) {
      return (this as JsonObject).toCustomType(className: key.camelcase);
    }

    throw SquintException("Unable to convert JSON String to CustomType");
  }
}

/// Convert a [JsonArray] String to a [StandardType].
extension on JsonArray {
  StandardType get toListType => (data as List<dynamic>).toListType;
}

/// Convert a [List] to a [StandardType].
extension on List<dynamic> {
  StandardType get toListType {
    final noNullValues = where((dynamic e) => e != null);

    final hasNullValues = noNullValues.length != length;

    if (noNullValues.every((dynamic element) => element is String)) {
      return hasNullValues
          ? const ListType(NullableStringType())
          : const ListType(StringType());
    }

    if (noNullValues.every((dynamic element) => element is bool)) {
      return hasNullValues
          ? const ListType(NullableBooleanType())
          : const ListType(BooleanType());
    }

    if (noNullValues.every((dynamic element) => element is double)) {
      return hasNullValues
          ? const ListType(NullableDoubleType())
          : const ListType(DoubleType());
    }

    if (noNullValues.every((dynamic element) => element is Map)) {
      final keyType = (noNullValues.first as Map).keys.toList().toListType;

      final valueType = (noNullValues.first as Map).values.toList().toListType;

      return hasNullValues
          ? ListType(NullableMapType(key: keyType, value: valueType))
          : ListType(MapType(key: keyType, value: valueType));
    }

    throw SquintException(
      "Unable to determine List child type for data: $this",
    );
  }
}
