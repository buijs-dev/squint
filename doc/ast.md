A simplified abstract syntax tree for code and JSON processing.
- [Code](#Code)
- [JSON](#JSON)

# Code
Every datatype is an AbstractType. An AbstractType stores the actual datatype name.
AbstractTypes are implemented by 
- StandardType
- CustomType 

## StandardType
StandardTypes are based on all types supported by the [standard message codec](https://api.flutter.dev/flutter/services/StandardMessageCodec-class.html).
Meaning all standard types are Dart types that support efficient binary serialization of simple JSON-like values.


| **AST**                 | **Dart**       |
|:------------------------|----------------|
| IntType                 | int            | 
| NullableIntType         | int?           | 
| DoubleType              | double         | 
| NullableDoubleType      | double?        | 
| StringType              | String         | 
| StringTypeType          | String?        |
| BooleanType             | bool           | 
| NullableBooleanType     | bool?          | 
| ListType                | List           | 
| NullableListType        | List?          | 
| MapType                 | Map            | 
| NullableMapType         | Map?           | 
| Uint8ListType           | Uint8List      | 
| NullableUint8ListType   | Uint8List?     | 
| Int32ListType           | Int32ListType  | 
| NullableInt32ListType   | Int32ListType? | 
| Int64ListType           | Int64ListType  | 
| NullableInt64ListType   | Int64ListType? | 
| Float32ListType         | Float32List    | 
| NullableFloat32ListType | Float32List?   | 
| Float64ListType         | Float64List    | 
| NullableFloat64ListType | Float64List?   | 

## CustomType
A custom type is a user defined class consisting of:
- Class name
- 1 or more fields (TypeMember)

A TypeMember has a name and a type (AbstractType).

Example:

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
- type: CustomType
- className: SimpleResponse
- members:
  - name: a1, type: IntType 
  - name: a2, type: NullableStringType

# JSON
The JSON AST types are used to encode/decode JSON. Decoding
JSON with Squint will return a JsonObject instance from which
child nodes can be accessed. All data is wrapped in JSON AST nodes.
This makes it easier to access (nested) data. Values are always strongly typed.
There is no dynamic mapping. Decoding a List inside a List inside a List, etc.
does not require multiple mapping.


| **AST**                         | **JSON**  |
|:--------------------------------|-----------|
| JsonObject                      | object    |
| JsonArray                       | array     |
| JsonString                      | string    |
| JsonNumber                      | number    |
| JsonNull                        | null      |
| JsonBoolean                     | boolean   |