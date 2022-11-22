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

    if (this is JsonNull) {
      return const NullableStringType();
    }

    if (this is JsonArray) {
      final array = this as JsonArray;
      final data = array.data as List<dynamic>;

      final noNullValues = data.where((dynamic e) => e != null);

      final hasNullValues = noNullValues.length != data.length;

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

      throw SquintException(
          "Unable to determine List child type for data: $data");
    }

    if (this is JsonObject) {
      return (this as JsonObject).toCustomType(className: key.camelcase);
    }

    throw SquintException("Unable to convert JSON String to CustomType");
  }
}
