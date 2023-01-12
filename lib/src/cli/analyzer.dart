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

import "../analyzer/analyzer.dart" as analyzer;
import "../ast/ast.dart";
import "../common/common.dart";
import 'shared.dart';

/// Run the analyzer task.
List<AbstractType> runAnalyzerTask(List<String> args) {
  final arguments = args.analyzerArguments;

  return analyzer.analyze(
    pathToFile: arguments[AnalyzerArgs.input] as String,
    pathToOutputFolder: arguments[AnalyzerArgs.output] as String,
    overwrite: arguments[AnalyzerArgs.overwrite] as bool,
  );
}

/// Command-line arguments utilties.
extension ArgumentSplitter on List<String> {
  /// Return Map containing [AnalyzerArgs] and their value (if any).
  Map<AnalyzerArgs, dynamic> get analyzerArguments {
    final arguments = <AnalyzerArgs, dynamic>{
      // Optional argument so set to false as default.
      AnalyzerArgs.overwrite: false,
    };

    var index = 0;

    for (final value in this) {
      index += 1;
      if (value.startsWith("--")) {
        if (length < index) {
          _logAnalyzerExamples();
          throw SquintException("No value given for parameter: '$value'");
        }

        final lowercased = value.substring(2, value.length).toLowerCase();

        switch (lowercased) {
          case "input":
            arguments[AnalyzerArgs.input] = this[index];
            break;
          case "output":
            arguments[AnalyzerArgs.output] = this[index];
            break;
          case "overwrite":
            arguments[AnalyzerArgs.overwrite] = _boolOrThrow(index);
            break;
          default:
            _logAnalyzerExamples();
            throw SquintException("Invalid parameter: '$value'");
        }
      }
    }

    return arguments;
  }

  bool _boolOrThrow(int index) {
    final boolOrNull = this[index].asBoolOrNull;
    if (boolOrNull == null) {
      _logAnalyzerExamples();
      throw SquintException(
          "Expected a bool value but found: '${this[index]}'");
    }
    return boolOrNull;
  }
}

/// Arguments for the analyzer command-line task.
enum AnalyzerArgs {
  /// Input file to be analyzed.
  input,

  /// Output folder where to store the result.
  output,

  /// Indicator if existing analysis results may be overwritten.
  overwrite
}

void _logAnalyzerExamples() {
  "Task 'analyze' requires 2 parameters.".log();
  "Specify input file with --input.".log();
  "Specify output folder with --output.".log();
  "".log();
  "Example command: ".log(
    context:
        "flutter pub run squint:analyze --input foo/bar.dart --output foo/output",
  );
  "".log();
}
