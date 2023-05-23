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

import "package:squint_json/src/cli/generate.dart";
import "package:test/test.dart";

void main() {
  const dataclass = r"""
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
class RandomExample {
  const RandomExample({
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

JsonObject encodeObjectives(Objectives objectives) =>
    JsonObject.fromNodes(key: "objectives", nodes: [
      JsonBoolean(key: "inMission", data: objectives.inMission),
      JsonArray<dynamic>(
          key: "missionResults", data: objectives.missionResults),
    ]);

Objectives decodeObjectives(JsonObject object) => Objectives(
      inMission: object.boolean("inMission"),
      missionResults: object.array<bool>("missionResults"),
    );

JsonString encodeAnnoyanceRate(AnnoyanceRate annoyanceRate) {
  switch (annoyanceRate) {
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

  const expectedExample = """
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
import 'random_example_dataclass.dart';
import 'objectives_dataclass.dart';
import 'objectives_extensions.dart';
import 'annoyance_rate_dataclass.dart';
import 'annoyance_rate_extensions.dart';
import 'dynamic_dataclass.dart';
import 'dynamic_extensions.dart';

/// Autogenerated JSON (de)serialization methods by Squint.
extension RandomExampleJsonBuilder on RandomExample {
  JsonObject get toJsonObject => JsonObject.fromNodes(nodes: [
        JsonIntegerNumber(key: "id", data: id),
        JsonBoolean(key: "isJedi", data: isJedi),
        JsonBoolean(key: "hasPadawan", data: hasPadawan),
        JsonString(key: "bff", data: bff),
        JsonArray<dynamic>(key: "jedi", data: jedi),
        JsonArray<dynamic>(key: "coordinates", data: coordinates),
        dynamicValue(key: "foo", data: foo),
        encodeAnnoyanceRate(annoyanceRate),
        encodeObjectives(objectives),
      ]);

  String get toJson => toJsonObject.stringify;
}

extension RandomExampleJsonString2Class on String {
  RandomExample get toRandomExample => jsonDecode.toRandomExample;
}

extension RandomExampleJsonObject2Class on JsonObject {
  RandomExample get toRandomExample => RandomExample(
        id: integer("id"),
        isJedi: boolean("isJedi"),
        hasPadawan: boolean("hasPadawan"),
        bff: string("bff"),
        jedi: array<String>("jedi"),
        coordinates: array<double>("coordinates"),
        objectives: decodeObjectives(objectNode("objectives")),
        annoyanceRate: decodeAnnoyanceRate(stringNode("annoyanceRate")),
        foo: byKey("foo").data,
      );
}
""";

  const expectedObjectives = """
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
import 'random_example_dataclass.dart';

/// Autogenerated JSON (de)serialization methods by Squint.
extension ObjectivesJsonBuilder on Objectives {
  JsonObject get toJsonObject => JsonObject.fromNodes(nodes: [
        JsonBoolean(key: "inMission", data: inMission),
        JsonArray<dynamic>(key: "missionResults", data: missionResults),
      ]);

  String get toJson => toJsonObject.stringify;
}

extension ObjectivesJsonString2Class on String {
  Objectives get toObjectives => jsonDecode.toObjectives;
}

extension ObjectivesJsonObject2Class on JsonObject {
  Objectives get toObjectives => Objectives(
        inMission: boolean("inMission"),
        missionResults: array<bool>("missionResults"),
      );
}
""";

  test("Verify Converting a JSON String to a data class", () {
    // setup:
    final sep = Platform.pathSeparator;
    final basePath = "${Directory.systemTemp.absolute.path}$sep";
    final outputPath = "${basePath}output";

    // given:
    final dataclassFile = File("$outputPath${sep}random_example_dataclass.dart")
      ..createSync(recursive: true)
      ..writeAsStringSync(dataclass);

    final expectedExampleFile =
        File("$outputPath${sep}random_example_extensions.dart");

    final expectedObjectivesFile =
        File("$outputPath${sep}objectives_extensions.dart");

    // when:
    final result = runGenerateTask([
      "--type",
      "serializer",
      "--input",
      dataclassFile.absolute.path,
      "--output",
      outputPath,
      "--overwrite",
      "true"
    ]);

    expect(result.ok!.parent != null, true,
        reason: "There should be a parent!");
    expect(expectedExampleFile.existsSync(), true,
        reason: "Example serializer is generated");
    expect(expectedExampleFile.readAsStringSync(), expectedExample,
        reason: "Example serializer content is correct");
    expect(expectedObjectivesFile.existsSync(), true,
        reason: "Objectives serializer is generated");
    expect(expectedObjectivesFile.readAsStringSync(), expectedObjectives,
        reason: "Objectives serializer content is correct");
  });
}
