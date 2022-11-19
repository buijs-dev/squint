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

import "dart:io";

import "package:analyzer/dart/analysis/features.dart";
import "package:analyzer/dart/analysis/utilities.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/visitor.dart";

import "../../squint.dart";
import "../ast/ast.dart";
import "../common/common.dart";

///
List<AbstractType> analyze(
  String path,
) {
  if (path.contains("sqdb_")) {
    final customType = File(path).customType;

    if (customType != null) {
      return [customType];
    } else {
      return [];
    }
  }

  final result = parseFile(
    path: path,
    featureSet: FeatureSet.latestLanguageVersion(),
  );

  final declarations = result.unit.declarations;

  if (declarations.isEmpty) {
    return [];
  }

  final visitor = _JsonVisitor();
  declarations.accept(visitor);
  return visitor.collected;
}

/// Visit a class
class _JsonVisitor extends SimpleAstVisitor<dynamic> {
  final collected = <AbstractType>[];

  @override
  dynamic visitClassDeclaration(ClassDeclaration node) {
    if (!node.metadata.any((annotation) => annotation.name.name == "squint")) {
      return null;
    }

    final className = node.name.toString();

    final members = node.members
        .whereType<FieldDeclaration>()
        .map((e) => e.fields)
        .map(typeMember)
        .toList();

    final customType = CustomType(
      className: className,
      members: members,
    );

    collected.add(customType);
    return collected;
  }

  TypeMember typeMember(VariableDeclarationList? variable) {
    final type = variable?.type;
    final rawType = type?.toString().trim();

    if (rawType == null) {
      throw SquintException("Unable to determine rawType: $type");
    }

    final name = variable?.variables.toList().first.name.toString();

    if (name == null) {
      throw SquintException("Unable to determine variable name: $variable");
    }

    return TypeMember(
      name: name,
      type: rawType.abstractType(),
    );
  }
}
