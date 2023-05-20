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

import "package:squint_json/src/analyzer/analyzer.dart" as analyzer;
import "package:squint_json/src/ast/ast.dart";
import "package:squint_json/src/ast/types.dart";
import "package:test/test.dart";

void main() {
  test("Analyze int", () {
    "int".createResponse.executeTest(
          first: const IntType(),
          second: const NullableIntType(),
        );
  });

  test("Analyze double", () {
    "double".createResponse.executeTest(
          first: const DoubleType(),
          second: const NullableDoubleType(),
        );
  });

  test("Analyze bool", () {
    "bool".createResponse.executeTest(
          first: const BooleanType(),
          second: const NullableBooleanType(),
        );
  });

  test("Analyze String", () {
    "String".createResponse.executeTest(
          first: const StringType(),
          second: const NullableStringType(),
        );
  });

  test("Analyze Uint8List", () {
    "Uint8List".createResponse.executeTest(
          first: const Uint8ListType(),
          second: const NullableUint8ListType(),
        );
  });

  test("Analyze Int32List", () {
    "Int32List".createResponse.executeTest(
          first: const Int32ListType(),
          second: const NullableInt32ListType(),
        );
  });

  test("Analyze Int64List", () {
    "Int64List".createResponse.executeTest(
          first: const Int64ListType(),
          second: const NullableInt64ListType(),
        );
  });

  test("Analyze Float32List", () {
    "Float32List".createResponse.executeTest(
          first: const Float32ListType(),
          second: const NullableFloat32ListType(),
        );
  });

  test("Analyze Float64List", () {
    "Float64List".createResponse.executeTest(
          first: const Float64ListType(),
          second: const NullableFloat64ListType(),
        );
  });

  test("Analyze List", () {
    // given:
    final file = File("${basePath}list_response.dart")
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
            });
        
            final List<String>   a1;
            final List<String>?  a2;
            final List<String?>  a3;
            final List<String?>? a4;
            final List<List<String>> a5;
          }""",
      );

    final path = file.absolute.path;

    // when:
    final result = analyzer.analyze(pathToFile: path);

    // then:
    expect(result.childrenEnumTypes.isEmpty, true,
        reason: "There are no enums");
    expect(result.childrenCustomTypes.isEmpty, true,
        reason: "There are no customtypes");

    final type = result.parentAsCustomTypeOrFail;
    expect(type.members.length, 5);

    // List<String>
    expect(type.members[0].name, "a1");
    expect(type.members[0].type is ListType, true,
        reason: "First type is List");
    expect((type.members[0].type as ListType).child is StringType, true,
        reason: "First type child is String");

    // List<String>?
    expect(type.members[1].name, "a2");
    expect(type.members[1].type is NullableListType, true,
        reason: "Second type is a nullable List");
    expect((type.members[1].type as NullableListType).child is StringType, true,
        reason: "Second type child is String");

    // List<String?>
    expect(type.members[2].name, "a3");
    expect(type.members[2].type is ListType, true,
        reason: "Third type is List");
    expect((type.members[2].type as ListType).child is NullableStringType, true,
        reason: "Third type child is a nullable String");

    // List<String?>?
    expect(type.members[3].name, "a4");
    expect(type.members[3].type is NullableListType, true,
        reason: "Fourth type is a nullable List");
    expect(
        (type.members[3].type as NullableListType).child is NullableStringType,
        true,
        reason: "Fourth type child is a nullable String");

    // List<List<String>>
    expect(type.members[4].name, "a5");
    expect(type.members[4].type is ListType, true,
        reason: "Fifth type is List");
    expect((type.members[4].type as ListType).child is ListType, true,
        reason: "Fifth type child is List");
    expect(
        ((type.members[4].type as ListType).child as ListType).child
            is StringType,
        true,
        reason: "Fifth sub child type is String");
  });

  test("Analyze Map", () {
    // given:
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
            });
        
            final Map<String, double>   a1;
            final Map<String, double>?  a2;
            final Map<String, double?>  a3;
            final Map<String, double?>? a4;
            final Map<String, Map<String, double>> a5;
          }""",
      );

    final path = file.absolute.path;

    // when:
    final result = analyzer.analyze(pathToFile: path);

    // then:
    expect(result.parent != null, true, reason: "Should have found 1 type");

    final type = result.parentAsCustomTypeOrFail;

    expect(type.members.length, 5);

    // Map<String, double>
    expect(type.members[0].name, "a1");
    expect(type.members[0].type is MapType, true, reason: "First type is Map");
    expect((type.members[0].type as MapType).key is StringType, true,
        reason: "First type key is String");
    expect((type.members[0].type as MapType).value is DoubleType, true,
        reason: "First type value is double");

    // Map<String, double>?
    expect(type.members[1].name, "a2");
    expect(type.members[1].type is NullableMapType, true,
        reason: "Second type is a nullable Map");
    expect((type.members[1].type as NullableMapType).key is StringType, true,
        reason: "Second type key is String");
    expect((type.members[1].type as NullableMapType).value is DoubleType, true,
        reason: "Second type value is double");

    // Map<String, double?>
    expect(type.members[2].name, "a3");
    expect(type.members[2].type is MapType, true, reason: "Third type is Map");
    expect((type.members[2].type as MapType).key is StringType, true,
        reason: "Third type key is String");
    expect((type.members[2].type as MapType).value is NullableDoubleType, true,
        reason: "Third type value is a nullable double");

    // Map<String, double?>?
    expect(type.members[3].name, "a4");
    expect(type.members[3].type is NullableMapType, true,
        reason: "Fourth type is a nullable Map");
    expect((type.members[3].type as NullableMapType).key is StringType, true,
        reason: "Fourth type key is String");
    expect(
        (type.members[3].type as NullableMapType).value is NullableDoubleType,
        true,
        reason: "Fourth type value is a nullable double");

    // Map<String, Map<String, double>>
    expect(type.members[4].name, "a5");
    expect(type.members[4].type is MapType, true, reason: "Fifth type is Map");
    expect((type.members[4].type as MapType).key is StringType, true,
        reason: "Fifth type key is String");
    expect((type.members[4].type as MapType).value is MapType, true,
        reason: "Fifth type value is Map");
    expect(
        ((type.members[4].type as MapType).value as MapType).key is StringType,
        true,
        reason: "Fifth sub map key type is String");
    expect(
        ((type.members[4].type as MapType).value as MapType).value
            is DoubleType,
        true,
        reason: "Fifth sub map value type is double");
  });

  test("Analyze class with enumerated member", () {
    // given:
    final file = File("${basePath}classwithenum_response.dart")
      ..createSync()
      ..writeAsStringSync(
        """
          @squint
          class SimpleResponse {
            ///
            SimpleResponse({
                required this.myEnum,
            });
        
            final MyEnum myEnum;
          }
          
          @squint
          enum MyEnum {
            hello,
            goodbye
          }
          """,
      );

    final path = file.absolute.path;

    // when:
    final result = analyzer.analyze(pathToFile: path);

    // then:
    expect(result.parent != null, true, reason: "First is CustomType");
    expect(result.parent!.className == "SimpleResponse", true,
        reason: "First class is named SimpleResponse");
    // and:
    final enumType = result.childrenEnumTypes.first;
    expect(enumType.values[0], "hello", reason: "First value is hello");
    expect(enumType.values[1], "goodbye", reason: "Second value is goodbye");
    expect(enumType.valuesJSON.isEmpty, true);
  });

  test("Analyze class with enumerated member containing @JsonValue", () {
    // given:
    final file = File("${basePath}classwithenum_response.dart")
      ..createSync()
      ..writeAsStringSync(
        """
          @squint
          class SimpleResponse {
            ///
            SimpleResponse({
                required this.myEnum,
            });
        
            final MyEnum myEnum;
          }
          
          @squint
          enum MyEnum {
            @JsonValue("HELLO!")
            hello, 
            @JsonValue("GOODBYE...")
            goodbye
          }
          """,
      );

    final path = file.absolute.path;

    // when:
    final result = analyzer.analyze(pathToFile: path);

    // then:
    expect(result.parent != null, true, reason: "First is CustomType");
    expect(result.parent!.className == "SimpleResponse", true,
        reason: "First class is named SimpleResponse");
    // and:
    final enumType = result.childrenEnumTypes.first;
    expect(enumType.values[0], "hello", reason: "First value is hello");
    expect(enumType.values[1], "goodbye", reason: "Second value is goodbye");
    expect(enumType.valuesJSON[0], "HELLO!",
        reason: "First JSON value is HELLO!");
    expect(enumType.valuesJSON[1], "GOODBYE...",
        reason: "Second JSON value is GOODBYE...");
  });
}

final basePath =
    "${Directory.systemTemp.absolute.path}${Platform.pathSeparator}";

extension TestFileWriter on String {
  String get createResponse {
    final file = File("$basePath${this}_response.dart")
      ..createSync()
      ..writeAsStringSync(
        """
          @squint
          class SimpleResponse {
            ///
            SimpleResponse({
                required this.a1,
                required this.a2,
            });
        
            final $this a1;
            final $this? a2;
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

    final type = result.parentAsCustomTypeOrFail;

    // then:
    expect(type.members.length, 2);
    expect(type.members[0].name, "a1");
    expect(type.members[0].type.toString() == first.toString(), true,
        reason: "First type is not nullable");
    expect(type.members[1].name, "a2");
    expect(type.members[1].type.toString() == second.toString(), true,
        reason: "Second type is nullable");

    return true;
  }
}
