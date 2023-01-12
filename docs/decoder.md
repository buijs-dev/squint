Decode a JSON String to a JsonObject.
The decoder will create all actual dart types, including nested lists and/or objects.
Any meaningless whitespace/formatting will be removed before parsing. Every JSON node is 
wrapped in a JsonElement, containing the key and data. See [AST](ast.md) for more
information about how types are mapped from JSON to dart.

One of the main features of Squint is it's decoding ability.
Using dart:convert library, the following will result in an exception
(type 'List\<dynamic>' is not a subtype of type 'List<List\<String>>' in type cast):

```dart
final json = '''
  {
      "multiples" : [
          [
              "hooray!"
          ]
      ]
  }
''';

List<List<String>> multiples = 
    jsonDecode(json)['multiples'] as List<List<String>>;
```

Every sublist requires casting to return the proper Dart type:

```dart
    List<List<String>> multiples = (jsonDecode(json)['multiples'] as List<dynamic>)
      .map((dynamic e) => (e as List<dynamic>)
        .map((dynamic e) => e as String)
        .toList()
    ).toList();
```

Squint automatically returns the correct data type. Given this JSON containing Lists, 
inside Lists, inside another List:

```json
{
    "xyz": [[["hi !", "aye" ], ["bye", "zzz"]] ]
}

```

Decoding it requires no extra casting:

```dart
final json = """
        {
            "xyz": [[["hi !", "aye" ], ["bye", "zzz"]] ]
        }""";

final decoded = json.jsonDecode;

final xyzArray = decoded.array<dynamic>("xyz");
expect(xyzArray.key, "xyz");

final dynamic data = xyzArray.data;
expect(data[0][0][0], "hi !");
expect(data[0][0][1], "aye");
expect(data[0][1][0], "bye");
expect(data[0][1][1], "zzz");
```

Bad formatting is ignored:

```dart
final json = """
        {
            "xyz": [
            [[
            "hi !", "aye" 
            
            
      ], [
      "bye"
      , "zzz"
      
      
      ]         ] 
      
      ]
        }""";

final decoded = json.jsonDecode;

final xyzArray = decoded.array<dynamic>("xyz");
expect(xyzArray.key, "xyz");

final dynamic data = xyzArray.data;
expect(data[0][0][0], "hi !");
expect(data[0][0][1], "aye");
expect(data[0][1][0], "bye");
expect(data[0][1][1], "zzz");
```

How to retrieve String, Boolean, Integer, Double, List and Map values:


```dart
const json = """
{
  "id": 1,
  "fake-data": true,
  "real_data": false,
  "greeting": "Welcome to Squint!",
  "instructions": [
    "Type or paste JSON here",
    "Or choose a sample above",
    "squint will generate code in your",
    "chosen language to parse the sample data"
  ],
  "numbers": [22, 4.4, -15],
  "objective": { 
    "indicator": false,
    "instructions": [false, true, true, false]
  },
  "objectList": [
    { "a" : 1 }
  ]
}""";

final decoded = json.jsonDecode;

final id = decoded.integer("id");
expect(id.key, "id");
expect(id.data, 1);

final fakeData = decoded.boolean("fake-data");
expect(fakeData.key, "fake-data");
expect(fakeData.data, true);

final realData = decoded.boolean("real_data");
expect(realData.key, "real_data");
expect(realData.data, false);

final greeting = decoded.string("greeting");
expect(greeting.key, "greeting");
expect(greeting.data, "Welcome to Squint!");

final instructions = decoded.array<String>("instructions");
expect(instructions.key, "instructions");
expect(instructions.data[0], "Type or paste JSON here");
expect(instructions.data[1], "Or choose a sample above");
expect(instructions.data[2], "squint will generate code in your");
expect(instructions.data[3], "chosen language to parse the sample data");

final numbers = decoded.array<double>("numbers");
expect(numbers.key, "numbers");
// If any number in a List is a floating point,
// then they are all stored as double values.
expect(numbers.data[0], 22.0);
expect(numbers.data[1], 4.4);
expect(numbers.data[2], -15);

final objective = decoded.object("objective");
expect(objective.key, "objective");
expect(objective.boolean("indicator").data, false);
expect(objective.array<bool>("instructions").data[1], true);

final objectList = decoded.array<dynamic>("objectList");
expect(objectList.key, "objectList");
expect(objectList.data[0]["a"], 1);
```