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
import "object2custom.dart";
import "object2map.dart";
import "undetermined.dart";

/// Convert a [JsonNode] to an [AbstractType].
extension JsonNode2AbstractType on JsonNode {
  /// Convert a [JsonNode] to an [AbstractType].
  AbstractType toAbstractType(String key) {
    if (this is JsonString) {
      return const StringType();
    }

    if (this is JsonBoolean) {
      return const BooleanType();
    }

    if (this is JsonFloatingNumber) {
      return const DoubleType();
    }

    if (this is JsonIntegerNumber) {
      return const IntType();
    }

    if (this is JsonArray) {
      final arr = this as JsonArray;
      final data = arr.data as List<dynamic>;
      if (data.isNotEmpty && data.first is Map) {
        final type = (data.first as Map).values.first.runtimeType;
        final allChildrenOfSameType = data.every((child) {
          return (child as Map).values.every((value) {
            return value.runtimeType == type;
          });
        });

        /// If all children are of same type then an strongly typed
        /// Map can be used and there is no need to create a JsonObject,
        ///
        /// Example:
        ///
        /// If a List contains a Map<String, dynamic> and all children
        /// of type dynamic are of the same type, for instance String,
        /// then this can be returned as Map<String, String>.
        ///
        /// If a List contains a Map<String,dynamic> and all all children
        /// are not of the same type, for instance some are String and
        /// others double, then this could not be cast to a Map<String,String>
        /// or Map<String,double>. In this case building a JsonObject and
        /// converting it to a [CustomType] is better.
        if (!allChildrenOfSameType) {
          return ListType(
            JsonObject.fromMap(data: data.first as Map<String, dynamic>)
                .toCustomType(className: key.camelCase()),
          );
        }
      }
      return (arr.data as List<dynamic>).toListType;
    }

    if (this is JsonObject) {
      final valueType = (this as JsonObject).valuesAllOfSameType;
      if (valueType != null) {
        if (valueType is StringType) {
          return const MapType(key: StringType(), value: StringType());
        }

        if (valueType is BooleanType) {
          return const MapType(key: StringType(), value: BooleanType());
        }

        if (valueType is IntType) {
          return const MapType(key: StringType(), value: IntType());
        }

        if (valueType is DoubleType) {
          return const MapType(key: StringType(), value: DoubleType());
        }
      }
      return (this as JsonObject).toCustomType(className: key.camelCase());
    }

    return const UndeterminedAsDynamic();
  }
}

/// Convert a [List] to a [StandardType].
extension on List<dynamic> {
  ListType get toListType {
    final noNullValues = where((e) => e != null);
    final hasNullValues = noNullValues.length != length;

    if (noNullValues.every((element) => element is String)) {
      return hasNullValues
          ? const ListType(NullableStringType())
          : const ListType(StringType());
    }

    if (noNullValues.every((element) => element is bool)) {
      return hasNullValues
          ? const ListType(NullableBooleanType())
          : const ListType(BooleanType());
    }

    if (noNullValues.every((element) => element is double)) {
      return hasNullValues
          ? const ListType(NullableDoubleType())
          : const ListType(DoubleType());
    }

    if (noNullValues.every((element) => element is int)) {
      return hasNullValues
          ? const ListType(NullableIntType())
          : const ListType(IntType());
    }

    if (noNullValues.every((element) => element is Map)) {
      final keyType =
          (noNullValues.first as Map).keys.toList().toListType.child;

      final valueType =
          (noNullValues.first as Map).values.toList().toListType.child;

      return hasNullValues
          ? ListType(NullableMapType(key: keyType, value: valueType))
          : ListType(MapType(key: keyType, value: valueType));
    }

    return const ListType(UndeterminedAsDynamic());
  }
}
