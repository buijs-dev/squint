// ignore_for_file: avoid_dynamic_calls
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

import "../ast/ast.dart";
import "../common/common.dart";
import "../decoder/decoder.dart";
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

/// The analyzer can read files and return metadata about (dart) classes.
///
/// Metadata can be read and written as JSON files.
/// The analyzer supports:
/// 1. Any .dart file containing valid dart classes.
/// 2. Metadata file in AST JSON format.
///
/// {@category analyzer}
List<AbstractType> analyze({
  /// File to be analyzed.
  ///
  /// Must be a valid .dart file containing 1 or more classes
  /// or a metadata JSON file.
  required String pathToFile,

  /// Folder to store analysis result as JSON.
  ///
  /// For each data class a new file is created in this folder.
  String? pathToOutputFolder,
}) {
  final file = File(pathToFile);

  if (!file.existsSync()) {
    throw SquintException("File does not exist: $pathToFile");
  }

  final types = pathToFile.contains(metadataMarkerPrefix)
      ? [file.parseMetadata]
      : file.parseDataClass;

  if (pathToOutputFolder != null) {
    if (!Directory(pathToOutputFolder).existsSync()) {
      throw SquintException("Folder does not exist: $pathToOutputFolder");
    }

    types.saveAsJson(pathToOutputFolder);
  }

  return types;
}

/// {@category analyzer}
extension on File {
  /// Use [JsonVisitor] to collect Metadata from dart class.
  List<CustomType> get parseDataClass {
    final visitor = JsonVisitor();
    parseFile(
      path: absolute.path,
      featureSet: FeatureSet.latestLanguageVersion(),
    ).unit.declarations.accept(visitor);
    return visitor.collected;
  }

  /// JSON decode current file and return [CustomType].
  ///
  /// The JSON is expected to contain metadata for a single data class.
  CustomType get parseMetadata {
    final json = readAsStringSync().jsonDecode;

    final className = json.string("className").data;

    final dynamic data = json.array<dynamic>("members").data;

    final members = <TypeMember>[];

    for (final object in data) {
      final name = object["name"] as String;
      final type = object["type"] as String;
      final nullable = object["nullable"] as bool;

      members.add(
        TypeMember(
          name: name,
          type: type.toAbstractType(nullable: nullable),
        ),
      );
    }

    return CustomType(
      className: className,
      members: members,
    );
  }
}

/// {@category analyzer}
extension on List<AbstractType> {
  void saveAsJson(String pathToOutputFolder) {
    final output = Directory(pathToOutputFolder);
    whereType<CustomType>().forEach((type) {
      output
          .resolve("$metadataMarkerPrefix${type.className.toLowerCase()}.json")
        ..createSync()
        ..writeAsStringSync("""
          {
            "className": "${type.className}",
            "members": [
              ${type.members.map((e) => """
                { 
                  "name": "${e.name}",
                  "type": "${e.type.printType}",
                  "nullable": ${e.type.nullable},
                }
                """).join(",")}
            ]
          }""");
    });
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
