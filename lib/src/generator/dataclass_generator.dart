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
import "generator.dart";

/// Convert a [CustomType] to a data class.
///
/// {@category generator}
extension CustomType2DataClass on CustomType {
  /// Add Annotation data to CustomType by generating the dataclass
  /// using [generateDataClassFile] and the using [analyze] to collect
  /// the annotations.
  ///
  /// {@category generator}
  CustomType get withDataClassMetadata {
    final dataclass = generateDataClassFile();
    final types = analyze(fileContent: dataclass);
    final customs = types.whereType<CustomType>();
    final parent = customs.first;
    final children = customs.toList()..removeAt(0);
    final members = <TypeMember>[];
    for (final member in parent.members) {
      members.add(TypeMember(
        name: member.name,
        annotations: member.annotations,
        type: member.type.normalizeType(children),
      ));
    }

    return CustomType(
      className: parent.className,
      members: members,
    );
  }

  /// Generate data class from [CustomType].
  ///
  /// {@category generator}
  String generateDataClassFile({
    SquintGeneratorOptions options = standardSquintGeneratorOptions,
  }) {
    final buffer = StringBuffer()..write("""
      |// Copyright (c) 2021 - 2022 Buijs Software
      |//
      |// Permission is hereby granted, free of charge, to any person obtaining a copy
      |// of this software and associated documentation files (the "Software"), to deal
      |// in the Software without restriction, including without limitation the rights
      |// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      |// copies of the Software, and to permit persons to whom the Software is
      |// furnished to do so, subject to the following conditions:
      |//
      |// The above copyright notice and this permission notice shall be included in all
      |// copies or substantial portions of the Software.
      |//
      |// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      |// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      |// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      |// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      |// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      |// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
      |// SOFTWARE.
      |
      |import 'package:squint_json/squint.dart';
      |
      |/// Autogenerated data class by Squint.
      ${generateDataClassBody(options)}""");

    for (final ct
        in members.map((e) => e.type).whereType<CustomType>().toSet()) {
      buffer.write(ct.generateDataClassBody(options));
    }

    for (final ct
        in members.where((element) => element.type is CustomType).toList()) {
      buffer
        ..write(ct.encodingMethodBody)
        ..write(ct.decodingMethodBody);
    }

    return buffer.toString().formattedDartCode;
  }

  /// Generate data class from [CustomType].
  ///
  /// {@category generator}
  String generateDataClassBody(SquintGeneratorOptions options) {
    // Sort members so required fields are serialized first and nullables last.
    final sortedMembers = members..sort((a, b) => !a.type.nullable ? -1 : 1);

    // Print the members as constructor fields.
    final constructorMembers =
        sortedMembers.map((e) => e.printConstructor).join("\n");

    // Print the members as class fields.
    final fieldMembers = sortedMembers.map((e) {
      return options.includeJsonAnnotations
          ? e.printField(alwaysAddJsonValue: options.alwaysAddJsonValue)
          : e.printFieldWithoutAnnotations;
    }).join(options.blankLineBetweenFields ? "\n\n" : "\n");

    return """
      |@squint
      |class $className {
      |   const $className ({
      |      $constructorMembers
      |   });
      |
      |   $fieldMembers
      |}
      |
      """
        .format;
  }
}

extension on TypeMember {
  String get printConstructor =>
      type.nullable ? "this.$name," : "required this.$name,";

  String get printFieldWithoutAnnotations =>
      type.nullable && type.className != "dynamic"
          ? "final ${type.printType}? $name;"
          : "final ${type.printType} $name;";

  String printField({bool alwaysAddJsonValue = false}) {
    final buffer = StringBuffer();

    if (type is CustomType) {
      buffer
        ..write("@JsonEncode(using: ${type.className.encodingMethodName})\n")
        ..write(
            "@JsonDecode<${type.className}, JsonObject>(using: ${type.className.decodingMethodName})\n");
    }

    if (name != jsonNodeKey || alwaysAddJsonValue) {
      buffer.write('@JsonValue("$jsonNodeKey")\n');
    }

    if (type.nullable && type.className != "dynamic") {
      buffer.write("final ${type.printType}? $name;");
    } else {
      buffer.write("final ${type.printType} $name;");
    }

    return buffer.toString();
  }

  String get encodingMethodBody {
    return """
      JsonObject ${name.encodingMethodName}(${type.className} $name) =>
        JsonObject.fromNodes(
        key: "$name",
        nodes: [
        ${(type as CustomType).members.toJsonNodeSetters(dataPrefix: "$name.").join("\n")}
        ]);
          \n""";
  }

  String get decodingMethodBody => """
    ${type.className} ${name.decodingMethodName}(JsonObject object) =>
       ${type.className}(
        ${(type as CustomType).members.toJsonNodeGetters(dataPrefix: "object.").join("\n")}
        );
  \n""";
}

extension on String {
  String get decodingMethodName => "decode${camelCase()}";

  String get encodingMethodName => "encode${camelCase()}";
}

extension on AbstractType {
  AbstractType normalizeType(List<CustomType> types) {
    final maybeType = types.firstBy((type) => type.className == className);
    if (maybeType != null) {
      return maybeType;
    }

    if (this is ListType) {
      final listType = this as ListType;
      final childType = listType.child.normalizeType(types);
      return listType.nullable
          ? NullableListType(childType)
          : ListType(childType);
    }

    if (this is MapType) {
      final mapType = this as MapType;
      final keyType = mapType.key.normalizeType(types);
      final valueType = mapType.value.normalizeType(types);
      return mapType.nullable
          ? NullableMapType(key: keyType, value: valueType)
          : MapType(key: keyType, value: valueType);
    }

    return this;
  }
}
