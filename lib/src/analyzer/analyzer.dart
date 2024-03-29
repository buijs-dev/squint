// ignore_for_file: avoid_dynamic_calls
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

import "dart:io";

import "package:analyzer/dart/analysis/features.dart";
import "package:analyzer/dart/analysis/utilities.dart";

import "../ast/ast.dart";
import "../common/common.dart";
import "../decoder/decoder.dart";
import "../generator/shared.dart";
import "visitor.dart";

/// Marker prefix used for metadata debug files.
///
/// Example:
///
/// Storing analysis result of a data class named 'SimpleResponse'
/// will be stored in metadata file named: 'sqdb_simpleresponse.json'
///
/// {@category analyzer}
const metadataMarkerPrefix = "sqdb_";

final _importRegex = RegExp(r"""import\s+?("|')(.+?)("|')\s*;""");

/// Result returned after analysing a File [analyze].
class AnalysisResult {
  /// Construct a new [AnalysisResult].
  const AnalysisResult({
    required this.parent,
    this.childrenCustomTypes = const {},
    this.childrenEnumTypes = const {},
  });

  /// Main [CustomType] or [EnumType].
  final AbstractType? parent;

  /// All [CustomType] members.
  final Set<CustomType> childrenCustomTypes;

  /// All [EnumType] members.
  final Set<EnumType> childrenEnumTypes;

  /// Get the parent as [CustomType].
  CustomType get parentAsCustomTypeOrFail => parent! as CustomType;

  /// Get the parent as [EnumType].
  EnumType get parentAsEnumTypeOrFail => parent! as EnumType;

  @override
  String toString() =>
      "AnalysisResult for parent: $parent. CustomType children: $childrenCustomTypes. EnumType children: $childrenEnumTypes";
}

/// The analyzer can read files and return metadata about (dart) classes.
///
/// Metadata can be read and written as JSON files.
/// The analyzer supports:
/// 1. Any .dart file containing valid dart classes.
/// 2. Metadata file in AST JSON format.
///
/// {@category analyzer}
AnalysisResult analyze({
  /// File to be analyzed.
  ///
  /// Must be a valid .dart file containing 1 or more classes
  /// or a metadata JSON file.
  String? pathToFile,

  /// Content of file to be analysed.
  String? fileContent,

  /// Folder to store analysis result as JSON.
  ///
  /// For each data class a new file is created in this folder.
  String? pathToOutputFolder,

  /// Allow overwriting existing output files or not.
  bool overwrite = true,
}) {
  File? file;

  if (pathToFile != null) {
    file = File(pathToFile);
  }

  if (fileContent != null) {
    file = Directory.systemTemp.resolve("squinttempfile.dart")
      ..createSync()
      ..writeAsStringSync(fileContent);
  }

  if (!(file?.existsSync() ?? false)) {
    throw SquintException("File does not exist: ${file?.path ?? ''}");
  }

  final result = file!.path.contains(metadataMarkerPrefix)
      ? file.parseMetadata
      : file.parseDataClass;

  if (pathToOutputFolder != null) {
    if (!Directory(pathToOutputFolder).existsSync()) {
      throw SquintException("Folder does not exist: $pathToOutputFolder");
    }

    result.saveAsJson(pathToOutputFolder, overwrite: overwrite);
  }

  return result;
}

/// {@category analyzer}
extension FileAnalyzer on File {
  /// Use [JsonVisitor] to collect Metadata from dart class.
  AnalysisResult get parseDataClass {
    final visitor = JsonVisitor();
    if (!_visitFile(visitor)) {
      return const AnalysisResult(parent: null);
    }

    _importRegex
        .allMatches(readAsStringSync())
        .map((e) => e.group(2))
        .map((directive) =>
            File("${parent.absolute.path}${Platform.pathSeparator}$directive"))
        .where((file) => file.existsSync())
        .toList()
        .forEach((element) => element._visitFile(visitor));

    final types = visitor.collected;
    final parentType = types.removeAt(0);
    final result = AnalysisResult(
        parent: parentType,
        childrenCustomTypes: types.whereType<CustomType>().toSet(),
        childrenEnumTypes: types.whereType<EnumType>().toSet());

    if (parentType is CustomType) {
      return result.normalizeParentTypeMembers;
    } else {
      return result;
    }
  }

  bool _visitFile(JsonVisitor visitor) {
    try {
      parseFile(
        path: absolute.path,
        featureSet: FeatureSet.latestLanguageVersion(),
      ).unit.declarations.accept(visitor);
      return true;
      // ignore: avoid_catching_errors
    } catch (error) {
      error.toString().log();
      return false;
    }
  }

  /// JSON decode current file and return [CustomType].
  ///
  /// The JSON is expected to contain metadata for a single data class.
  AnalysisResult get parseMetadata {
    final enumTypes = <EnumType>[];
    final customTypes = <CustomType>[];
    final json = readAsStringSync().jsonDecode;
    final className = json.stringNode("className").data;

    if (json.hasKey("members")) {
      final data = json.arrayOrNull<dynamic>("members");
      if (data != null) {
        final members = <TypeMember>[];

        for (final object in data) {
          final name = object["name"] as String;
          final type = object["type"] as String;
          final nullable = object["nullable"] as bool;

          final memberType = type.toAbstractType(nullable: nullable);

          if (memberType is CustomType || memberType is EnumType) {
            final debugFile = parent.resolve(
                "$metadataMarkerPrefix${memberType.className.toLowerCase()}.json");
            if (debugFile.existsSync()) {
              final result = debugFile.parseMetadata;
              final parentOrNull = result.parent;
              if (parentOrNull is CustomType) {
                customTypes.add(parentOrNull);
              }
              if (parentOrNull is EnumType) {
                enumTypes.add(parentOrNull);
              }
              customTypes.addAll(result.childrenCustomTypes);
              enumTypes.addAll(result.childrenEnumTypes);
            } else {
              "Found ${memberType.runtimeType} but no source (Does not exist: ${debugFile.path})"
                  .log();
            }
          }

          members.add(
            TypeMember(
              name: name,
              type: memberType,
            ),
          );
        }

        return AnalysisResult(
          parent: CustomType(
            className: className,
            members: members,
          ),
          childrenCustomTypes: customTypes.toSet(),
          childrenEnumTypes: enumTypes.toSet(),
        ).normalizeParentTypeMembers;
      }
    }

    if (json.hasKey("values")) {
      final values = json.arrayOrNull<String>("values") ?? [];
      final valuesJSON = json.hasKey("valuesJSON")
          ? json.arrayOrNull<String>("valuesJSON") ?? <String>[]
          : <String>[];

      final enumType = EnumType(
        className: className,
        values: values,
        valuesJSON: valuesJSON,
      );

      enumTypes.add(enumType);
      return AnalysisResult(
        parent: null,
        childrenCustomTypes: customTypes.toSet(),
        childrenEnumTypes: enumTypes.toSet(),
      );
    }

    "Example of CustomType metadata JSON file:".log(context: """
    {
    "className": "MyResponse",
    "members": [ 
      {
          "name": "a1",
          "type": "int",
          "nullable": false
      },
      {
            "name": "a2",
            "type": "String",
            "nullable": true
      } 
    ]
  }""");
    "Example of EnumType metadata JSON file:".log(context: """
    {
        "className": "MyResponse",
        "values": [ 
          "FOO", 
          "BAR"
        ],
        "valuesJSON": [ 
          "foo", 
          "bar"
        ],
      }""");

    throw SquintException("Unable to parse metadata file.");
  }
}

/// {@category analyzer}
extension on AnalysisResult {
  void saveAsJson(String pathToOutputFolder, {required bool overwrite}) {
    final output = Directory(pathToOutputFolder);
    final customTypes = <CustomType>{}..addAll(childrenCustomTypes);
    if (parent is CustomType) {
      customTypes.add(parent! as CustomType);
    }
    for (final type in customTypes) {
      final file = output
          .resolve("$metadataMarkerPrefix${type.className.toLowerCase()}.json");

      if (file.existsSync() && !overwrite) {
        "Unable to store analysis result.".log();
        "File already exists: ${file.absolute.path}.".log();
        "To allow overwriting files use --overwrite true.".log();
      }

      file
        ..createSync()
        ..writeAsStringSync("""
{
  "className": "${type.className}",
  "members": [
    ${type.members.map((e) => """
      { 
        "name": "${e.name}",
        "type": "${e.type.printType}",
        "nullable": ${e.type.nullable}
      }
      """).join(",")}
  ]
}""");
    }

    for (final type in childrenEnumTypes) {
      final file = output
          .resolve("$metadataMarkerPrefix${type.className.toLowerCase()}.json");

      if (file.existsSync() && !overwrite) {
        "Unable to store analysis result.".log();
        "File already exists: ${file.absolute.path}.".log();
        "To allow overwriting files use --overwrite true.".log();
      }

      file
        ..createSync()
        ..writeAsStringSync("""
{
  "className": "${type.className}",
  "values": ${type.values.map((e) => '''"$e"''').toList()},
  "valuesJSON": ${type.valuesJSON.map((e) => '''"$e"''').toList()}
}""");
    }
  }
}

/// {@category analyzer}
extension AbstractTypeSerializer on AbstractType {
  /// Output [AbstractType] as dart code.
  String get printType {
    final q = nullable ? "?" : "";

    if (this is ListType) {
      return "List<${(this as ListType).child.printType}>$q";
    }

    if (this is MapType) {
      final map = this as MapType;
      return "Map<${map.key.printType}, ${map.value.printType}>$q";
    }

    return "$className$q";
  }
}

extension on AnalysisResult {
  AnalysisResult get normalizeParentTypeMembers {
    if (parent == null) {
      return this;
    }

    final parentMembers = parentAsCustomTypeOrFail.members
        .map((member) => member.copyWith(
            type: member.type
                .normalizeType(childrenEnumTypes, childrenCustomTypes)))
        .toList();

    return AnalysisResult(
      parent: CustomType(
        className: parent!.className,
        members: parentMembers,
      ),
      childrenCustomTypes: childrenCustomTypes,
      childrenEnumTypes: childrenEnumTypes,
    );
  }
}
