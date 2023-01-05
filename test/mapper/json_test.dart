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

// ignore_for_file: avoid_dynamic_calls

import "package:squint/squint.dart";
import 'package:squint/src/converters/converters.dart';
import 'package:squint/src/mapper/json.dart';
import "package:test/test.dart";

void main() {
  test("verify implementing SquintJson mixin", () {
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
    final example = readValue(json);

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

class Example2 {
  const Example2(this.object);

  final JsonObject object;

  int get id => object.integer("id");

  bool get isJedi => object.boolean("isJedi");

  // final bool hasPadawan;
  // final String bff;
  // final List<String> jedi;
  // final List<double> coordinates;
  // final Objectives objectives;
  // final List<Map<String, int>> annoyanceRate;
  // final dynamic foo;
  // final List<List<List<List<Objectives>>>> listOfObjectives;
  // final Map<String, int> simpleMap;

  String get writeValue => object.stringify;
}

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

  final int id;
  final bool isJedi;
  final bool hasPadawan;
  final String bff;
  final List<String> jedi;
  final List<double> coordinates;
  final Objectives objectives;
  final List<Map<String, int>> annoyanceRate;
  final dynamic foo;
  final List<List<List<List<Objectives>>>> listOfObjectives;
  final Map<String, int> simpleMap;

  String writeValue(Example t) => JsonObject.fromNodes(nodes: [
    "id".integer(id),
    "isJedi".boolean(isJedi),
    "hasPadawan".boolean(hasPadawan),
    JsonString(key: "bff", data: bff),
    JsonArray(key: "jedi", data: jedi),
    JsonArray(key: "coordinates", data: coordinates),
    JsonArray(key: "annoyance-rate", data: annoyanceRate),
    JsonArray(key: "listOfObjectives", data: listOfObjectives),
    JsonObject.fromMap(data: simpleMap, key: "simpleMap"),
    "foo".unkown(foo),
    encodeObjectives(objectives),
  ]).stringify;
}

extension JsonBuilder on String {
  JsonIntegerNumber integer(int data) =>
      JsonIntegerNumber(key: this, data: data);
  JsonFloatingNumber float(double data) =>
      JsonFloatingNumber(key: this, data: data);
  JsonBoolean boolean(bool data) =>
      JsonBoolean(key: this, data: data);
  /// JSON node of unknown type.
  ///
  /// The data is stored as dynamic
  /// because the type can not be determined.
  /// Value is possibly null.
  UntypedJsonNode unkown(dynamic data) =>
      UntypedJsonNode(key: this, data: data);
}

Example readValue(String json) {
  final object = json.jsonDecode;
  return Example(
    id: object.integer("id"),
    isJedi: object.boolean("isJedi"),
    hasPadawan: object.boolean("hasPadawan"),
    bff: object.string("bff"),
    jedi: object.array<String>("jedi"),
    coordinates: object.array<double>("coordinates"),
    objectives: decodeObjectives(object.objectNode("objectives")),
    annoyanceRate: object.array<Map<String, int>>("annoyance-rate"),
    foo: object.byKey("foo").data,
    listOfObjectives: object.array<List<List<List<Objectives>>>>(
      "listOfObjectives",
      decoder: decodeObjectives,
      childType: <Objectives>[],
    ),
    simpleMap: object.object("simpleMap"),
  );
}

@squint
class Objectives {
  const Objectives({
    required this.inMission,
    required this.missionResults,
  });

  final bool inMission;
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

// /// Below is generated based on the following JSON:
// ///
// /// ```
// /// {
// ///         "id": 1,
// ///         "isJedi": true,
// ///         "hasPadawan": false,
// ///         "bff": "Leia",
// ///         "jedi": [
// ///           "Obi-Wan", "Anakin", "Luke Skywalker"
// ///         ],
// ///         "coordinates": [22, 4.4, -15],
// ///         "objectives": {
// ///           "in-mission": false,
// ///           "mission-results": [false, true, true, false]
// ///         },
// ///         "annoyance-rate": [
// ///           { "JarJarBinks" : 9000 }
// ///         ],
// ///         "foo": null,
// ///         "listOfObjectives": [
// ///           {
// ///             "in-mission": true,
// ///             "mission-results": [false, true, true, true]
// ///           },
// ///           {
// ///             "in-mission": false,
// ///             "mission-results": [false, true, false, false]
// ///           }
// ///         ],
// ///           "simpleMap": {
// ///             "a": 1,
// ///             "b": 2,
// ///             "c": 4
// ///           }
// ///       }
// /// ```
// /// Autogenerated data class by Squint.
// @squint
// class Example with SquintJson<Example> {
//   const Example({
//     required this.id,
//     required this.isJedi,
//     required this.hasPadawan,
//     required this.bff,
//     required this.jedi,
//     required this.coordinates,
//     required this.objectives,
//     required this.annoyanceRate,
//     required this.foo,
//     required this.listOfObjectives,
//     required this.simpleMap,
//   });
//
//   @JsonValue("id")
//   final int id;
//
//   @JsonValue("isJedi")
//   final bool isJedi;
//
//   @JsonValue("hasPadawan")
//   final bool hasPadawan;
//
//   @JsonValue("bff")
//   final String bff;
//
//   @JsonValue("jedi")
//   final List<String> jedi;
//
//   @JsonValue("coordinates")
//   final List<double> coordinates;
//
//   @JsonEncode(using: encodeObjectives)
//   @JsonDecode<
//       Objectives,
//       JsonObject
//   >(using: decodeObjectives)
//   @JsonValue("objectives")
//   final Objectives objectives;
//
//   @JsonValue("annoyance-rate")
//   final List<Map<String, int>> annoyanceRate;
//
//   @JsonValue("foo")
//   final dynamic foo;
//
//   @JsonValue("listOfObjectives")
//   final List<List<List<List<Objectives>>>> listOfObjectives;
//
//   @JsonValue("simpleMap")
//   final Map<String, int> simpleMap;
//
//   @override
//   Example readValue(String json) {
//     final object = json.jsonDecode;
//     return Example(
//       id: object.integerValue("id"),
//       isJedi: object.booleanValue("isJedi"),
//       hasPadawan: object.booleanValue("hasPadawan"),
//       bff: object.stringValue("bff"),
//       jedi: object.arrayValue<String>("jedi"),
//       coordinates: object.arrayValue<double>("coordinates"),
//       objectives: decodeObjectives(object.object("objectives")),
//       annoyanceRate: object.arrayValue<Map<String, int>>("annoyance-rate"),
//       foo: object.byKey("foo").data,
//       listOfObjectives: object.arrayValue<List<List<List<Objectives>>>>(
//         "listOfObjectives",
//         decoder: decodeObjectives,
//         childType: <Objectives>[],
//       ),
//       simpleMap: object.mapValue("simpleMap"),
//     );
//   }
//
//   @override
//   String writeValue(Example t) => JsonObject.elements([
//     JsonIntegerNumber(key: "id", data: id),
//     JsonBoolean(key: "isJedi", data: isJedi),
//     JsonBoolean(key: "hasPadawan", data: hasPadawan),
//     JsonString(key: "bff", data: bff),
//     JsonArray<dynamic>(key: "jedi", data: jedi),
//     JsonArray<dynamic>(key: "coordinates", data: coordinates),
//     JsonArray<dynamic>(key: "annoyance-rate", data: annoyanceRate),
//     JsonArray<dynamic>(key: "listOfObjectives", data: listOfObjectives),
//     JsonObject.fromMap(simpleMap, "simpleMap"),
//     dynamicValue(key: "foo", data: foo),
//     encodeObjectives(objectives),
//   ]).stringify;
//
// }
//
// @squint
// class Objectives {
//   const Objectives({
//     required this.inMission,
//     required this.missionResults,
//   });
//
//   @JsonValue("in-mission")
//   final bool inMission;
//
//   @JsonValue("mission-results")
//   final List<bool> missionResults;
// }
//
// JsonObject encodeObjectives(Objectives objectives) => JsonObject.elements([
//   JsonBoolean(
//     key: "in-mission",
//     data: objectives.inMission,
//   ),
//   JsonArray<dynamic>(
//     key: "mission-results",
//     data: objectives.missionResults,
//   ),
// ], "objectives");
//
// Objectives decodeObjectives(JsonObject object) => Objectives(
//   inMission: object.booleanValue("in-mission"),
//   missionResults: object.arrayValue<bool>("mission-results"),
// );
