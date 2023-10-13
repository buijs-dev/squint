The analyzer can read files and return metadata about (dart) classes.
This metadata can then be read and written as JSON files. The analyzer supports:
1. Any .dart file containing valid dart classes.
2. Metadata file in AST JSON format (see [AST](ast.md) documentation).

<b>What's the point?</b></br>
The simplified metadata only contains information about data classes, meaning
their field names, types and nullability. The lack of complexity greatly simplifies
processing this data.

Using JSON as input/output makes it easier to use the analyzer in conjunction with other
tools in different programming languages. For example analysis could be done on Kotlin data classes 
using a Kotlin compiler plugin which then stores the result as JSON. The Squint analyzer can then
read this metadata JSON and generate dart code (see [Generator](generator.md)).

### Using analyzer programmatically

The analyzer returns CustomType instances which can be used to generate code or do other operations.

```dart
import "package:squint_json/squint_json.dart";

void main() {
  final metadata = analyze(pathToFile: "foo/bar.dart");

  for(final object in metadata) {
    // Calls toString method of CustomType
    print(object); 
  }
}
```

Analysing String content directly is also possible.

```dart
import "package:squint_json/squint_json.dart";

void main() {
  const content = """
    class SimpleResponse {
      SimpleResponse({
        required this.a1,
        this.a2,
      });
    
      final int a1;
      final String? a2;
    }
  """;
  
  final metadata = analyze(fileContent: content);

  for(final object in metadata) {
    // Calls toString method of CustomType
    print(object);
  }
}
```

> Note that analyzing code will fail if the code is not valid dart. 
> This includes errors like missing imports, brackets or other syntactical issues.

The analysis result can be stored as JSON metadata by specifying an output folder. A File will be created for each CustomType.

```dart
import "package:squint_json/squint_json.dart";

void main() {
  analyze(
    pathToFile: "foo/bar.dart",
    pathToOutputFolder: "foo/metadata",
  );
  
  // Metadata JSON is now stored in foo/metadata.
}
```

By default, existing metadata files will not be overwritten. This can be changed by setting the overwrite parameter.

```dart
import "package:squint_json/squint_json.dart";

void main() {
  analyze(
      pathToFile: "foo/bar.dart",
      pathToOutputFolder: "foo",
      overwrite: true,
  );
}
```

> A SquintException is thrown if overwrite parameter is not specified (or set to false) and the metadata JSON is already present.

### Using analyzer from cli

To analyse a file from the command-line, one should specify an input file and an output folder using --input and --output respectively.

```shell
flutter pub run squint_json:analyze --input foo/some_class_file.dart --output foo/bar/output
```

Use --overwrite parameter to allow overriding existing metadata JSON files.

```shell
flutter pub run squint_json:analyze --input foo/some_class_file.dart --output foo/bar/output --overwrite true
```

### Examples
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
- members: IntType a1, NullableStringType a2

Given a valid CustomType metadata JSON:

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
- members: IntType a1, NullableStringType a2

Given a valid EnumType metadata JSON:

```json
 {
  "className": "MyResponse",
  "values": [ 
    "FOO",
    "BAR"
  ],
  "valuesJSON": [
    "foo",
    "bar"
  ]
}
```

Will return a CustomType instance:
- className: MyResponse
- values: "FOO", "BAR"
- valuesJSON: "foo", "bar"

> The valuesJSON list is optional which can be used to differentiate between
> member names of an enum and how they should be serialized in a JSON String.