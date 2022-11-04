import "dart:io";

import "package:analyzer/dart/analysis/features.dart";
import "package:analyzer/dart/analysis/utilities.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/visitor.dart";

import "../../squint.dart";
import "../ast/ast.dart";

///
List<AbstractType> analyze(
  String path,
) {

  if(path.contains("sqdb_")) {

    final customType = File(path).customType;

    if(customType != null) {
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
    if(!node.metadata.any((annotation) => annotation.name.name == "squint")) {
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

    if(rawType == null) {
      throw SquintException("Unable to determine rawType: $type");
    }

    final name = variable?.variables.toList().first.name.toString();

    if(name == null) {
      throw SquintException("Unable to determine variable name: $variable");
    }

    return TypeMember(
        name: name,
        type: rawType.abstractType(),
    );
  }

}
