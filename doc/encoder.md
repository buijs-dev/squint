The encoder will generate formatted JSON Strings.

# Examples

## Example 1

Encode a JsonObject with .stringify, and it will be formatted using standardJsonFormatting.

```dart
final object = JsonObject.elements([
  const JsonString(key: "foo", data: "hello"),
  const JsonBoolean(key: "isOk", data: true),
  const JsonArray<dynamic>(key: "random", data: [1,0,33]),
]);

// when:
final json = object.stringify;

// then:
expect(json, """
{
    "foo" : "hello",
    "isOk" : true,
    "random" : [
        1,
        0,
        33
    ]
}""");
```

## Example 2

Encode a JsonObject with .stringifyWithFormatting, and it will be formatted using custom formatting.
Use standardJsonFormatting.copyWith to use the standardJsonFormatting as base and only alter what you require.

```dart
  // given:
final object = JsonObject.elements([
  const JsonString(key: "foo", data: "hello"),
  const JsonBoolean(key: "isOk", data: true),
  const JsonArray<dynamic>(key: "random", data: [1,0,33]),
]);

// when:
final json = object.stringifyWithFormatting(
    standardJsonFormatting.copyWith(
      indentationSize: JsonIndentationSize.doubleSpace,
      colonPadding: 20,
    )
);

// then:
expect(json, """
{
  "foo"                    :                    "hello",
  "isOk"                    :                    true,
  "random"                    :                    [
    1,
    0,
    33
  ]
}""");
```