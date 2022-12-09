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

import '../analyzer/analyzer.dart';
import "../ast/ast.dart";
import "../common/common.dart";

///
extension JsonElementGenerator on List<TypeMember> {
  ///
  List<String> toJsonNodeSetters({String dataPrefix = ""}) =>
      map((TypeMember tm) => "    ${tm.toJsonType(dataPrefix: dataPrefix)},")
          .toList();

  ///
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
        unwrapper = '${dataPrefix}string("$jsonKey")';
      } else if (unwrapperType == "JsonFloatingNumber") {
        unwrapper = '${dataPrefix}float("$jsonKey")';
      } else if (unwrapperType == "JsonIntegerNumber") {
        unwrapper = '${dataPrefix}integer("$jsonKey")';
      } else if (unwrapperType == "JsonBoolean") {
        unwrapper = '${dataPrefix}boolean("$jsonKey")';
      } else if (unwrapperType == "JsonArray") {
        unwrapper =
            '${dataPrefix}array<${(this.type as ListType).child.printType}>("$jsonKey")';
      } else if (unwrapperType == "JsonObject") {
        unwrapper = '${dataPrefix}object("$jsonKey")';
      } else {
        throw SquintException("Unsupported data type: $unwrapperType");
      }

      return "$name: $method($unwrapper)";
    }

    switch (type) {
      case "String":
        return '$name: ${dataPrefix}stringValue("$jsonKey")';
      case "double":
        return '$name: ${dataPrefix}floatValue("$jsonKey")';
      case "int":
        return '$name: ${dataPrefix}integerValue("$jsonKey")';
      case "bool":
        return '$name: ${dataPrefix}booleanValue("$jsonKey")';
      case "List":
        return '$name: ${dataPrefix}arrayValue<${(this.type as ListType).child.printType}>("$jsonKey")';
      case "Map":
        return '$name: ${dataPrefix}object("$jsonKey").rawData()';
      default:
        throw SquintException("Unsupported data type: $type");
    }
  }

  String toJsonType({String dataPrefix = ""}) {
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
        return 'JsonObject.fromMap($dataPrefix$name, "$jsonKey")';
      default:
        throw SquintException("Unsupported data type: ${this.type.className}");
    }
  }
}
