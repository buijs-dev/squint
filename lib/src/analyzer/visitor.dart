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

import "package:analyzer/dart/ast/ast.dart"
    show ClassDeclaration, FieldDeclaration, VariableDeclarationList;
import "package:analyzer/dart/ast/syntactic_entity.dart";
import "package:analyzer/dart/ast/visitor.dart";

import "../ast/ast.dart";
import "../common/common.dart";
import "../decoder/decoder.dart";

/// Regex to find @JsonDecode annotation.
final _jsonDecodeRegex = RegExp(
  r"""^(@JsonDecode)(<(.+?),(.+?)>)\(using:([^\)]+?)\)""",
);

/// Regex to find @JsonEncode annotation.
final _jsonEncoderRegex = RegExp(
  r"""^(@JsonEncode)\(using:([^\)]+?)\)""",
);

/// Regex to find @JsonValue annotation.
final _jsonValueRegex = RegExp(
  r"""^(@JsonValue)\("([^"]+?)"\)""",
);

/// Visit a dart data class and return metadata as [CustomType].
///
/// {@category analyzer}
class JsonVisitor extends SimpleAstVisitor<dynamic> {
  /// List of dart data classes found.
  final collected = <CustomType>[];

  @override
  dynamic visitClassDeclaration(ClassDeclaration node) {
    if (node.hasSquintAnnotation) {
      return collected..add(node.toCustomType);
    } else {
      return null;
    }
  }
}

/// {@category analyzer}
extension on ClassDeclaration {
  /// Return true if squint annotation is present.
  bool get hasSquintAnnotation => metadata.any((o) => o.name.name == "squint");

  CustomType get toCustomType => CustomType(
        className: name.toString(),
        members: members
            .whereType<FieldDeclaration>()
            .map((e) => e.fields)
            .whereType<VariableDeclarationList>()
            .map(_typeMember)
            .toList(),
      );

  TypeMember _typeMember(VariableDeclarationList variable) {
    final abstractType = variable.type?.toString().trim().toAbstractType();
    if (abstractType == null) {
      SquintException("Unable to determine rawType: ${variable.type}");
    }
    final name = variable.variables.toList().first.name.toString();
    final annotations = variable.parent?.childEntities.jsonAnnotations;
    return TypeMember(
      name: name,
      type: abstractType!,
      annotations: annotations ?? [],
    );
  }
}

extension on Iterable<SyntacticEntity> {
  List<TypeAnnotation> get jsonAnnotations {
    final annotations = <TypeAnnotation>[];

    for (final annotation in this) {
      final jsonDecoderRegexMatch = // Check for @JsonDecode annotation.
          _jsonDecodeRegex.firstMatch("$annotation");
      if (jsonDecoderRegexMatch != null) {
        annotations.add(_jsonDecoder(jsonDecoderRegexMatch));
        continue;
      }

      final jsonEncoderRegexMatch = // Check for @JsonEncode annotation.
          _jsonEncoderRegex.firstMatch("$annotation");
      if (jsonEncoderRegexMatch != null) {
        annotations.add(_jsonEncoder(jsonEncoderRegexMatch));
        continue;
      }

      final jsonValueRegexMatch = // Check for @JsonValue annotation.
          _jsonValueRegex.firstMatch("$annotation");
      if (jsonValueRegexMatch != null) {
        annotations.add(_jsonValue(jsonValueRegexMatch));
      }
    }

    return annotations;
  }
}

TypeAnnotation _jsonDecoder(RegExpMatch match) {
  final matches = match.matches;
  final jsonElement = matches[4].trim();
  final using = matches[5].trim();
  return TypeAnnotation(
    name: "JsonDecode",
    data: {
      "using": using,
      "jsonElement": jsonElement,
    },
  );
}

TypeAnnotation _jsonEncoder(RegExpMatch match) {
  final matches = match.matches;
  final using = matches[2].trim();
  return TypeAnnotation(
    name: "JsonEncode",
    data: {"using": using},
  );
}

TypeAnnotation _jsonValue(RegExpMatch match) {
  final matches = match.matches;
  final tag = matches[2].trim();
  return TypeAnnotation(
    name: "JsonValue",
    data: {"tag": tag},
  );
}
