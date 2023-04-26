# Quick start

Install this library with Dart:

```shell
dart pub add squint
```

Or with Flutter:

```shell
flutter pub add squint
```

This will add a line like this to your package's pubspec.yaml (and run an implicit dart pub get):

```yaml
dependencies:
  squint_json: ^0.0.6
```

## Features
The following steps can be followed as a short tutorial.
It will cover all main features of Squint.
If you're looking for a specific subject then skip to the feature
you want to know more about or use the side-panel navigation for more
in-depth documentation.

- Core functions
  - [Decoding](#decode-json)
  - [Encoding](#encode-json)
  - [Formatting](#format-json)

- Code generation
  - [Class](#generate-data-class-from-json)
  - [Serializer](#generate-serialization-code)

- Advanced functions
  - [Analyzer](#analyzer)
  - [Command-line](#command-line-usage)

We'll use the following example JSON to examine Squint's key features:

```json
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
  "foo": null
}
```

## Decode JSON

One of the main features of Squint is it's decoding ability.
Decoding is done by using the jsonDecode extension method on a String variable.

```dart
// Variable 'json' is our actual JSON String.
final JsonObject object = json.jsonDecode;
```

Or alternatively use toJsonObject instead of the jsonDecode extension.

```dart
// Variable 'json' is our actual JSON String.
final JsonObject object = toJsonObject(json);
```

The result is a JsonObject containing all data. 
> A JsonObject is a wrapper around the JSON
elements. Each key-value pair is stored in a JsonElement. See [AST](ast.md) for more 
information about JsonElements and JsonElementTypes.

There are 2 ways to interact with decoded data:
- Get raw values directly
- Get typed JsonNodes and access data from there

Let's take the long way first. To access data we need to specify the data-type and key.

```dart
    // Getter integer will return a JsonIntegerNumber
    assert(object.integerNode("id").key == "id");
    assert(object.integerNode("id").data == 1);
```

In this example we retrieve the JsonNode for tag key **id**. We know it's an integer value, so we 
use the **integer** getter. If tried to retrieve a boolean value using this integer getter, then Squint
would throw an exception and fail. We can see the JsonNode, which is a JsonIntegerNumber subclass, 
contains both the key and value data.

For easier access it's also possible to get the value immediately.

```dart
  assert(object.integer("id") == 1);
```

There's a getter for boolean values.

```dart
  assert(object.boolean("isJedi") == true);
  assert(object.boolean("hasPadawan") == false);
```

There's a getter for String values.

```dart
  assert(object.string("bff") == "Leia");
```

If a value is nullable then it can be accessed safely by appending the correct getter with **orNull**.

```dart
  assert(object.stringOrNull("foo") == null);
```

But requesting data by key that does not exist will always result in a SquintException being thrown.

```dart
  // This will throw a SquintException 
  // because our JSON does not contain this key.
  object.stringOrNull("does-not-exist") == null;
```

> Requesting data by key that does not exist will always result in a SquintException being thrown.
> If a value is nullable however then it can be accessed safely by appending the correct getter with **orNull**.

Accessing Lists can be done with the array getter. The child type has to be specified as Type Parameter.
The top level List is implied so does not have to be included. 

```dart
// IDE will report: Unnecessary type check; the result is always 'true'.
assert(object.array<String>("jedi") is List<String>);

assert(object.array<String>("jedi")[0] == "Obi-Wan");
assert(object.array<String>("jedi")[1] == "Anakin");
assert(object.array<String>("jedi")[2] == "Luke Skywalker");

// Notice how all values are casted to double
// even though they're not all floating point numbers.
assert(object.array<double>("coordinates")[0] == 22);
assert(object.array<double>("coordinates")[1] == 4.4);
assert(object.array<double>("coordinates")[2] == -15);
```

Finally, we can access JSON Objects with the objectNode getter.

```dart
    assert(object.objectNode("objectives").boolean("in-mission") == false);
    assert(object.objectNode("objectives").array<bool>("mission-results")[0] == false);
    assert(object.objectNode("objectives").array<bool>("mission-results")[1] == true);
```

Objects nested inside a List are also no problem.

```dart
assert(object.array<Map<String,int>>("annoyance-rate")[0]["JarJarBinks"] == 9000);
```

## Encode JSON

Use stringify to output a JSON String from a JsonObject.

```dart
// Variable 'json' is our actual JSON String.
final JsonObject object = json.jsonDecode;

// Encode JsonObject to formatted JSON String.
print(object.stringify);
```

## Format JSON

Use stringifyWithFormatting to customize the JSON formatting.

```dart
// Variable 'json' is our actual JSON String.
final JsonObject object = json.jsonDecode;

// Encode JsonObject to formatted JSON String.
// Specifying standardJsonFormatting like this 
// is redundant because that is the default formatting.
print(object.stringifyWithFormatting(standardJsonFormatting));
```

The stringifyWithFormatting method expects a JsonFormattingOptions instance.
The easiest way to do minor tweaks is using the copyWith instance method.

```dart
// Variable 'json' is our actual JSON String.
final JsonObject object = json.jsonDecode;

// Encode JsonObject to formatted JSON String.
// Set the indentation size to double space.
print(
  object.stringifyWithFormatting(
    standardJsonFormatting.copyWith(
      indentationSize: JsonIndentationSize.doubleSpace,
    ),
  )
);
```

## Generate data class from JSON

Using data classes instead of raw JSON data is beneficial because of the enforced type safety. 
Writing one is a repetitive and mostly boring task. Would it not be nice to generate a simple class
based on a JSON String? Squint can do just that.

```dart
// Variable 'json' is our actual JSON String.
final JsonObject object = json.jsonDecode;

// Convert a JsonObject to a CustomType object (AST model).
final CustomType customType = object.toCustomType(className: "Example");

// Convert a CustomType to a .dart File.
print(customType.generateDataClassFile());
```

This will print the following .dart file:

```dart
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

JsonObject encodeObjectives(Objectives objectives) =>
    JsonObject.fromNodes(nodes: [
      JsonBoolean(key: "in-mission", data: objectives.inMission),
      JsonArray<dynamic>(
          key: "mission-results", data: objectives.missionResults),
    ]);

Objectives decodeObjectives(JsonObject object) => Objectives(
  inMission: object.boolean("in-mission"),
  missionResults: object.array<bool>("mission-results"),
);
```

Not all type information can be inferred by reading a JSON file. In our JSON example
we have an element named **foo**, but its value is null. There's no way of determining
the actual data type. Squint will generate a **dynamic** type field in those cases.

## Generate serialization code

To (de)serialize from/to JSON, Squint can generate extension methods.

```dart
    // Variable 'json' is our actual JSON String.
    final JsonObject object = json.jsonDecode;
    
    // Convert a JsonObject to a CustomType object (AST model).
    final CustomType customType = object.toCustomType(className: "Example");

    // Generate extenions methods.
    // Notice the relativeImport variable which is required to import the dart file
    // containing the dataclass to be encoded/decoded.
    print(customType.generateJsonDecodingFile(relativeImport: "example.dart"));

```

This will print the following .dart file:

```dart

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

import 'example.dart';
import 'package:squint_json/squint_json.dart';

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
    );
}
```

Encoding and decoding is now as simple as:

```dart
    // Deserialize JSON String to an Example instance.
    final Example example = json.toExample;

    // Encode the Example instance to a JsonObject.
    final JsonObject exampleJsonObject = example.toJsonObject;

    // Serialize the Example instance to a JSON String.
    final String exampleJson = example.toJson;
```

## Analyzer

The analyzer can read files and return metadata about (dart) classes.
This metadata can then be read and written as JSON files. The analyzer supports:
1. Any .dart file containing valid dart classes.
2. Metadata file in AST JSON format (see [AST](ast.md) documentation).

> The simplified metadata only contains information about data classes, meaning
their field names, types and nullability. The lack of complexity greatly simplifies
processing this data.

Using JSON as input/output makes it easier to use the analyzer in conjunction with other
tools in different programming languages. For example analysis could be done on Kotlin data classes
using a Kotlin compiler plugin which then stores the result as JSON. The Squint analyzer can then
read this metadata JSON and generate dart code (see [Generator](generator.md)).

```dart
import "package:squint_json/squint_json.dart";

void main() {
  final metadata = analyze(pathToFile: "foo/bar.dart");

  for(final object in metadata) {
    print(object); // Calls toString method of CustomType
  }
}

```

See [Analyzer](analyzer.md) for more information and examples.

## Command-line usage

Analysis and code generation is accessible through command-line.
Tasks should be specified in lowercase:
- analyze
- generate

Arguments are case-insensitive if possible (for example: true, TRUE, True are all valid boolean values).
The following is an extensive list of all possible commands.

### Analyzer

Analyze some_class_file.dart and store the output in foo/bar/output.

```shell
flutter pub run squint_json:analyze --input foo/some_class_file.dart --output foo/bar/output
```

Analyze some_class_file.dart, store the output in foo/bar/output and allow existing metadata JSON files to be overwritten.

```shell
flutter pub run squint_json:analyze --input foo/some_class_file.dart --output foo/bar/output --overwrite true
```

Analyze some_class_file.dart, store the output in foo/bar/output and do NOT allow existing metadata JSON files to be overwritten.

```shell
flutter pub run squint_json:analyze --input foo/some_class_file.dart --output foo/bar/output --overwrite false
```

> Specifying --overwrite false is redundant because false is the default setting.

### Generate

Generate a data class for a JSON File and save the output in folder foo.

```shell
flutter pub run squint_json:generate --type dataclass --input foo/example.json
```

Generate a data class for a JSON String and save the output in the current folder.

```shell
flutter pub run squint_json:generate --type dataclass --input '{
  "id": 1,
  "isJedi": true,
  "hasPadawan": false,
  "bff": "Leia",
  "jedi": [
    "Obi-Wan",
    "Anakin",
    "Luke Skywalker"
  ],
  "coordinates": [
    22,
    4.4,
    -15
  ],
  "objectives": {
    "in-mission": false,
    "mission-results": [
      false,
      true,
      true,
      false
    ]
  },
  "annoyance-rate": [
    { "JarJarBinks" : 9000 }
  ],
  "foo": null
}'
```

Generate a data class for a JSON File and save the output in folder foo/bar.

```shell
flutter pub run squint_json:generate --type dataclass --input foo/example.json --output foo/bar
```

Generate a data class and add a blank line between each field.

```shell
flutter pub run squint_json:generate --type dataclass --input foo/example.json --blankLineBetweenFields true
```

> See [Generator](generator.md) for setting generator options and examples of generated code.

Generate a data class and add @JsonValue annotation to each field. By default, @JsonValue will only 
be added to fields which have a different name in the JSON String and in the data class. For example
annoyance-rate in JSON will be generated as annoyanceRate in the data class and have @JsonValue("annoyance-rate").

```shell
flutter pub run squint_json:generate --type dataclass --input foo/example.json --alwaysAddJsonValue true
```

Generate a data class without any annotations.

```shell
flutter pub run squint_json:generate --type dataclass --input foo/example.json --includeJsonAnnotations false
```

> Squint will normalize JSON keys to be valid dart field names. If --includeJsonAnnotations is set to false
then the generated code might not be compatible with the JSON file.

Generate (de)serializer extensions for a data class and save the output in folder foo/bar.

```shell
flutter pub run squint_json:generate --type serializer --input foo/example.dart --output foo/bar
```

Generate (de)serializer extensions for a data class and save the output in folder foo/bar.