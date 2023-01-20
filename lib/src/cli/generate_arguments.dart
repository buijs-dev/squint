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
import "../generator/generator.dart";
import "const.dart";
import "shared.dart";

const _options = standardSquintGeneratorOptions;

/// Either containing parsed arguments as Map<GenerateArgs, dynamic>
/// or a List of String log messages.
typedef Result = Either<Map<GenerateArgs, dynamic>, List<String>>;

Result _argumentFailureMissingValue(String argument) => Result.nok(
      _logGeneratorExamples() +
          ["", "No value given for parameter: '$argument'"],
    );

Result _argumentFailureUnknown(String argument) => Result.nok(
      _logGeneratorExamples() + ["", "Invalid parameter: '$argument'"],
    );

Either<bool, List<String>> _argumentFailureNotABooleanValue(String argument) =>
    Either.nok(_logGeneratorExamples() +
        ["Expected a bool value but found: '$argument'"]);

/// Arguments for the generate command-line task.
enum GenerateArgs {
  /// What type of code to be generated.
  type,

  /// Input file to be analyzed.
  input,

  /// Output folder where to store the result.
  output,

  /// Indicator if existing analysis results may be overwritten.
  overwrite,

  /// Configure to add a blank line between dataclass fields or not.
  blankLineBetweenFields,

  /// Configure to always add @JsonValue to dataclass fields or not.
  alwaysAddJsonValue,

  /// Configure to include annotations or not.
  includeJsonAnnotations,
}

/// Helper to parse Command-line arguments for the generate Task.
extension ArgumentSplitter on List<String> {
  /// Return Map containing [GenerateArgs] and their value (if any).
  Result get generateArguments {
    final arguments = <GenerateArgs, dynamic>{
      GenerateArgs.overwrite: false,
      GenerateArgs.blankLineBetweenFields: _options.blankLineBetweenFields,
      GenerateArgs.alwaysAddJsonValue: _options.alwaysAddJsonValue,
      GenerateArgs.includeJsonAnnotations: _options.includeJsonAnnotations,
    };

    var index = 0;

    for (final value in this) {
      index += 1;
      if (value.startsWith("--")) {
        if (length < index) {
          return _argumentFailureMissingValue(value);
        }

        switch (value.lowercase) {
          case "type":
            arguments[GenerateArgs.type] = this[index];
            break;
          case "input":
            arguments[GenerateArgs.input] = this[index];
            break;
          case "output":
            arguments[GenerateArgs.output] = this[index];
            break;
          case "overwrite":
            final boolOrNot = _boolOrFail(index);

            if (!boolOrNot.isOk) {
              return Result.nok(boolOrNot.nok!);
            }

            arguments[GenerateArgs.overwrite] = boolOrNot.ok;
            break;
          case "blanklinebetweenfields":
            final boolOrNot = _boolOrFail(index);

            if (!boolOrNot.isOk) {
              return Result.nok(boolOrNot.nok!);
            }

            arguments[GenerateArgs.blankLineBetweenFields] = boolOrNot.ok;
            break;
          case "alwaysaddjsonvalue":
            final boolOrNot = _boolOrFail(index);

            if (!boolOrNot.isOk) {
              return Result.nok(boolOrNot.nok!);
            }

            arguments[GenerateArgs.alwaysAddJsonValue] = boolOrNot.ok;
            break;
          case "includejsonannotations":
            final boolOrNot = _boolOrFail(index);

            if (!boolOrNot.isOk) {
              return Result.nok(boolOrNot.nok!);
            }

            arguments[GenerateArgs.includeJsonAnnotations] = boolOrNot.ok;
            break;
          default:
            return _argumentFailureUnknown(value);
        }
      }
    }

    return Result.ok(arguments);
  }

  Either<bool, List<String>> _boolOrFail(int index) {
    final boolOrNull = this[index].asBoolOrNull;

    if (boolOrNull == null) {
      return _argumentFailureNotABooleanValue(this[index]);
    }

    return Either.ok(boolOrNull);
  }
}

List<String> _logGeneratorExamples() => [
      "Task '$generateTaskName' requires 2 parameters.",
      "Specify what to be generated with --$generateArgumentType (possible values: $generateArgumentTypeValueDataclass or $generateArgumentTypeValueSerializer).",
      "Specify input file with --$generateArgumentInput.",
      "Optional parameters are",
      "--$generateArgumentOutput (folder to write generated code which defaults to current folder)",
      "Example: flutter pub run $libName:$generateTaskName --$generateArgumentType $generateArgumentTypeValueDataclass --$generateArgumentInput foo/bar/message.json --$generateArgumentOutput foo/bar/gen",
      "",
      "For $generateArgumentTypeValueDataclass only:",
      "--$generateArgumentAlwaysAddJsonValue (include @JsonValue annotation on all fields)",
      "Example: flutter pub run $libName:$generateTaskName --$generateArgumentType $generateArgumentTypeValueDataclass --$generateArgumentInput foo/bar/message.json --$generateArgumentAlwaysAddJsonValue  true",
      "--$generateArgumentIncludeJsonAnnotations (add annotations or not)",
      "Example: flutter pub run $libName:$generateTaskName --$generateArgumentType $generateArgumentTypeValueDataclass --$generateArgumentInput foo/bar/message.json --$generateArgumentIncludeJsonAnnotations false",
      "--$generateArgumentBlankLineBetweenFields (add blank line between dataclass fields or not)",
      " Example: flutter pub run $libName:$generateTaskName --$generateArgumentType $generateArgumentTypeValueDataclass --$generateArgumentInput foo/bar/message.json --$generateArgumentBlankLineBetweenFields true",
    ];
