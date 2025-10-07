## 0.1.4
- Remove obsolete path dependency.
- Set analyzer dependency range to '>=7.0.0 <9.0.0'
- Bugfix: JsonObject getters to retrieve data as Map should not return any JsonNode type.

## 0.1.3
- Bump Flutter SDK range to ">=3.0.0 <4.0.0".
- Bump dependencies.
- Bugfix: incorrect import statements in generated serializer code.
- Bugfix: correctly mark nullable ComplexType and EnumType fields when generating code based on AST metadata.
- Bugfix: type-member information is potentially lost when generating code resulting in empty data classes.

## 0.1.2
- Add support for generating enum extensions.
- Bugfix: Incorrect bracket count when processing Maps nested inside Lists.

## 0.1.1
- Add support for enumerated objects (Map<enum, dynamic).
- Add none value to generated enumerations to avoid throwing exceptions.
- Bugfix: missing imports in generated dataclass when CustomType/EnumType is nested inside a List or Map.

## 0.1.0
- Add JsonMissing class to allow nullable JSON elements to be absent.

## 0.0.6
- Add more squintGeneratorOptions.

## 0.0.5
- Bugfix: enum classes not generated when there is no data class.

## 0.0.4
- Bugfix: incorrect outputting of '??' instead of '?' for nullable dataclass fields.

## 0.0.3
- Downgrade path dependency to 1.8.2 to make it compatible with flutter_test.

## 0.0.2
- Add hasKey method to JsonObject.
- Add EnumType to AST.
- Add support for generating dataclasses from Metadata.
- Add support for generating dart enum classes.

## 0.0.1
- Initial version.
