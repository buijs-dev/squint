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

import "../common/common.dart";
import "shared.dart";

/// Either containing parsed arguments as Map<GenerateArgs, dynamic>
/// or a List of String log messages.
typedef Result = Either<Map<AnalyzeArgs, dynamic>, List<String>>;

Result _argumentFailureMissingValue(String argument) => Result.nok(
      _logAnalyzerExamples() +
          ["", "No value given for parameter: '$argument'"],
    );

Result _argumentFailureUnknown(String argument) => Result.nok(
      _logAnalyzerExamples() + ["", "Invalid parameter: '$argument'"],
    );

Either<bool, List<String>> _argumentFailureNotABooleanValue(String argument) =>
    Either.nok(_logAnalyzerExamples() +
        ["Expected a bool value but found: '$argument'"]);

/// Arguments for the analyzer command-line task.
enum AnalyzeArgs {
  /// Input file to be analyzed.
  input,

  /// Output folder where to store the result.
  output,

  /// Indicator if existing analysis results may be overwritten.
  overwrite
}

/// Command-line arguments utilties.
extension ArgumentSplitter on List<String> {
  /// Return Map containing [AnalyzeArgs] and their value (if any).
  Result get analyzerArguments {
    final arguments = <AnalyzeArgs, dynamic>{
      // Optional argument so set to false as default.
      AnalyzeArgs.overwrite: false,
    };

    var index = 0;

    for (final value in this) {
      index += 1;
      if (value.startsWith("--")) {
        if (length < index) {
          return _argumentFailureMissingValue(value);
        }

        switch (value.lowercase) {
          case "input":
            arguments[AnalyzeArgs.input] = this[index];
            break;
          case "output":
            arguments[AnalyzeArgs.output] = this[index];
            break;
          case "overwrite":
            final boolOrNot = _boolOrFail(index);

            if (!boolOrNot.isOk) {
              return Result.nok(boolOrNot.nok!);
            }

            arguments[AnalyzeArgs.overwrite] = boolOrNot.ok;
            break;
          default:
            return _argumentFailureUnknown(value);
        }
      }
    }

    return Result.ok(arguments);
  }

  /// Return bool or null if value is not a bool (or String) bool.
  Either<bool, List<String>> _boolOrFail(int index) {
    final boolOrNull = this[index].asBoolOrNull;

    if (boolOrNull == null) {
      return _argumentFailureNotABooleanValue(this[index]);
    }

    return Either.ok(boolOrNull);
  }
}

List<String> _logAnalyzerExamples() => [
      "Task 'analyze' requires 2 parameters.",
      "Specify input file with --input.",
      "Specify output folder with --output.",
      "",
      "Example command: ",
      "flutter pub run squint_json:analyze --input foo/bar.dart --output foo/output",
    ];
