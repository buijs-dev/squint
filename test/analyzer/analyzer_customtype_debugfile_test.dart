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

import "package:squint_json/squint_json.dart";
import "package:squint_json/src/analyzer/analyzer.dart" as analyzer;
import "package:test/test.dart";

void main() {
  test("Analyze int", () {
    "int"
        .createResponse
        .executeTest(first: const IntType(), second: const NullableIntType());
  });

  test("Analyze double", () {
    "double".createResponse.executeTest(
        first: const DoubleType(), second: const NullableDoubleType());
  });

  test("Analyze bool", () {
    "bool".createResponse.executeTest(
        first: const BooleanType(), second: const NullableBooleanType());
  });

  test("Analyze String", () {
    "String".createResponse.executeTest(
        first: const StringType(), second: const NullableStringType());
  });

  test("Analyze Uint8List", () {
    "Uint8List".createResponse.executeTest(
        first: const Uint8ListType(), second: const NullableUint8ListType());
  });

  test("Analyze Int32List", () {
    "Int32List".createResponse.executeTest(
        first: const Int32ListType(), second: const NullableInt32ListType());
  });

  test("Analyze Int64List", () {
    "Int64List".createResponse.executeTest(
        first: const Int64ListType(), second: const NullableInt64ListType());
  });

  test("Analyze Float32List", () {
    "Float32List".createResponse.executeTest(
        first: const Float32ListType(),
        second: const NullableFloat32ListType());
  });

  test("Analyze Float64List", () {
    "Float64List".createResponse.executeTest(
        first: const Float64ListType(),
        second: const NullableFloat64ListType());
  });
}

final basePath =
    "${Directory.systemTemp.absolute.path}${Platform.pathSeparator}";

extension on String {
  String get createResponse {
    final file = File("$basePath$this$metadataMarkerPrefix$this.dart")
      ..createSync()
      ..writeAsStringSync(
        """
             {
              "className": "MyResponse",
               "members": [ {
                    "name": "a1", 
                    "type": "$this", 
                    "nullable": false
                  }, 
                  {
                    "name": "a2", 
                    "type": "$this", 
                    "nullable": true
                 } ]
              }""",
      );

    return file.absolute.path;
  }

  bool executeTest({
    required StandardType first,
    required StandardType second,
  }) {
    // when:
    final result = analyzer.analyze(pathToFile: this);

    // then:
    final type = result.parentAsCustomTypeOrFail;
    expect(type!.members.length, 2);
    expect(type.members[0].name, "a1");
    expect(type.members[0].type.toString() == first.toString(), true,
        reason: "First type is not nullable");
    expect(type.members[1].name, "a2");
    expect(type.members[1].type.toString() == second.toString(), true,
        reason: "Second type is nullable");

    return true;
  }
}
