[![GitHub](https://img.shields.io/github/license/buijs-dev/squint?color=black&style=for-the-badge)](https://github.com/buijs-dev/squint/blob/main/LICENSE)
[![Codecov](https://img.shields.io/codecov/c/github/buijs-dev/squint?logo=codecov&style=for-the-badge)](https://codecov.io/gh/buijs-dev/squint)

# Squint

Lightweight JSON processing code generator. Safely deserialize JSON decoded Strings to Dart Types.
A JSON decoding library that actually decodes nested lists. No more dynamic mapping!

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

<B>Important:</B> Unpublished library, this is a POC.

# Features
- [x] Deserialize JSON properly, including (nested) arrays.
- [ ] Serialize to JSON without implementing toJson/fromJson methods using Squint.
- [x] Generate data class from JSON content.
- [x] Format JSON messages.