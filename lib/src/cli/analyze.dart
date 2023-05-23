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

import "../analyzer/analyzer.dart" as analyzer;
import "../common/common.dart";
import "analyze_arguments.dart";

/// Either containing an AnalysisResult
/// or a List of String log messages.
typedef Result = Either<analyzer.AnalysisResult, List<String>?>;

/// Run the analyzer task.
Result runAnalyzerTask(List<String> args) {
  final argumentsOrLog = args.analyzerArguments;

  if (!argumentsOrLog.isOk) {
    return Result.nok(argumentsOrLog.nok);
  }

  final arguments = argumentsOrLog.ok!;

  /// Get path to File to be analyzed which should always be present.
  ///
  /// If [AnalyzeArgs.input] is not present then extension
  /// [.analyzerArguments] should return Result.NOK.
  final pathToFile = arguments[AnalyzeArgs.input] as String;

  /// Get path to output folder if given.
  ///
  /// Optional argument which may not be set.
  final outputArgument = arguments[AnalyzeArgs.output] as String?;

  /// Get path to current folder where output should
  /// be placed if [AnalyzeArgs.output] is not set.
  final pathToCurrentFolder = Directory.current.absolute.path;

  /// Set path to output folder to given folder or default to current.
  final pathToOutputFolder = outputArgument ?? pathToCurrentFolder;

  /// Get overwrite argument.
  ///
  /// If set to false (default) then analyzer will not write
  /// it's output if a File already exists.
  final overwrite = arguments[AnalyzeArgs.overwrite] as bool;

  /// Execute te actual analysis.
  final analysisResult = analyzer.analyze(
    pathToFile: pathToFile,
    pathToOutputFolder: pathToOutputFolder,
    overwrite: overwrite,
  );

  return Result.ok(analysisResult);
}
