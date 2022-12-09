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
  squint: ^0.0.1
```

## Features
The following steps can be followed as a short tutorial.
It will cover all main features of Squint.
If you're looking for a specific subject then skip to the feature
you want to know more about or use the side-panel navigation for more
in-depth documentation.

- [Decode JSON](#Decode%20JSON)
- [Encode JSON](#Encode%20JSON)
- [Format JSON](#Format%20JSON)
- [Generate data class from JSON](#Generate%20data%20class%20from%20JSON)
- [Generate serialization code](Generate%20serialization%20code)

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

The result is a JsonObject containing all data. 
> A JsonObject is a wrapper around the JSON
elements. Each key-value pair is stored in a JsonElement. See [AST](ast.md) for more 
information about JsonElements and JsonElementTypes.

There are 2 ways to interact with decoded data:
- Get raw values directly
- Get typed JsonElements and access data from there

Let's take the long way first. To access data we need to specify the data-type and key.

```dart
    // Getter integer will return a JsonIntegerNumber
    assert(object.integer("id").key == "id");
    assert(object.integer("id").data == 1);
```

In this example we retrieve the JsonElement for tag key **id**. We know it's an integer value, so we 
use the **integer** getter. If tried to retrieve a boolean value using this integer getter, then Squint
would throw an exception and fail. We can see the JsonElement, which is a JsonIntegerNumber subclass, 
contains both the key and value data.

For easier access it's also possible to get the value immediately.

```dart
  assert(object.integerValue("id") == 1);
```

There's a getter for boolean values.

```dart
  assert(object.booleanValue("isJedi") == true);
  assert(object.booleanValue("hasPadawan") == false);
```

There's a getter for String values.

```dart
  assert(object.stringValue("bff") == "Leia");
```

If a value is nullable then it can be accessed safely by appending the correct getter with **orNull**.

```dart
  assert(object.stringValueOrNull("foo") == null);
```

But requesting data by key that does not exist will always result in a SquintException being thrown.

```dart
  // This will throw a SquintException 
  // because our JSON does not contain this key.
  object.stringValueOrNull("does-not-exist") == null;
```

> Requesting data by key that does not exist will always result in a SquintException being thrown.
> If a value is nullable however then it can be accessed safely by appending the correct getter with **orNull**.

Accessing Lists can be done with the array getter. The child type has to be specified as Type Parameter.
The top level List is implied so does not have to be included. 

```dart
// IDE will report: Unnecessary type check; the result is always 'true'.
assert(object.arrayValue<String>("jedi") is List<String>);

assert(object.arrayValue<String>("jedi")[0] == "Obi-Wan");
assert(object.arrayValue<String>("jedi")[1] == "Anakin");
assert(object.arrayValue<String>("jedi")[2] == "Luke Skywalker");

// Notice how all values are casted to double
// even though they're not all floating point numbers.
assert(object.arrayValue<double>("coordinates")[0] == 22);
assert(object.arrayValue<double>("coordinates")[1] == 4.4);
assert(object.arrayValue<double>("coordinates")[2] == -15);
```

Finally, we can access JSON Objects with the object getter.

```dart
    assert(object.object("objectives").booleanValue("in-mission") == false);
    assert(object.object("objectives").arrayValue<bool>("mission-results")[0] == false);
    assert(object.object("objectives").arrayValue<bool>("mission-results")[1] == true);
```

Objects nested inside a List are also no problem.

```dart
assert(object.arrayValue<dynamic>("annoyance-rate")[0]["JarJarBinks"] == 9000);
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
final CustomType customType = object.toCustomType(className: "MyExample");

// Convert a CustomType to a .dart File.
print(customType.generateDataClassFile);
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

import 'package:squint/squint.dart';

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
    this.foo,
  });

  final int id;
  final bool isJedi;
  final bool hasPadawan;
  final String bff;
  final List<String> jedi;
  final List<double> coordinates;

  @JsonEncode(using: _encodeObjectives)
  @JsonDecode<Objectives, JsonObject>(using: _decodeObjectives)
  final Objectives objectives;
  final List<Map<String, int>> annoyanceRate;
  final dynamic foo;
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

JsonObject _encodeObjectives(Objectives objectives) => JsonObject.elements([
  JsonBoolean(key: "inMission", data: objectives.inMission),
  JsonArray<dynamic>(
      key: "missionResults", data: objectives.missionResults),
], "objectives");

Objectives _decodeObjectives(JsonObject object) => Objectives(
  inMission: object.booleanValue("in-mission"),
  missionResults: object.arrayValue<bool>("mission-results"),
);
```

Not all type information can be inferred by reading a JSON file. In our JSON example
we have an element named **foo**, but its value is null. There's no way of determining
the actual data type. Squint will generate a **dynamic** type field in those cases.

## Generate serialization code

It is possible to generate serialization methods. The data class should follow a few simple rules to do so:
- Class is annotated with @squint.
- There is one constructor with all fields to be (de)serialized.
- All fields are either:
    - of type:
        - String
        - int
        - double
        - bool
        - List
        - Map
    - or annotated with both:
        - @JsonEncode
        - @JsonDecode

For configuring JSON property names, fields can be annotated with @JsonValue.


Let's say we have a data class in path foo/bar/my_example.dart. 
This data class has the following content:

```dart
import 'package:squint/squint.dart';

@squint
class MyExample {
  const MyExample({
    required this.id,
    required this.isJedi,
    required this.hasPadawan,
    required this.bff,
    required this.jedi,
    required this.coordinates,
    required this.objectives,
    required this.annoyanceRate,
  });

  final int id;
  final bool isJedi;
  final bool hasPadawan;
  final String bff;
  final List<String> jedi;
  final List<double> coordinates;

  @JsonEncode(using: _encodeObjectives)
  @JsonDecode<Objectives, JsonObject>(using: _decodeObjectives)
  final Objectives objectives;
  final List<Map<String, int>> annoyanceRate;
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

JsonObject _encodeObjectives(Objectives objectives) => JsonObject.elements([
  JsonBoolean(key: "inMission", data: objectives.inMission),
  JsonArray<dynamic>(
      key: "missionResults", data: objectives.missionResults),
], "objectives");

Objectives _decodeObjectives(JsonObject object) => Objectives(
  inMission: object.booleanValue("in-mission"),
  missionResults: object.arrayValue<bool>("mission-results"),
);
```

We can then generate
the extension methods by running the following from command line:

```shell
flutter pub run squint:generate foo/bar/my_example.dart
```