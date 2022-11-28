[![GitHub](https://img.shields.io/github/license/buijs-dev/squint?color=black)](https://github.com/buijs-dev/squint/blob/main/LICENSE)
[![CodeScene Code Health](https://codescene.io/projects/32221/status-badges/code-health)](https://codescene.io/projects/32221)
[![codecov](https://codecov.io/gh/buijs-dev/squint/branch/main/graph/badge.svg?token=yxUBpDvGFg)](https://codecov.io/gh/buijs-dev/squint)

Lightweight JSON processing code generator. 
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

<B>Important:</B> Unpublished library, this is a POC.

# Features
- [x] Deserialize JSON properly, including (nested) arrays.
- [ ] Serialize to JSON without implementing toJson/fromJson methods using Squint.
- [x] Generate data class from JSON content.
- [x] Format JSON messages.