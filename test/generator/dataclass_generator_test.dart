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

import "dart:core";
import "dart:io";
import "package:path/path.dart" as path;

import "package:squint_json/src/cli/const.dart";
import "package:squint_json/src/cli/generate_arguments.dart";
import "package:squint_json/src/cli/generate_dataclass.dart";
import "package:test/test.dart";

void main() {
  test("When the input File does not exist then a Result NOK is returned", () {
    // given:
    final arguments = {
      GenerateArgs.type: generateArgumentTypeValueDataclass,
      GenerateArgs.input: "doesNotExist.json"
    };

    // when:
    final result = arguments.dataclass;
    expect(result.isOk, false);
    expect(result.nok != null, true);
    expect(result.nok!.length, 1);
    expect(result.nok![0].startsWith("File does not exist:"), true);
    expect(result.nok![0].endsWith("doesNotExist.json"), true);
  });

  test(
      "When the input File exists but is not JSON then a Result NOK is returned",
      () {
    // setup:
    final notJsonFile =
        File("${path.current}${Platform.pathSeparator}notJson.txt")
          ..createSync(recursive: true);

    // given:
    final arguments = {
      GenerateArgs.type: generateArgumentTypeValueDataclass,
      GenerateArgs.input: notJsonFile.path,
    };

    // when:
    final result = arguments.dataclass;

    // cleanup:
    notJsonFile.deleteSync();

    // then:
    expect(result.isOk, false);
    expect(result.nok != null, true);
    expect(result.nok!.length, 1);
    expect(result.nok![0].startsWith("File is not a .json File:"), true);
    expect(result.nok![0].endsWith("notJson.txt"), true);
  });

  test(
      "When the input File JSON content is invalid then a Result NOK is returned",
      () {
    // setup:
    final invalidJson =
        File("${path.current}${Platform.pathSeparator}invalid.json")
          ..createSync(recursive: true)
          ..writeAsStringSync("""notJson!""");

    // given:
    final arguments = {
      GenerateArgs.type: generateArgumentTypeValueDataclass,
      GenerateArgs.input: invalidJson.path,
      GenerateArgs.includeJsonAnnotations: true,
      GenerateArgs.alwaysAddJsonValue: true,
      GenerateArgs.blankLineBetweenFields: true,
    };

    // when:
    final result = arguments.dataclass;

    //cleanup:
    invalidJson.deleteSync();

    // then:
    expect(result.isOk, false);
    expect(result.nok != null, true);
    expect(result.nok!.length, 1);
    expect(result.nok![0].startsWith("Failed to analyze .json File:"), true);
    expect(result.nok![0].endsWith("invalid.json"), true);
  });

  test("When the output File already exists then a Result NOK is returned", () {
    // setup:
    final exampleJson = File("someJsonFoo.json")
      ..createSync(recursive: true)
      ..writeAsStringSync("""{"field": "value"}""");

    // setup: output file exists
    final outputFile = File("some_json_foo_dataclass.dart")
      ..createSync(recursive: true);

    // given:
    final arguments = {
      GenerateArgs.type: generateArgumentTypeValueDataclass,
      GenerateArgs.input: exampleJson.path,
      GenerateArgs.includeJsonAnnotations: true,
      GenerateArgs.alwaysAddJsonValue: true,
      GenerateArgs.blankLineBetweenFields: true,
    };

    // when:
    final result = arguments.dataclass;

    // cleanup:
    exampleJson.deleteSync();
    outputFile.deleteSync();

    // then:
    expect(result.isOk, false);
    expect(result.nok != null, true);
    expect(result.nok!.length, 2);
    expect(
        result.nok![0].startsWith(
            "Failed to write generated code because File already exists"),
        true);
    expect(result.nok![0].endsWith("some_json_foo_dataclass.dart."), true);
    expect(result.nok![1],
        "Use '--$generateArgumentOverwrite true' to allow overwriting existing files.");
  });
}
