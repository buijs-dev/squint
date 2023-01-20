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
import "../common/common.dart";
import "const.dart";
import "generate_arguments.dart";
import "generate_dataclass.dart";
import "generate_serializer.dart";

/// Either containing an AnalysisResult
/// or a List of String log messages.
typedef Result = Either<analyzer.AnalysisResult, List<String>?>;

/// Run the analyzer task.
Result runGenerateTask(List<String> args) {
  final argumentsOrLog = args.generateArguments;

  if (!argumentsOrLog.isOk) {
    return Result.nok(argumentsOrLog.nok);
  }

  final arguments = argumentsOrLog.ok!;

  if (!arguments.containsKey(GenerateArgs.type)) {
    return Result.nok([
      "Missing argument '$generateArgumentType'.",
      "Specify what code to be generated with --$generateArgumentInput.",
      "Example to generate dataclass from JSON file: ",
      "flutter pub run $libName:$generateTaskName --$generateArgumentType $generateArgumentTypeValueDataclass --$generateArgumentInput message.json",
      "Example to generate serializer extensions for dart class: ",
      "flutter pub run $libName:$generateTaskName --$generateArgumentType $generateArgumentTypeValueSerializer --$generateArgumentInput foo.dart",
    ]);
  }

  final toBeGenerated = arguments[GenerateArgs.type] as String;

  if (toBeGenerated == generateArgumentTypeValueDataclass) {
    final dataclassOrLog = arguments.dataclass;
    if (!dataclassOrLog.isOk) {
      return Result.nok(dataclassOrLog.nok);
    } else {
      return Result.ok(dataclassOrLog.ok!);
    }
  }

  if (toBeGenerated == generateArgumentTypeValueSerializer) {
    final serializerOrLog = arguments.serializers;
    if (!serializerOrLog.isOk) {
      return Result.nok(serializerOrLog.nok);
    } else {
      return Result.ok(serializerOrLog.ok!);
    }
  }

  return Result.nok([
    "Invalid value for argument --$generateArgumentType: '$toBeGenerated'",
    "Possible values are:",
    "- $generateArgumentTypeValueDataclass (generate dataclass from JSON)",
    "- $generateArgumentTypeValueSerializer (generate serializer extensions for dart class)",
  ]);
}
