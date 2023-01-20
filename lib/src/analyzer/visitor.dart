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
    show
        ClassDeclaration,
        Declaration,
        EnumDeclaration,
        FieldDeclaration,
        VariableDeclarationList;
import "package:analyzer/dart/ast/syntactic_entity.dart";
import "package:analyzer/dart/ast/visitor.dart";

import "../ast/ast.dart";
import "../common/common.dart";
import "../decoder/decoder.dart";

/// Visit a dart data class and return metadata as [CustomType].
///
/// {@category analyzer}
class JsonVisitor extends SimpleAstVisitor<dynamic> {
  /// List of dart data classes found.
  final collected = <AbstractType>[];

  @override
  dynamic visitClassDeclaration(ClassDeclaration node) {
    if (node.hasSquintAnnotation) {
      return collected..add(node.toCustomType);
    } else {
      return null;
    }
  }

  @override
  dynamic visitEnumDeclaration(EnumDeclaration node) {
    if (node.hasSquintAnnotation) {
      return collected..add(node.toEnumType);
    } else {
      return null;
    }
  }
}

/// {@category analyzer}
extension on Declaration {
  /// Return true if squint annotation is present.
  bool get hasSquintAnnotation => metadata.any((o) => o.name.name == "squint");
}

/// {@category analyzer}
extension on ClassDeclaration {
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

/// {@category analyzer}
extension on EnumDeclaration {
  EnumType get toEnumType {
    final values = <String>[];
    final valuesJSON = <String>[];

    for (final constant in constants) {
      final value = constant.name.lexeme;
      final annotations = constant.childEntities.jsonAnnotations;
      final jsonValueOrNull = annotations.firstBy((t) => t.name == "JsonValue");
      values.add(value);
      valuesJSON.add(jsonValueOrNull?.data["tag"] ?? value);
    }

    return EnumType(
      className: name.toString(),
      values: values,
      valuesJSON: valuesJSON,
    );
  }
}

extension on Iterable<SyntacticEntity> {
  List<TypeAnnotation> get jsonAnnotations {
    final annotations = <TypeAnnotation>[];

    for (final annotation in this) {
      final decode = _JsonDecodeExtractor("$annotation");
      if (decode.hasMatch) {
        annotations.add(decode.annotation);
        continue;
      }

      final encode = _JsonEncodeExtractor("$annotation");
      if (encode.hasMatch) {
        annotations.add(encode.annotation);
        continue;
      }

      final value = _JsonValueExtractor("$annotation");
      if (value.hasMatch) {
        annotations.add(value.annotation);
        continue;
      }
    }

    return annotations;
  }
}

class _JsonValueExtractor extends _AnnotationExtractor {
  _JsonValueExtractor(String annotation)
      : super(
            annotation: annotation,
            regExp: RegExp(r"""^(@JsonValue)\("([^"]+?)"\)"""),
            toAnnotation: (RegExpMatch match) {
              final matches = match.matches;
              final tag = matches[2].trim();
              return TypeAnnotation(
                name: "JsonValue",
                data: {
                  "tag": tag,
                },
              );
            });
}

class _JsonDecodeExtractor extends _AnnotationExtractor {
  _JsonDecodeExtractor(String annotation)
      : super(
            annotation: annotation,
            regExp:
                RegExp(r"""^(@JsonDecode)(<(.+?),(.+?)>)\(using:([^\)]+?)\)"""),
            toAnnotation: (RegExpMatch match) {
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
            });
}

class _JsonEncodeExtractor extends _AnnotationExtractor {
  _JsonEncodeExtractor(String annotation)
      : super(
            annotation: annotation,
            regExp: RegExp(r"""^(@JsonEncode)\(using:([^\)]+?)\)"""),
            toAnnotation: (RegExpMatch match) {
              final matches = match.matches;
              final using = matches[2].trim();
              return TypeAnnotation(
                name: "JsonEncode",
                data: {"using": using},
              );
            });
}

class _AnnotationExtractor {
  _AnnotationExtractor({
    required String annotation,
    required RegExp regExp,
    required this.toAnnotation,
  }) {
    match = regExp.firstMatch(annotation);
  }

  late final RegExpMatch? match;

  late final TypeAnnotation Function(RegExpMatch) toAnnotation;

  bool get hasMatch => match != null;

  TypeAnnotation get annotation => toAnnotation.call(match!);
}
