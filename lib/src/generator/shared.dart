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

import "../analyzer/analyzer.dart";
import "../ast/ast.dart";
import "../common/common.dart";

/// Utilities to generate getter/setters for dataclasses and serializers.
///
/// {@category generator}
extension JsonNodeGenerator on List<TypeMember> {
  /// Generate setters.
  ///
  /// {@category generator}
  List<String> toJsonNodeSetters({String dataPrefix = ""}) =>
      map((TypeMember tm) => "    ${tm.toJsonSetter(dataPrefix: dataPrefix)},")
          .toList()
        ..sort((a, b) => a.trim().startsWith("Json") ? -1 : 1);

  /// Generate getters.
  ///
  /// {@category generator}
  List<String> toJsonNodeGetters({String dataPrefix = ""}) =>
      map((TypeMember tm) => "    ${tm.toJsonGetter(dataPrefix: dataPrefix)},")
          .toList();
}

extension on TypeMember {
  String toJsonGetter({String dataPrefix = ""}) {
    final type = this.type.className.removePrefixIfPresent("Nullable");

    final valueJsonAnnotated = annotations
        .firstBy((element) => element.name == "JsonValue")
        ?.data["tag"];

    final jsonKey = valueJsonAnnotated ?? name;

    final decodeJsonAnnotated =
        annotations.firstBy((element) => element.name == "JsonDecode");

    if (decodeJsonAnnotated != null) {
      final method = decodeJsonAnnotated.data["using"];

      final unwrapperType = decodeJsonAnnotated.data["jsonElement"];

      String? unwrapper;

      if (unwrapperType == "JsonString") {
        unwrapper = '${dataPrefix}stringNode("$jsonKey")';
      } else if (unwrapperType == "JsonFloatingNumber") {
        unwrapper = '${dataPrefix}floatNode("$jsonKey")';
      } else if (unwrapperType == "JsonIntegerNumber") {
        unwrapper = '${dataPrefix}integerNode("$jsonKey")';
      } else if (unwrapperType == "JsonBoolean") {
        unwrapper = '${dataPrefix}booleanNode("$jsonKey")';
      } else if (unwrapperType == "JsonArray") {
        unwrapper =
            '${dataPrefix}arrayNode<${(this.type as ListType).child.printType}>("$jsonKey")';
      } else if (unwrapperType == "JsonObject") {
        unwrapper = '${dataPrefix}objectNode("$jsonKey")';
      } else {
        throw SquintException("Unsupported data type: $unwrapperType");
      }

      return "$name: $method($unwrapper)";
    }

    switch (type) {
      case "String":
        return '$name: ${dataPrefix}string("$jsonKey")';
      case "double":
        return '$name: ${dataPrefix}float("$jsonKey")';
      case "int":
        return '$name: ${dataPrefix}integer("$jsonKey")';
      case "bool":
        return '$name: ${dataPrefix}boolean("$jsonKey")';
      case "List":
        return '$name: ${dataPrefix}array<${(this.type as ListType).child.printType}>("$jsonKey")';
      case "Map":
        return '$name: ${dataPrefix}object("$jsonKey")';
      case "dynamic":
        return '$name: ${dataPrefix}byKey("$jsonKey").data';
      default:
        throw SquintException("Unsupported data type: $type");
    }
  }

  String toJsonSetter({String dataPrefix = ""}) {
    final valueJsonAnnotated = annotations
        .firstBy((element) => element.name == "JsonValue")
        ?.data["tag"];

    final jsonKey = valueJsonAnnotated ?? name;

    final encodeJsonAnnotated = annotations
        .firstBy((element) => element.name == "JsonEncode")
        ?.data["using"];

    if (encodeJsonAnnotated != null) {
      return "$encodeJsonAnnotated($dataPrefix$name)";
    }

    final type = this.type.className.removePrefixIfPresent("Nullable");

    switch (type) {
      case "String":
        return 'JsonString(key: "$jsonKey", data: $dataPrefix$name)';
      case "double":
        return 'JsonFloatingNumber(key: "$jsonKey", data: $dataPrefix$name)';
      case "int":
        return 'JsonIntegerNumber(key: "$jsonKey", data: $dataPrefix$name)';
      case "bool":
        return 'JsonBoolean(key: "$jsonKey", data: $dataPrefix$name)';
      case "List":
        return 'JsonArray<dynamic>(key: "$jsonKey", data: $dataPrefix$name)';
      case "Map":
        return 'JsonObject.fromMap(key: "$jsonKey", data: $dataPrefix$name)';
      case "dynamic":
        return 'dynamicValue(key: "$jsonKey", data: $dataPrefix$name)';
      default:
        throw SquintException("Unsupported data type: ${this.type.className}");
    }
  }
}
