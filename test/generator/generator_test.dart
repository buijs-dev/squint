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

import "package:squint/squint.dart";
import "package:squint/src/analyzer/analyzer.dart" as analyzer;
import "package:squint/src/generator/generator.dart" as generator;
import "package:test/test.dart";

void main() {
  const object = _TestingExample(
    foo: "bar",
    isOk: true,
    random: [0, 3, 2],
    multiples: [
      ["hooray!"]
    ],
    counters: {
      "x": 2,
      "y": 5,
    },
      noIdea: 1
  );

  // This tests makes sure the examples that are used to compare
  // are itself valid, otherwise testing is useless.
  test("Examples SmokeTest", () {
    // when:
    final jsonObject = object.toJsonObject;

    // then:
    expect(jsonObject.string("foo").data, "bar");
    expect(jsonObject.boolean("isOk").data, true);
    expect(jsonObject.array<double>("random").data[0], 0);
    expect(jsonObject.array<double>("random").data[1], 3);
    expect(jsonObject.array<double>("random").data[2], 2);
    expect(jsonObject.array<List<String>>("multiples").data[0][0], "hooray!");

    // when:
    final jsonString = object.toJson;

    // then:
    expect(jsonString, """
{
    "foo" : "bar",
    "isOk" : true,
    "random" : [
        0.0,
        3.0,
        2.0
    ],
    "multiples" : [
        [
            "hooray!"
        ]
    ],
    "counters" : {
        "x" : 2.0,
        "y" : 5.0
    },
    "id" : 1.0
}""");

    // when:
    final decoded = jsonString.toTestingExample;

    // then:
    expect(decoded.foo, "bar");
    expect(decoded.isOk, true);
    expect(decoded.random[0], 0);
    expect(decoded.random[1], 3);
    expect(decoded.random[2], 2);
    expect(decoded.multiples[0][0], "hooray!");

    // when:
    final decodedFromObject = jsonObject.toTestingExample;

    // then:
    expect(decodedFromObject.foo, "bar");
    expect(decodedFromObject.isOk, true);
    expect(decodedFromObject.random[0], 0);
    expect(decodedFromObject.random[1], 3);
    expect(decodedFromObject.random[2], 2);
    expect(decodedFromObject.multiples[0][0], "hooray!");
  });

  test("Verify generating (de)serialization methods", () {

    // given
    final outputFolder = Directory.systemTemp.absolute.path;

    // and
    final file = File("$outputFolder${Platform.pathSeparator}example_class.dart")
      ..createSync()
      ..writeAsStringSync(exampleClass);

    // and
    final analysis = analyzer.analyze(pathToFile: file.absolute.path);

    // when
    final dataclass = (analysis[0] as CustomType).generateFile(relativeImport: "").trim();

    // then
    expect(dataclass, expectedOutput);
  });

  test("verify an exception is thrown if the dart class has CustomType members", () {
    expect(() => const CustomType(
        className: "NestedCustomType",
        members: [
          TypeMember(
              name: "child",
              type: CustomType(
                  className: "ChildClass",
                  members: [],
              ),
          ),
        ],
    ).generateFile(relativeImport: ""), throwsA(predicate((e) => e is SquintException &&
        e.cause == "Unsupported data type: ChildClass"
    )));

    expect(() => const CustomType(
      className: "NestedCustomType",
      members: [
        TypeMember(
          name: "child",
          type: ListType(
            CustomType(
              className: "ChildClass",
              members: [],
            ),
          )
        ),
      ],
    ).generateFile(relativeImport: ""), throwsA(predicate((e) => e is SquintException &&
        e.cause == "Unsupported data type: ChildClass"
    )));
  });

}

final expectedOutput = """
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

import '';
import 'package:squint/squint.dart';

/// Autogenerated JSON (de)serialization methods by Squint.
extension TestingExampleJsonBuilder on TestingExample {
  JsonObject get toJsonObject => JsonObject.elements([
    JsonString(key: "foo", data: foo),
    JsonBoolean(key: "isOk", data: isOk),
    JsonArray<dynamic>(key: "random", data: random),
    JsonArray<dynamic>(key: "multiples", data: multiples),
    JsonObject.fromMap(counters, "counters"),
    _encodeId(noIdea),
  ]);

  String get toJson => toJsonObject.stringify;
}

extension TestingExampleJsonString2Class on String {
  TestingExample get toTestingExample => jsonDecode.toTestingExample;
}

extension TestingExampleJsonObject2Class on JsonObject {
  TestingExample get toTestingExample => TestingExample(
    foo: string("foo").data,
    isOk: boolean("isOk").data,
    random: array<double>("random").data,
    multiples: array<List<String>>("multiples").data,
    counters: object("counters").rawData(),
    noIdea: _decodeId(number("id")),
  );
}
""".trim();

const exampleClass = """
@squint
class TestingExample {
  const TestingExample({
    required this.foo,
    required this.isOk,
    required this.random,
    required this.multiples,
    required this.counters,
    required this.id, 
  });

  final String foo;
  final bool isOk;
  final List<double> random;
  final List<List<String>> multiples;
  final Map<String, double> counters;
  
  @JsonDecode<int, JsonNumber>(using: _decodeId)
  @JsonEncode(using: _encodeId)
  @JsonValue("id")
  final int noIdea;
}

JsonNumber _encodeId(int id) =>
  JsonNumber(key: "id", data: id.toDouble());

int _decodeId(JsonNumber id) =>
  id.data.toInt();
""";

@squint
class _TestingExample {
  const _TestingExample({
    required this.foo,
    required this.isOk,
    required this.random,
    required this.multiples,
    required this.counters,
    required this.noIdea,
  });
  
  final String foo;
  final bool isOk;
  final List<double> random;
  final List<List<String>> multiples;
  final Map<String, double> counters;

  @JsonDecode<int, JsonNumber>(using: _decodeId)
  @JsonEncode(using: _encodeId)
  @JsonValue("id")
  final int noIdea;
}

JsonNumber _encodeId(int id) =>
  JsonNumber(key: "id", data: id.toDouble());

int _decodeId(JsonNumber id) =>
  id.data.toInt();

extension _TestExampleJsonBuilder on _TestingExample {
  JsonObject get toJsonObject => JsonObject.elements([
    JsonString(key: "foo", data: foo),
    JsonBoolean(key: "isOk", data: isOk),
    JsonArray<dynamic>(key: "random", data: random),
    JsonArray<dynamic>(key: "multiples", data: multiples),
    JsonObject.fromMap(counters, "counters"),
    _encodeId(noIdea),
  ]);

  String get toJson => toJsonObject.stringify;
}

extension _TestExampleJsonString2Class on String {
  _TestingExample get toTestingExample => jsonDecode.toTestingExample;
}

extension _TestExampleJsonObject2Class on JsonObject {
  _TestingExample get toTestingExample => _TestingExample(
    foo: string("foo").data,
    isOk: boolean("isOk").data,
    random: array<double>("random").data,
    multiples: array<List<String>>("multiples").data,
    counters: object("counters").rawData(),
    noIdea: _decodeId(number("id")),
  );
}