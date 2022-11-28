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

import "package:squint/src/analyzer/analyzer.dart" as analyzer;
import "package:squint/src/analyzer/analyzer.dart";
import "package:squint/src/ast/ast.dart";
import "package:squint/src/common/common.dart";
import "package:test/test.dart";

import "analyzer_classfile_test.dart";

void main() {

  test("Analyze dart class, store as JSON metadata, analyze metadata", () {
    // given:
    final output = Directory("${basePath}analyzertest")
      ..createSync();

    // and:
    final file = File("${basePath}map_response.dart")
      ..createSync()
      ..writeAsStringSync(
        """
          @squint
          class SimpleResponse {
            ///
            SimpleResponse({
                required this.a1,
                required this.a2,
                required this.a3,
                required this.a4,
                required this.a5,
                required this.a6,
                required this.b1,
                required this.b2,
                required this.b3,
            });
        
            final Map<String, double>   a1;
            final Map<String, double>?  a2;
            final Map<String, double?>  a3;
            final Map<String, double?>? a4;
            final Map<String, Map<String, double>> a5;
            final List<String> b1;
            final List<String?> b2;
            final List<String>? b3;
          }""",
      );

    // expect:
    analyzer.analyze(
        pathToFile: file.absolute.path,
        pathToOutputFolder: output.absolute.path,
    )._expect();

    // and:
    analyzer.analyze(
      pathToFile: output.resolve("${metadataMarkerPrefix}simpleresponse.json").absolute.path,
    )._expect();

  });

  test("If input file does not exist then an exception is thrown", () {
    expect(() =>  analyzer.analyze(pathToFile: "doesnotexist"),
        throwsA(predicate((e) =>
        e is SquintException &&
            e.cause.startsWith("File does not exist:") &&
            e.cause.endsWith("doesnotexist")
        )));
  });

  test("If output folder does not exist then an exception is thrown", () {
    final file = File("${basePath}map_response.dart")
      ..createSync();

    expect(() =>  analyzer.analyze(pathToFile: file.absolute.path, pathToOutputFolder: "doesnotexist"),
        throwsA(predicate((e) =>
        e is SquintException &&
            e.cause.startsWith("Folder does not exist:") &&
            e.cause.endsWith("doesnotexist")
        )));
  });

}

extension on List<AbstractType> {

  void _expect() {
    expect(length, 1, reason: "Should have found 1 type");

    final type = first;
    expect(type is CustomType, true,
        reason: "An user created model is always a CustomType");

    final customType = type as CustomType;
    expect(customType.members.length, 8);

    // Map<String, double>
    expect(customType.members[0].name, "a1");
    expect(customType.members[0].type is MapType, true,
        reason: "First type is Map");
    expect((customType.members[0].type as MapType).key is StringType, true,
        reason: "First type key is String");
    expect((customType.members[0].type as MapType).value is DoubleType, true,
        reason: "First type value is double");

    // Map<String, double>?
    expect(customType.members[1].name, "a2");
    expect(customType.members[1].type is NullableMapType, true,
        reason: "Second type is a nullable Map");
    expect(
        (customType.members[1].type as NullableMapType).key is StringType, true,
        reason: "Second type key is String");
    expect((customType.members[1].type as NullableMapType).value is DoubleType,
        true,
        reason: "Second type value is double");

    // Map<String, double?>
    expect(customType.members[2].name, "a3");
    expect(customType.members[2].type is MapType, true,
        reason: "Third type is Map");
    expect((customType.members[2].type as MapType).key is StringType, true,
        reason: "Third type key is String");
    expect((customType.members[2].type as MapType).value is NullableDoubleType,
        true,
        reason: "Third type value is a nullable double");

    // Map<String, double?>?
    expect(customType.members[3].name, "a4");
    expect(customType.members[3].type is NullableMapType, true,
        reason: "Fourth type is a nullable Map");
    expect(
        (customType.members[3].type as NullableMapType).key is StringType, true,
        reason: "Fourth type key is String");
    expect(
        (customType.members[3].type as NullableMapType).value
        is NullableDoubleType,
        true,
        reason: "Fourth type value is a nullable double");

    // Map<String, Map<String, double>>
    expect(customType.members[4].name, "a5");
    expect(customType.members[4].type is MapType, true,
        reason: "Fifth type is Map");
    expect((customType.members[4].type as MapType).key is StringType, true,
        reason: "Fifth type key is String");
    expect((customType.members[4].type as MapType).value is MapType, true,
        reason: "Fifth type value is Map");
    expect(
        ((customType.members[4].type as MapType).value as MapType).key
        is StringType,
        true,
        reason: "Fifth sub map key type is String");
    expect(
        ((customType.members[4].type as MapType).value as MapType).value
        is DoubleType,
        true,
        reason: "Fifth sub map value type is double");

    // List<String>
    expect(customType.members[5].name, "b1");
    expect(customType.members[5].type is ListType, true,
        reason: "Sixth type is List");
    expect((customType.members[5].type as ListType).child is StringType, true,
        reason: "Sixth type child is String");

    // List<String?>
    expect(customType.members[6].name, "b2");
    expect(customType.members[6].type is ListType, true,
        reason: "Seventh type is List");
    expect((customType.members[6].type as ListType).child is NullableStringType, true,
        reason: "Seventh type child is a nullable String");

    // final List<String>? b3
    expect(customType.members[7].name, "b3");
    expect(customType.members[7].type is NullableListType, true,
        reason: "Eight type is a nullable List");
    expect((customType.members[7].type as NullableListType).child is StringType, true,
        reason: "Eight type child is String");
  }
}