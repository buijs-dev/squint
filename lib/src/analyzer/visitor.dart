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

import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/visitor.dart";

import "../ast/ast.dart";
import "../common/common.dart";

/// Visit a dart data class and return metadata as [CustomType].
///
/// {@category analyzer}
class JsonVisitor extends SimpleAstVisitor<dynamic> {
  /// List of dart data classes found.
  final collected = <CustomType>[];

  @override
  dynamic visitClassDeclaration(ClassDeclaration node) {
    if (!node.hasSquintAnnotation) {
      return null;
    }

    final className = node.name.toString();

    final members = node.typeMembers;

    final customType = CustomType(
      className: className,
      members: members,
    );

    return collected..add(customType);
  }
}

/// {@category analyzer}
extension on ClassDeclaration {
  /// Return true if squint annotation is present.
  bool get hasSquintAnnotation => metadata.any((o) => o.name.name == "squint");

  /// Convert every [FieldDeclaration] to a [TypeMember].
  List<TypeMember> get typeMembers => members
      .whereType<FieldDeclaration>()
      .map((e) => e.fields)
      .map(_typeMember)
      .toList();

  TypeMember _typeMember(VariableDeclarationList? variable) {
    final type = variable?.type;

    final rawType = type?.toString().trim().orElseThrow(
          SquintException(
            "Unable to determine rawType: $type",
          ),
        );

    final name = variable?.variables.toList().first.name.toString().orElseThrow(
          SquintException(
            "Unable to determine variable name: $variable",
          ),
        );

    return TypeMember(
      name: name!,
      type: rawType!.abstractType(),
    );
  }
}
