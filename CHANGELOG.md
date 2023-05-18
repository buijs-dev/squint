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
