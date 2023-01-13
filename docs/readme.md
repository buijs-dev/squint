Lightweight JSON processor and AST.
Safely deserialize JSON decoded Strings to Dart Types.
A JSON decoding library that actually decodes nested lists.
**No more dynamic mapping!**

````dart

const example = """
{
  "aRidiculousListOfLists": [ [ [ [ "Lugia", "Ho-Oh" ], [ "Pikachu!" ] ] ] ]
}""";

final decoded = example.jsonDecode;
final myArray = decoded.array("aRidiculousListOfLists");
expect(myArray.data[0][0][0][0], "Lugia");
expect(myArray.data[0][0][0][1], "Ho-Oh");

````

# Features
- Deserialize JSON properly including (nested) arrays.
- Deserialize JSON without writing data classes.
- Generate data classes from JSON content.
- Generate boilerplate for JSON processing programmatically.
- Generate boilerplate for JSON processing through cli.
- Format JSON messages.
- Does not require build_runner.
- Does not require dart:mirrors.
- Extensible: Write and reuse custom JSON data converters.