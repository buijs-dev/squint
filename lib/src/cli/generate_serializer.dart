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
import "package:path/path.dart" as path;
import "../analyzer/analyzer.dart" as analyzer;
import "../ast/ast.dart";
import "../common/common.dart";
import "../generator/generator.dart";
import "generate_arguments.dart";
import "input.dart";
import "output.dart";

/// Either containing an AnalysisResult
/// or a List of String log messages.
typedef Result = Either<analyzer.AnalysisResult, List<String>?>;

Result _taskFailureNotADartFile(File file) =>
    Result.nok(["File is not a .dart File: ${file.absolute.path}"]);

Result _taskFailureClassNotAnalyzed(File file) =>
    Result.nok(["Failed to analyze .dart File: ${file.absolute.path}"]);

/// Generate a serializer extensions.
extension GenerateSerializers on Map<GenerateArgs, dynamic> {
  /// Generate a dataclass.
  Result get serializers {
    /// Get a valid input File.
    final inputFileOrResult = _inputFileOrResult;

    if (!inputFileOrResult.isOk) {
      return inputFileOrResult.nok!;
    }

    final inputFile = inputFileOrResult.ok!;

    /// Get the CustomType by analyzing the input File.
    final analysisResult = inputFile.parseDataClass;

    if (analysisResult.parent == null) {
      return _taskFailureClassNotAnalyzed(inputFile);
    }

    /// Get all CustomTypes (including types of TypeMembers)
    /// which require code generation.
    final customTypes = analysisResult.childrenCustomTypes
      ..add(analysisResult.parent!);

    /// Valid all types and convert to [_CustomTypeData].
    final customTypesData = _toCustomTypeDataList(customTypes);

    /// Get all invalid types and return Result if any present.
    final invalidCustomTypes = customTypesData.invalid;

    if (invalidCustomTypes.isNotEmpty) {
      return Result.nok(invalidCustomTypes);
    }

    /// Generate an extension File for each [_ValidCustomType].
    for (final type in customTypesData) {
      final customType = type as _ValidCustomType;
      final customTypeFile = customType.file;
      final data = type.type;
      final inputPath = inputFile.uri.path;
      final outputPath = customTypeFile.uri.path;
      final import = path
          .relative(inputPath, from: outputPath)
          .removePrefixIfPresent("../");
      final content = data.generateJsonDecodingFile(relativeImport: import);
      customTypeFile.writeAsStringSync(content);
    }

    return Result.ok(analysisResult);
  }

  /// Return [File] input if:
  /// - it exists
  /// - has .dart extension
  ///
  /// Or Result.nok with log output.
  Either<File, Result> get _inputFileOrResult {
    final inputFileOrLog = inputFile;

    if (!inputFileOrLog.isOk) {
      return Either.nok(Result.nok(inputFileOrLog.nok));
    }

    final file = inputFileOrLog.ok!;

    if (!file.path.toLowerCase().endsWith(".dart")) {
      return Either.nok(
        _taskFailureNotADartFile(file),
      );
    }

    return Either.ok(file);
  }

  List<_CustomTypeData> _toCustomTypeDataList(
    Set<CustomType> customTypes,
  ) =>
      customTypes.map((customType) {
        final filename = "${customType.className.snakeCase}_extensions.dart";
        final maybeOutputFile = outputFile(
          filename: filename,
          currentFolder: Directory.current,
        );

        if (!maybeOutputFile.isOk) {
          final log = maybeOutputFile.nok ?? ["Oops something went wrong..."];
          return _InvalidCustomType(log);
        }

        return _ValidCustomType(file: maybeOutputFile.ok!, type: customType);
      }).toList();
}

/// Get List of all [_InvalidCustomType].
extension on List<_CustomTypeData> {
  List<String> get invalid => whereType<_InvalidCustomType>()
      .map((e) => e.logOutput)
      .expand((e) => e)
      .toList();
}

class _InvalidCustomType extends _CustomTypeData {
  /// Construct a new instance of [_InvalidCustomType].
  const _InvalidCustomType(this.logOutput);

  /// List of messages to be outputted to the command-line.
  final List<String> logOutput;
}

class _ValidCustomType extends _CustomTypeData {
  /// Construct a new instance of [_ValidCustomType]
  /// for a [CustomType] which is valid.
  const _ValidCustomType({
    required this.file,
    required this.type,
  });

  /// File to write code to.
  final File file;

  /// [CustomType] for which code to be generated.
  final CustomType type;
}

abstract class _CustomTypeData {
  const _CustomTypeData();
}
