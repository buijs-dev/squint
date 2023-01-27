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

import "../analyzer/analyzer.dart" as analyzer;
import "../ast/ast.dart";
import "../common/common.dart";
import "../converters/converters.dart";
import "../decoder/decoder.dart";
import "../generator/generator.dart";
import "generate_arguments.dart";
import "input.dart";
import "output.dart";

/// Either containing an AnalysisResult or a List of String log messages.
typedef Result = Either<analyzer.AnalysisResult, List<String>?>;

Result _taskFailureJsonNotAnalyzed(File file) =>
    Result.nok(["Failed to analyze .json File: ${file.absolute.path}"]);

Result _taskFailureNotAJsonFile(File file) =>
    Result.nok(["File is not a .json File: ${file.absolute.path}"]);

Result _taskFailureUnknownType(AbstractType type) =>
    Result.nok(["Failed to generate code for type: $type"]);

Result _taskSuccessCustomType(CustomType type) {
  final members = type.members.map((e) => e.type);
  return Result.ok(analyzer.AnalysisResult(
    parent: type,
    childrenEnumTypes: members.whereType<EnumType>().toSet(),
    childrenCustomTypes: members.whereType<CustomType>().toSet(),
  ));
}

Result _taskSuccessEnumType(EnumType type) {
  return Result.ok(analyzer.AnalysisResult(
    parent: null,
    childrenEnumTypes: {type},
    childrenCustomTypes: {},
  ));
}

/// Generate a dataclass for the given [GenerateArgs].
///
/// Input is expected to contain all necessary arguments.
///
/// {@category generator}
extension GenerateDataClass on Map<GenerateArgs, dynamic> {
  /// Generate a dataclass.
  ///
  /// {@category generator}
  Result get dataclass {
    /// Get a valid input File.
    final inputFileOrResult = _inputFileOrResult;

    if (!inputFileOrResult.isOk) {
      return inputFileOrResult.nok!;
    }

    final inputFile = inputFileOrResult.ok!;

    /// Get the CustomType by analyzing the input File.
    final customTypeOrEnumType = inputFile.determineTypeOrNull;

    if (customTypeOrEnumType == null) {
      return _taskFailureJsonNotAnalyzed(inputFile);
    }

    /// Get a valid output File.
    final outputFileOrResult = outputFile(
      filename: "${inputFile.toClassName.snakeCase}_dataclass.dart",
      currentFolder: Directory.current,
    );

    if (!outputFileOrResult.isOk) {
      return Result.nok(outputFileOrResult.nok);
    }

    /// Generate the data class based on the CustomType.
    if (customTypeOrEnumType is CustomType) {
      final options = _optionsWithOverrides;
      final content =
          customTypeOrEnumType.generateDataClassFile(options: options);
      outputFileOrResult.ok!.writeAsStringSync(content);
      return _taskSuccessCustomType(customTypeOrEnumType);
    }

    /// Generate the enum class based on the EnumType
    if (customTypeOrEnumType is EnumType) {
      final options = _optionsWithOverrides;
      final content =
          customTypeOrEnumType.generateEnumClassFile(options: options);
      outputFileOrResult.ok!.writeAsStringSync(content);
      return _taskSuccessEnumType(customTypeOrEnumType);
    }

    return _taskFailureUnknownType(customTypeOrEnumType);
  }

  /// Return [File] input if:
  /// - it exists
  /// - has .json extension
  ///
  /// Or Result.nok with log output.
  Either<File, Result> get _inputFileOrResult {
    final inputFileOrLog = inputFile;

    if (!inputFileOrLog.isOk) {
      return Either.nok(Result.nok(inputFileOrLog.nok));
    }

    final file = inputFileOrLog.ok!;

    if (!file.path.toLowerCase().endsWith(".json")) {
      return Either.nok(
        _taskFailureNotAJsonFile(file),
      );
    }

    return Either.ok(file);
  }

  /// Get instance of [standardSquintGeneratorOptions] and override
  /// values retrieved from command-line input.
  SquintGeneratorOptions get _optionsWithOverrides =>
      standardSquintGeneratorOptions.copyWith(
        includeJsonAnnotations:
            this[GenerateArgs.includeJsonAnnotations] as bool,
        alwaysAddJsonValue: this[GenerateArgs.alwaysAddJsonValue] as bool,
        blankLineBetweenFields:
            this[GenerateArgs.blankLineBetweenFields] as bool,
      );
}

extension on File {
  /// Analyse the File as JSON and return the CustomType
  /// or null if failed to.
  AbstractType? get determineTypeOrNull {
    if (path.contains(analyzer.metadataMarkerPrefix)) {
      final metadata = parseMetadata;
      final parent = metadata.parent;
      if (parent != null) {
        return parent;
      }

      final enumerations = metadata.childrenEnumTypes;
      if (enumerations.isNotEmpty) {
        return enumerations.first;
      }

      return null;
    }

    final content = readAsStringSync().trim();

    if (content.startsWith("{") && content.endsWith("}")) {
      return content.jsonDecode.toCustomType(className: toClassName);
    }

    return null;
  }

  /// Return a String className based on the filename.
  String get toClassName {
    if (path.contains("/") || path.contains(r"\")) {
      final filename = path.replaceAll(parent.path, "");
      return filename
          .substring(1, filename.lastIndexOf("."))
          .removePrefixIfPresent(analyzer.metadataMarkerPrefix)
          .camelCase();
    }

    return path
        .substring(0, path.lastIndexOf("."))
        .removePrefixIfPresent(analyzer.metadataMarkerPrefix)
        .camelCase();
  }
}
