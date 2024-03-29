// Copyright (c) 2021 - 2023 Buijs Software
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

/// Utilities to generate getters/setters for enum classes and serializers.
///
/// {@category generator}
extension JsonNodeEnumGenerator on EnumType {
  /// Generate setters.
  ///
  /// {@category generator}
  List<String> toJsonNodeSetters(String key) {
    final output = <String>[];

    var index = 0;
    while (index < values.length) {
      output.add("""
          case $className.${values[index]}:
            return const JsonString(key: "$key", data: "${valuesJSON[index]}");
          """);
      index += 1;
    }

    return output;
  }

  /// Generate getters.
  ///
  /// {@category generator}
  List<String> toJsonNodeGetters(String key) {
    final output = <String>[];

    var index = 0;
    while (index < values.length) {
      output.add("""
          case "${valuesJSON[index]}":
            return $className.${values[index]};
          """);
      index += 1;
    }

    return output;
  }
}

extension on TypeMember {
  String toJsonGetter({String dataPrefix = ""}) {
    final className = type.className;

    final valueJsonAnnotated = annotations
        .firstBy((element) => element.name == "JsonValue")
        ?.data["tag"];

    final jsonKey = valueJsonAnnotated ?? name;

    final decodeJsonAnnotated =
        annotations.firstBy((element) => element.name == "JsonDecode");

    final q = type.nullable ? "OrNull" : "";

    if (decodeJsonAnnotated != null) {
      final method = decodeJsonAnnotated.data["using"];

      final unwrapperType = decodeJsonAnnotated.data["jsonElement"];

      String? unwrapper;

      if (unwrapperType == "JsonString") {
        unwrapper = '${dataPrefix}stringNode$q("$jsonKey")';
      } else if (unwrapperType == "JsonFloatingNumber") {
        unwrapper = '${dataPrefix}floatNode$q("$jsonKey")';
      } else if (unwrapperType == "JsonIntegerNumber") {
        unwrapper = '${dataPrefix}integerNode$q("$jsonKey")';
      } else if (unwrapperType == "JsonBoolean") {
        unwrapper = '${dataPrefix}booleanNode$q("$jsonKey")';
      } else if (unwrapperType == "JsonArray") {
        final childType = (type as ListType).child;
        unwrapper = "${dataPrefix}arrayNode$q<${childType.printType}>";
        if (childType is CustomType) {
          unwrapper +=
              '("$jsonKey", decoder: (dynamic value) => JsonObject.fromMap(data: value as Map<String, dynamic>).to${childType.className})';
        } else if (childType is EnumType) {
          unwrapper +=
              '("$jsonKey", decoder: (dynamic value) => value.to${childType.className})';
        } else {
          unwrapper += '("$jsonKey")';
        }
      } else if (unwrapperType == "JsonObject") {
        unwrapper = '${dataPrefix}objectNode$q("$jsonKey")';
      } else {
        throw SquintException("Unsupported data type: $unwrapperType");
      }

      return "$name: $method($unwrapper)";
    }

    switch (className) {
      case "String":
        return '$name: ${dataPrefix}string$q("$jsonKey")';
      case "double":
        return '$name: ${dataPrefix}float$q("$jsonKey")';
      case "int":
        return '$name: ${dataPrefix}integer$q("$jsonKey")';
      case "bool":
        return '$name: ${dataPrefix}boolean$q("$jsonKey")';
      case "List":
        final childType = (type as ListType).child;
        final decoderOrBlank = childType.printDecoderMethod;
        if (childType is CustomType) {
          return '$name: ${dataPrefix}array$q<${childType.printType}>("$jsonKey", decoder: $decoderOrBlank)';
        } else if (childType is EnumType) {
          return '$name: ${dataPrefix}array$q<${childType.printType}>("$jsonKey", decoder: $decoderOrBlank)';
        } else {
          return '$name: ${dataPrefix}array$q<${childType.printType}>("$jsonKey")';
        }
      case "Map":
        final mapType = type as MapType;
        final mapKeyType = mapType.validKeyTypeOrThrow;
        final mapKeyTypeString = mapKeyType.className;
        final mapValueType = mapType.value;
        final mapValueDecoder = mapValueType.printDecoderMethod;
        final mapValueDecoderLine =
            mapValueDecoder == "" ? "" : ", toTypedValue: $mapValueDecoder";
        if (mapKeyType is StringType) {
          return '$name: ${dataPrefix}object$q("$jsonKey" $mapValueDecoderLine)';
        } else if (mapKeyType is EnumType) {
          return '$name: ${dataPrefix}typedObject<$mapKeyTypeString,${mapType.value.className}>$q(key: "$jsonKey", toTypedKey: (String entry) => $mapKeyTypeString.values.firstWhere((value) => value == entry, orElse: () => $mapKeyTypeString.${mapKeyType.noneValue}) $mapValueDecoderLine)';
        } else if (mapKeyType is IntType) {
          return '$name: ${dataPrefix}typedObject<int,${mapType.value.className}>$q(key: "$jsonKey", toTypedKey: (String value) => int.parse(value) $mapValueDecoderLine)';
        } else if (mapKeyType is DoubleType) {
          return '$name: ${dataPrefix}typedObject<int,${mapType.value.className}>$q(key: "$jsonKey", toTypedKey: (String value) => double.parse(value) $mapValueDecoderLine)';
        } else if (mapKeyType is BooleanType) {
          return '$name: ${dataPrefix}typedObject<int,${mapType.value.className}>$q(key: "$jsonKey", toTypedKey: (String value) => value.toUpperCase() == "TRUE" $mapValueDecoderLine)';
        } else {
          throw SquintException(
              "Map has unsupported key Type: ${mapKeyType.className}");
        }
      case "dynamic":
        return '$name: ${dataPrefix}byKey("$jsonKey").data';
      default:
        throw SquintException("Unsupported data type: $className");
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

    final q = type.nullable ? "OrNull" : "";

    switch (type.className) {
      case "String":
        return 'JsonString$q(key: "$jsonKey", data: $dataPrefix$name)';
      case "double":
        return 'JsonFloatingNumber$q(key: "$jsonKey", data: $dataPrefix$name)';
      case "int":
        return 'JsonIntegerNumber$q(key: "$jsonKey", data: $dataPrefix$name)';
      case "bool":
        return 'JsonBoolean$q(key: "$jsonKey", data: $dataPrefix$name)';
      case "List":
        return 'JsonArray$q<dynamic>(key: "$jsonKey", data: $dataPrefix$name)';
      case "Map":
        final mapType = type as MapType;
        final mapKeyType = mapType.validKeyTypeOrThrow;
        final mapKeyTypeString = mapKeyType.className;
        if (mapKeyType is StringType) {
          return 'JsonObject$q.fromMap(key: "$jsonKey", data: $dataPrefix$name)';
        } else if (mapKeyType is EnumType) {
          return 'JsonObject$q.fromTypedMap<$mapKeyTypeString>(keyToString: ($mapKeyTypeString entry) => entry.name, key: "$jsonKey", data: $dataPrefix$name)';
        } else if (mapKeyType is IntType) {
          return 'JsonObject$q.fromTypedMap<$mapKeyTypeString>(keyToString: (int value) => "\$value", key: "$jsonKey", data: $dataPrefix$name)';
        } else if (mapKeyType is DoubleType) {
          return 'JsonObject$q.fromTypedMap<$mapKeyTypeString>(keyToString: (double value) => "\$value", key: "$jsonKey", data: $dataPrefix$name)';
        } else if (mapKeyType is BooleanType) {
          return 'JsonObject$q.fromTypedMap<$mapKeyTypeString>(keyToString: (bool value) => "\$value", key: "$jsonKey", data: $dataPrefix$name)';
        } else {
          throw SquintException(
              "Map has unsupported key Type: ${mapKeyType.className}");
        }
      case "dynamic":
        return 'dynamicValue(key: "$jsonKey", data: $dataPrefix$name)';
      default:
        throw SquintException("Unsupported data type: ${type.className}");
    }
  }
}

/// Print import statements.
extension ImportsBuilder on CustomType {
  /// Return import statement for all non-standard types.
  Set<String> importStatements(Set<AbstractType> types) {
    types
      ..removeWhere((type) => type is StandardType)
      ..removeWhere((type) => type.className == className);
    return types
        .map((e) => e.className.snakeCase)
        .map((e) =>
            "import '${e}_dataclass.dart';\nimport '${e}_extensions.dart';\n")
        .toSet();
  }
}

/// Return [String] enum value for empty JSON String.
extension NoneValueBuilder on EnumType {
  /// Return "NONE" if all enum values are uppercase or "none" if not.
  String get noneValue =>
      values.every((e) => e == e.toUpperCase()) ? "NONE" : "none";
}

extension on MapType {
  AbstractType get validKeyTypeOrThrow {
    if (key.nullable) {
      throw SquintException("Nullable keys are not allowed for Type Map.");
    }

    if (_supportedMapKeyTypes.contains(key.runtimeType)) {
      return key;
    }

    throw SquintException("Map has unsupported key Type: ${key.className}");
  }
}

final _supportedMapKeyTypes = [
  StringType,
  IntType,
  DoubleType,
  BooleanType,
  EnumType
];

/// Utility to normalize user defined Types.
extension AbstractTypeNormalizer on AbstractType {
  /// Normalize [AbstractType] by replacing any (nested Type)
  /// with the instance scanned by the analyzer.
  AbstractType normalizeType(
    Set<EnumType> enumTypes,
    Set<CustomType> customTypes,
  ) {
    final customTypeOrNull =
        customTypes.firstBy((type) => type.className == className);
    if (customTypeOrNull != null) {
      return customTypeOrNull;
    }

    final enumTypeOrNull =
        enumTypes.firstBy((type) => type.className == className);
    if (enumTypeOrNull != null) {
      return enumTypeOrNull;
    }

    if (this is ListType) {
      final listType = this as ListType;
      final childType = listType.child.normalizeType(enumTypes, customTypes);
      return listType.nullable
          ? NullableListType(childType)
          : ListType(childType);
    }

    if (this is MapType) {
      final mapType = this as MapType;
      final keyType = mapType.key.normalizeType(enumTypes, customTypes);
      final valueType = mapType.value.normalizeType(enumTypes, customTypes);
      return mapType.nullable
          ? NullableMapType(key: keyType, value: valueType)
          : MapType(key: keyType, value: valueType);
    }

    return this;
  }
}

/// Output decoding method line.
extension DecoderMethod on AbstractType {
  /// Output decoding method line.
  String get printDecoderMethod {
    if (this is CustomType) {
      return "(dynamic value) => JsonObject.fromMap(data: value as Map<String, dynamic>).to$className";
    } else if (this is EnumType) {
      return "(dynamic value) => value.to$className";
    } else {
      return "";
    }
  }
}
