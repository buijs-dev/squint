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
      noIdea: 1);

  // This tests makes sure the examples that are used to compare
  // are itself valid, otherwise testing is useless.
  test("Examples SmokeTest", () {
    // when:
    final jsonObject = object.toJsonObject;

    // then:
    expect(jsonObject.stringNode("foo").data, "bar");
    expect(jsonObject.booleanNode("isOk").data, true);
    expect(jsonObject.arrayNode<double>("random").data[0], 0);
    expect(jsonObject.arrayNode<double>("random").data[1], 3);
    expect(jsonObject.arrayNode<double>("random").data[2], 2);
    expect(jsonObject.arrayNode<List<String>>("multiples").data[0][0], "hooray!");

    assert(jsonObject.floatNode("id").key == "id");
    assert(jsonObject.floatNode("id").data == 1);
    
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
    final file =
        File("$outputFolder${Platform.pathSeparator}example_class.dart")
          ..createSync()
          ..writeAsStringSync(exampleClass);

    // and
    final analysis = analyzer.analyze(pathToFile: file.absolute.path);

    // when
    final dataclass = (analysis[0] as CustomType)
        .generateJsonDecodingFile(relativeImport: "")
        .trim();

    // then
    expect(dataclass, expectedOutput);
  });

  test("Verify generated boilerplate works as intended", () {
    // given
    const json = """
      {
        "id": 1,
        "isJedi": true,
        "hasPadawan": false,
        "bff": "Leia",
        "jedi": [
          "Obi-Wan", "Anakin", "Luke Skywalker"
        ],
        "coordinates": [22, 4.4, -15],
        "objectives": {
          "in-mission": false,
          "mission-results": [false, true, true, false]
        },
        "annoyance-rate": [
          { "JarJarBinks" : 9000 }
        ],
        "foo": null,
        "listOfObjectives":  [ [ [ [
          {
            "in-mission": true,
            "mission-results": [false, true, true, true]
          },
          {
            "in-mission": false,
            "mission-results": [false, true, false, false]
          }
        ] ] ] ],
          "simpleMap": {
              "a": 1,
              "b": 2,
              "c": 4
            }
      }""";

    // when
    final example = json.toExample;

    // then
    expect(example.id, 1);
    expect(example.isJedi, true);
    expect(example.hasPadawan, false);
    expect(example.bff, "Leia");
    expect(example.jedi[0], "Obi-Wan");
    expect(example.jedi[1], "Anakin");
    expect(example.jedi[2], "Luke Skywalker");
    expect(example.coordinates[0], 22.0);
    expect(example.coordinates[1], 4.4);
    expect(example.coordinates[2], -15);
    expect(example.objectives.inMission, false);
    expect(example.objectives.missionResults[0], false);
    expect(example.objectives.missionResults[1], true);
    expect(example.objectives.missionResults[2], true);
    expect(example.objectives.missionResults[3], false);
    expect(example.annoyanceRate[0]["JarJarBinks"], 9000);
    expect(example.foo, null);
    // expect(example.listOfObjectives[0].inMission, true);
    // expect(example.listOfObjectives[0].missionResults[0], false);
    // expect(example.listOfObjectives[0].missionResults[1], true);
    // expect(example.listOfObjectives[0].missionResults[2], true);
    // expect(example.listOfObjectives[0].missionResults[3], true);
    // expect(example.listOfObjectives[1].inMission, false);
    // expect(example.listOfObjectives[1].missionResults[0], false);
    // expect(example.listOfObjectives[1].missionResults[1], true);
    // expect(example.listOfObjectives[1].missionResults[2], false);
    // expect(example.listOfObjectives[1].missionResults[3], false);
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
  JsonObject get toJsonObject => JsonObject.fromNodes(nodes: [
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
        foo: string("foo"),
        isOk: boolean("isOk"),
        random: array<double>("random"),
        multiples: array<List<String>>("multiples"),
        counters: object("counters").rawData(),
        noIdea: _decodeId(float("id")),
      );
}
"""
    .trim();

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
  
  @JsonDecode<int, JsonFloatingNumber>(using: _decodeId)
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

  @JsonDecode<int, JsonFloatingNumber>(using: _decodeId)
  @JsonEncode(using: _encodeId)
  @JsonValue("id")
  final int noIdea;
}

JsonFloatingNumber _encodeId(int id) =>
    JsonFloatingNumber(key: "id", data: id.toDouble());

int _decodeId(JsonFloatingNumber id) => id.data.toInt();

extension _TestExampleJsonBuilder on _TestingExample {
  JsonObject get toJsonObject => JsonObject.fromNodes(nodes: [
        JsonString(key: "foo", data: foo),
        JsonBoolean(key: "isOk", data: isOk),
        JsonArray<dynamic>(key: "random", data: random),
        JsonArray<dynamic>(key: "multiples", data: multiples),
        JsonObject.fromMap(data: counters, key: "counters"),
        _encodeId(noIdea),
      ]);

  String get toJson => toJsonObject.stringify;
}

extension _TestExampleJsonString2Class on String {
  _TestingExample get toTestingExample => jsonDecode.toTestingExample;
}

extension _TestExampleJsonObject2Class on JsonObject {
  _TestingExample get toTestingExample => _TestingExample(
        foo: string("foo"),
        isOk: boolean("isOk"),
        random: array<double>("random"),
        multiples: array<List<String>>("multiples"),
        counters: objectNode("counters").getDataAsMap(),
        noIdea: _decodeId(floatNode("id")),
      );
}

/// Below is generated based on the following JSON:
///
/// ```
/// {
///         "id": 1,
///         "isJedi": true,
///         "hasPadawan": false,
///         "bff": "Leia",
///         "jedi": [
///           "Obi-Wan", "Anakin", "Luke Skywalker"
///         ],
///         "coordinates": [22, 4.4, -15],
///         "objectives": {
///           "in-mission": false,
///           "mission-results": [false, true, true, false]
///         },
///         "annoyance-rate": [
///           { "JarJarBinks" : 9000 }
///         ],
///         "foo": null,
///         "listOfObjectives": [
///           {
///             "in-mission": true,
///             "mission-results": [false, true, true, true]
///           },
///           {
///             "in-mission": false,
///             "mission-results": [false, true, false, false]
///           }
///         ],
///           "simpleMap": {
///             "a": 1,
///             "b": 2,
///             "c": 4
///           }
///       }
/// ```
/// Autogenerated data class by Squint.
@squint
class Example {
  const Example({
    required this.id,
    required this.isJedi,
    required this.hasPadawan,
    required this.bff,
    required this.jedi,
    required this.coordinates,
    required this.objectives,
    required this.annoyanceRate,
    required this.foo,
    required this.listOfObjectives,
    required this.simpleMap,
  });

  @JsonValue("id")
  final int id;

  @JsonValue("isJedi")
  final bool isJedi;

  @JsonValue("hasPadawan")
  final bool hasPadawan;

  @JsonValue("bff")
  final String bff;

  @JsonValue("jedi")
  final List<String> jedi;

  @JsonValue("coordinates")
  final List<double> coordinates;

  @JsonEncode(using: encodeObjectives)
  @JsonDecode<Objectives, JsonObject>(using: decodeObjectives)
  @JsonValue("objectives")
  final Objectives objectives;

  @JsonValue("annoyance-rate")
  final List<Map<String, int>> annoyanceRate;

  @JsonValue("foo")
  final dynamic foo;

  @JsonValue("listOfObjectives")
  final List<List<List<List<Objectives>>>> listOfObjectives;

  @JsonValue("simpleMap")
  final Map<String, int> simpleMap;
}

@squint
class Objectives {
  const Objectives({
    required this.inMission,
    required this.missionResults,
  });

  @JsonValue("in-mission")
  final bool inMission;

  @JsonValue("mission-results")
  final List<bool> missionResults;
}

JsonObject encodeObjectives(Objectives objectives) => JsonObject.fromNodes(nodes: [
      JsonBoolean(
        key: "in-mission",
        data: objectives.inMission,
      ),
      JsonArray<dynamic>(
        key: "mission-results",
        data: objectives.missionResults,
      ),
    ], key: "objectives");

Objectives decodeObjectives(JsonObject object) => Objectives(
      inMission: object.boolean("in-mission"),
      missionResults: object.array<bool>("mission-results"),
    );

/// Autogenerated JSON (de)serialization methods by Squint.
extension ExampleJsonBuilder on Example {
  JsonObject get toJsonObject => JsonObject.fromNodes(nodes: [
        JsonIntegerNumber(key: "id", data: id),
        JsonBoolean(key: "isJedi", data: isJedi),
        JsonBoolean(key: "hasPadawan", data: hasPadawan),
        JsonString(key: "bff", data: bff),
        JsonArray<dynamic>(key: "jedi", data: jedi),
        JsonArray<dynamic>(key: "coordinates", data: coordinates),
        JsonArray<dynamic>(key: "annoyance-rate", data: annoyanceRate),
        JsonArray<dynamic>(key: "listOfObjectives", data: listOfObjectives),
        JsonObject.fromMap(data: simpleMap, key: "simpleMap"),
        dynamicValue(key: "foo", data: foo),
        encodeObjectives(objectives),
      ]);

  String get toJson => toJsonObject.stringify;
}

extension ExampleJsonString2Class on String {
  Example get toExample => jsonDecode.toExample;
}

extension ExampleJsonObject2Class on JsonObject {
  Example get toExample => Example(
        id: integer("id"),
        isJedi: boolean("isJedi"),
        hasPadawan: boolean("hasPadawan"),
        bff: string("bff"),
        jedi: array<String>("jedi"),
        coordinates: array<double>("coordinates"),
        objectives: decodeObjectives(objectNode("objectives")),
        annoyanceRate: array<Map<String, int>>("annoyance-rate"),
        foo: byKey("foo").data,
        listOfObjectives: array<List<List<List<Objectives>>>>(
          "listOfObjectives",
          decoder: decodeObjectives,
          childType: <Objectives>[],
        ),
        simpleMap: object("simpleMap"),
      );
}
