Code generation tools for JSON (de)serialization boilerplate.
All generators use AST objects as input. The [analyzer](analyzer.md) can read
metadata or .dart files and return it as AST objects. Generators
can then be used to use these objects to generate boilerplate code.

Tools:
- [Generate (de)serialization extension](#(De)serialization)

# (De)serialization
Even though (de)serialization is simplified by the Squint [decoder](decoder.md)/[encoder](encoder.md), 
it still requires some amount of boilerplate to be written. Thankfully this code can be generated.

Requirements:
- Class is annotated with @squint.
- There is one constructor.
- All fields to be (de)serialized are present in said constructor.
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

Example:

Given the following dart class:

```dart
@squint
class TestingExample {
  const TestingExample({
    required this.foo,
    required this.isOk,
    required this.random,
    required this.multiples,
    required this.counters,
  });

  final String foo;
  final bool isOk;
  final List<double> random;
  final List<List<String>> multiples;
  final Map<String, double> counters;
}
```

Using the cli command:
```shell
flutter pub run generate:foo/bar/testing_example.dart
```

Should generate the following code:
```dart
extension _TestExampleJsonBuilder on _TestingExample {
  JsonObject get toJsonObject => JsonObject.elements([
    JsonString(key: "foo", data: foo),
    JsonBoolean(key: "isOk", data: isOk),
    JsonArray<dynamic>(key: "random", data: random),
    JsonArray<dynamic>(key: "multiples", data: multiples),
    JsonObject.fromMap(counters, "counters"),
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
  );
}
```

Example with annotations:

Given the following dart class:

```dart
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

JsonNumber _encodeId(int id) =>
        JsonNumber(key: "id", data: id.toDouble());

int _decodeId(JsonFloatingNumber id) =>
        id.data.toInt();
```

Using the cli command:
```shell
flutter pub run generate:foo/bar/testing_example.dart
```

Should generate the following code:
```dart
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
    noIdea: _decodeId(floating("id")),
  );
}
```