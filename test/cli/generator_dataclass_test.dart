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

import "dart:core";
import "dart:io";

import "package:squint_json/squint_json.dart";
import "package:squint_json/src/cli/generate.dart";
import "package:test/test.dart";

void main() {
  const annoyanceRate = """
      {
        "className": "AnnoyanceRate",
        "values": ["low", "high", "unbearable"],
        "valuesJSON": ["LOW", "HIGH", "UNBEARABLE"]
      }
    """;

  const example = """
     {
        "className": "Example",
        "members": [
          { 
              "name": "id",
              "type": "int",
              "nullable": false
            }
            ,      { 
              "name": "isJedi",
              "type": "bool",
              "nullable": false
            }
            ,      { 
              "name": "hasPadawan",
              "type": "bool",
              "nullable": false
            }
            ,      { 
              "name": "bff",
              "type": "String",
              "nullable": false
            }
            ,      { 
              "name": "jedi",
              "type": "List<String>",
              "nullable": false
            }
            ,      { 
              "name": "coordinates",
              "type": "List<double>",
              "nullable": false
            }
            ,      { 
              "name": "objectives",
              "type": "Objectives",
              "nullable": false
            }
            ,      { 
              "name": "annoyanceRate",
              "type": "AnnoyanceRate",
              "nullable": false
            }
            ,      { 
              "name": "foo",
              "type": "dynamic",
              "nullable": false
            }
            
        ]
      }
    """;

  const objectives = """
    {
        "className": "Objectives",
        "members": [
                { 
              "name": "inMission",
              "type": "bool",
              "nullable": false
            }
            ,      { 
              "name": "missionResults",
              "type": "List<bool>",
              "nullable": false
            }
            
        ]
      }
  """;

  const expected = r"""
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

  @JsonEncode(using: encodeAnnoyanceRate)
  @JsonDecode<AnnoyanceRate, JsonString>(using: decodeAnnoyanceRate)
  @JsonValue("annoyanceRate")
  final AnnoyanceRate annoyanceRate;

  @JsonValue("foo")
  final dynamic foo;
}

@squint
class Objectives {
  const Objectives({
    required this.inMission,
    required this.missionResults,
  });

  @JsonValue("inMission")
  final bool inMission;

  @JsonValue("missionResults")
  final List<bool> missionResults;
}

@squint
enum AnnoyanceRate {
  @JsonValue("LOW")
  low,
  @JsonValue("HIGH")
  high,
  @JsonValue("UNBEARABLE")
  unbearable
}

JsonObject encodeObjectives(Objectives object) =>
    JsonObject.fromNodes(key: "objectives", nodes: [
      JsonBoolean(key: "inMission", data: object.inMission),
      JsonArray<dynamic>(key: "missionResults", data: object.missionResults),
    ]);

Objectives decodeObjectives(JsonObject object) => Objectives(
      inMission: object.boolean("inMission"),
      missionResults: object.array<bool>("missionResults"),
    );

JsonString encodeAnnoyanceRate(AnnoyanceRate object) {
  switch (object) {
    case AnnoyanceRate.low:
      return const JsonString(key: "annoyanceRate", data: "LOW");

    case AnnoyanceRate.high:
      return const JsonString(key: "annoyanceRate", data: "HIGH");

    case AnnoyanceRate.unbearable:
      return const JsonString(key: "annoyanceRate", data: "UNBEARABLE");
  }
}

AnnoyanceRate decodeAnnoyanceRate(JsonString value) {
  switch (value.data) {
    case "LOW":
      return AnnoyanceRate.low;

    case "HIGH":
      return AnnoyanceRate.high;

    case "UNBEARABLE":
      return AnnoyanceRate.unbearable;

    default:
      throw SquintException(
          "Unable to map value to AnnoyanceRate enum: ${value.data}");
  }
}
""";

  test("Verify Converting a JSON String to a data class", () {
    // setup:
    final sep = Platform.pathSeparator;
    final basePath = "${Directory.systemTemp.absolute.path}$sep";
    final outputPath = "$basePath${sep}output";
    final expectedFile = File("$outputPath${sep}example_dataclass.dart");

    if (expectedFile.existsSync()) {
      expectedFile.deleteSync();
    }

    // given:
    File("$basePath${metadataMarkerPrefix}annoyancerate.json")
      ..createSync(recursive: true)
      ..writeAsStringSync(annoyanceRate);

    final exampleFile = File("$basePath${metadataMarkerPrefix}example.json")
      ..createSync(recursive: true)
      ..writeAsStringSync(example);

    File("$basePath${metadataMarkerPrefix}objectives.json")
      ..createSync(recursive: true)
      ..writeAsStringSync(objectives);

    // when:
    final result = runGenerateTask([
      "--type",
      "dataclass",
      "--input",
      exampleFile.absolute.path,
      "--output",
      outputPath,
      "--overwrite",
      "true"
    ]);

    expect(result.ok!.parent != null, true,
        reason: "There should be a parent!");
    expect(expectedFile.existsSync(), true, reason: "Dataclass is generated");
    expect(expectedFile.readAsStringSync(), expected,
        reason: "Dataclass content is correct");
  });

  test("Verify Converting an enumeration from a metadata JSON file", () {
    // setup:
    final sep = Platform.pathSeparator;
    final basePath = "${Directory.systemTemp.absolute.path}$sep";
    final outputPath = "$basePath${sep}output";
    final expectedFile = File("$outputPath${sep}annoyancerate_dataclass.dart");

    if (expectedFile.existsSync()) {
      expectedFile.deleteSync();
    }

    // given:
    const expectedEnum = """
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

import 'package:squint_json/squint_json.dart';

/// Autogenerated enum class by Squint.
@squint
enum AnnoyanceRate {
  @JsonValue("LOW")
  low,
  @JsonValue("HIGH")
  high,
  @JsonValue("UNBEARABLE")
  unbearable
}
""";
    final annoyanceRateFile =
        File("$basePath${metadataMarkerPrefix}annoyancerate.json")
          ..createSync(recursive: true)
          ..writeAsStringSync(annoyanceRate);

    // when:
    final result = runGenerateTask([
      "--type",
      "dataclass",
      "--input",
      annoyanceRateFile.absolute.path,
      "--output",
      outputPath,
      "--overwrite",
      "true"
    ]);

    expect(result.ok!.parent == null, true,
        reason: "There should no a parent!");
    expect(result.ok!.childrenEnumTypes.length, 1,
        reason: "There should be 1 enum");
    expect(expectedFile.existsSync(), true, reason: "Enum is generated");
    expect(expectedFile.readAsStringSync(), expectedEnum,
        reason: "Enum content is correct");
  });
}
