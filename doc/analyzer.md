The analyzer can read files and return metadata about (dart) classes.
This metadata can then be read and written as JSON files. The analyzer supports:
1. Any .dart file containing valid dart classes.
2. Metadata file in AST JSON format (see [AST](../doc/ast.md) documentation).

<b>What's the point?</b></br>
The simplified metadata only contains information about data classes, meaning
their field names, types and nullability. The lack of complexity greatly simplifies
processing this data.

Using JSON as input/output makes it easier to use the analyzer in conjunction with other
tools in different programming languages. For example analysis could be done on Kotlin data classes 
using a Kotlin compiler plugin which then stores the result as JSON. The Squint analyzer can then
read this metadata JSON and generate dart code (see [generator](../doc/generator.md)).

### Using analyzer programmatically

```dart
import "../analyzer/analyzer.dart" as analyzer;

void analyze() {
  final metadata = analyzer.analyze(pathToFile);

  for(final object in metadata) {
    print(object); // Calls toString method of CustomType
  }
}

```

### Using analyzer from cli

```shell
flutter pub run squint:analyze foo/some_class_file.dart foo/bar/output
```

Analyzer reads a .dart file and returns a CustomType instance containing metadata.

Given a valid dart class declaration:

```dart
@squint
class SimpleResponse {
  ///
  SimpleResponse({
    required this.a1,
    this.a2,
  });

  final int a1;
  final String? a2;
}
```

Will return a CustomType instance:
- className: SimpleResponse
- members: [IntType a1, NullableStringType a2]

Analyzer reads a JSON file and returns a CustomType instance containing metadata.

Given a valid metadata file:

```json
 {
  "className": "MyResponse",
  "members": [ 
    {
        "name": "a1",
        "type": "int",
        "nullable": false
    },
    {
          "name": "a2",
          "type": "String",
          "nullable": true
    } 
  ]
}
```

Will return a CustomType instance:
- className: MyResponse
- members: [IntType a1, NullableStringType a2]