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

import "package:squint_json/squint_json.dart";
import "package:squint_json/src/converters/converters.dart";
import "package:test/test.dart";

/// When changes are made in this test then the quickstart.md should be updated as well.
void main() {
  const json = """
{
    "id" : 1,
    "isJedi" : true,
    "hasPadawan" : false,
    "bff" : "Leia",
    "jedi" : [
        "Obi-Wan",
        "Anakin",
        "Luke Skywalker"
    ],
    "coordinates" : [
        22.0,
        4.4,
        -15.0
    ],
    "objectives" : {
        "in-mission" : false,
        "mission-results" : [
            false,
            true,
            true,
            false
        ]
    },
    "annoyance-rate" : [
        {
            "JarJarBinks" : 9000
        }
    ],
    "foo" : null
}""";

  /// Decoding JSON examples.
  ///
  ///
  /// ===========================================

  test("verify decoding with extension method", () {
    // Variable 'json' is our actual JSON String.
    final object = json.jsonDecode;

    expect(object.data.isNotEmpty, true);
  });

  test("verify decoding with extension method", () {
    // Variable 'json' is our actual JSON String.
    final object = toJsonObject(json);

    expect(object.data.isNotEmpty, true);
  });

  test("verify accessing data by data-type and key", () {
    // Variable 'json' is our actual JSON String.
    final object = toJsonObject(json);

    // Getter integer will return a JsonIntegerNumber
    expect(object.integerNode("id").key, "id");
    expect(object.integerNode("id").data, 1);
  });

  test("verify accessing data directly", () {
    // Variable 'json' is our actual JSON String.
    final object = toJsonObject(json);

    // Getter integer will return a JsonIntegerNumber
    expect(object.integer("id"), 1);
  });

  test("verify accessing bool value data directly", () {
    // Variable 'json' is our actual JSON String.
    final object = toJsonObject(json);

    expect(object.boolean("isJedi"), true);
    expect(object.boolean("hasPadawan"), false);
  });

  test("verify accessing String value data directly", () {
    // Variable 'json' is our actual JSON String.
    final object = toJsonObject(json);

    expect(object.string("bff"), "Leia");
  });

  test("verify accessing a nullable value data directly", () {
    // Variable 'json' is our actual JSON String.
    final object = toJsonObject(json);

    expect(object.stringOrNull("foo"), null);
  });

  test("verify an exception is thrown if the request key is not found", () {
    // Variable 'json' is our actual JSON String.
    final object = toJsonObject(json);

    expect(
        () => object.string("does-not-exist"),
        throwsA(predicate((e) =>
            e is SquintException &&
            e.cause == "JSON key not found: 'does-not-exist'")));
  });

  test("verify accessing a List value", () {
    // Variable 'json' is our actual JSON String.
    final object = toJsonObject(json);

    // IDE will report: Unnecessary type check; the result is always 'true'.
    expect(object.array<String>("jedi") is List<String>, true);

    expect(object.array<String>("jedi")[0], "Obi-Wan");
    expect(object.array<String>("jedi")[1], "Anakin");
    expect(object.array<String>("jedi")[2], "Luke Skywalker");

    // Notice how all values are casted to double
    // even though they're not all floating point numbers.
    expect(object.array<double>("coordinates")[0], 22);
    expect(object.array<double>("coordinates")[1], 4.4);
    expect(object.array<double>("coordinates")[2], -15);
  });

  test("verify accessing a JsonObject with the object getter", () {
    // Variable 'json' is our actual JSON String.
    final object = toJsonObject(json);

    expect(object.objectNode("objectives").boolean("in-mission"), false);
    expect(object.objectNode("objectives").array<bool>("mission-results")[0],
        false);
    expect(object.objectNode("objectives").array<bool>("mission-results")[1],
        true);
  });

  test("verify accessing a JsonObject nested inside a List", () {
    // Variable 'json' is our actual JSON String.
    final object = toJsonObject(json);

    expect(object.array<Map<String, int>>("annoyance-rate")[0]["JarJarBinks"],
        9000);
  });

  /// Encoding JSON examples.
  ///
  ///
  /// ===========================================

  test("verify encoding a JsonObject with stringify", () {
    // Variable 'json' is our actual JSON String.
    final object = json.jsonDecode;

    final stringified = object.stringify;

    expect(stringified, json);
  });

  test("verify encoding a JsonObject with formatting", () {
    // Variable 'json' is our actual JSON String.
    final object = json.jsonDecode;

    // Encode JsonObject to formatted JSON String.
    // Specifying standardJsonFormatting like this
    // is redundant because that is the default formatting.
    expect(object.stringifyWithFormatting(standardJsonFormatting), json);
  });

  test("verify encoding a JsonObject with custom formatting", () {
    // Variable 'json' is our actual JSON String.
    final object = json.jsonDecode;

    // Encode JsonObject to formatted JSON String.
    // Set the indentation size to double space.
    expect(
        object.stringifyWithFormatting(
              standardJsonFormatting.copyWith(
                indentationSize: JsonIndentationSize.doubleSpace,
              ),
            ) !=
            json,
        true);
  });

  /// Code generation examples.
  ///
  ///
  /// ===========================================

  test("verify generating a data class from a JSON String", () {
    // Expected data class output:
    const expected = """
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

import 'package:squint_json/squint_json.dart';

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

JsonObject encodeObjectives(Objectives object) =>
    JsonObject.fromNodes(key: "objectives", nodes: [
      JsonBoolean(key: "in-mission", data: object.inMission),
      JsonArray<dynamic>(key: "mission-results", data: object.missionResults),
    ]);

Objectives decodeObjectives(JsonObject object) => Objectives(
      inMission: object.boolean("in-mission"),
      missionResults: object.array<bool>("mission-results"),
    );
""";

    // Variable 'json' is our actual JSON String.
    final object = json.jsonDecode;

    // Convert a JsonObject to a CustomType object (AST model).
    final customType = object.toCustomType(className: "Example");

    // Convert a CustomType to a .dart File.
    expect(customType.generateDataClassFile(), expected);
  });

  test("verify generating (de)serialization code for a data class", () {
    // Expected data class output:
    const expected = """
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

import 'package:squint_json/squint_json.dart';
import 'exampleish.dart';
import 'objectives_dataclass.dart';
import 'dynamic_dataclass.dart';

/// Autogenerated JSON (de)serialization methods by Squint.
extension ExampleishJsonBuilder on Exampleish {
  JsonObject get toJsonObject => JsonObject.fromNodes(nodes: [
        JsonIntegerNumber(key: "id", data: id),
        JsonBoolean(key: "isJedi", data: isJedi),
        JsonBoolean(key: "hasPadawan", data: hasPadawan),
        JsonString(key: "bff", data: bff),
        JsonArray<dynamic>(key: "jedi", data: jedi),
        JsonArray<dynamic>(key: "coordinates", data: coordinates),
        JsonArray<dynamic>(key: "annoyance-rate", data: annoyanceRate),
        dynamicValue(key: "foo", data: foo),
        encodeObjectives(objectives),
      ]);

  String get toJson => toJsonObject.stringify;
}

extension ExampleishJsonString2Class on String {
  Exampleish get toExampleish => jsonDecode.toExampleish;
}

extension ExampleishJsonObject2Class on JsonObject {
  Exampleish get toExampleish => Exampleish(
        id: integer("id"),
        isJedi: boolean("isJedi"),
        hasPadawan: boolean("hasPadawan"),
        bff: string("bff"),
        jedi: array<String>("jedi"),
        coordinates: array<double>("coordinates"),
        objectives: decodeObjectives(objectNode("objectives")),
        annoyanceRate: array<Map<String, int>>("annoyance-rate"),
        foo: byKey("foo").data,
      );
}
""";

    // Variable 'json' is our actual JSON String.
    final object = json.jsonDecode;

    // Convert a JsonObject to a CustomType object (AST model).
    final customType = object.toCustomType(className: "Exampleish");

    // Generate extenions methods.
    expect(
        customType.generateJsonDecodingFile(relativeImport: "exampleish.dart"),
        expected);
  });
}
