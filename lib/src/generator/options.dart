// Copyright (c) 2021 - 2022 Buijs Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/// Options to configure code generation.
///
/// {@category generator}
class SquintGeneratorOptions {
  /// Construct a [SquintGeneratorOptions] instance.
  const SquintGeneratorOptions({
    required this.includeJsonAnnotations,
    required this.alwaysAddJsonValue,
    required this.blankLineBetweenFields,
    required this.generateChildClasses,
    required this.includeCustomTypeImports,
  });

  /// Include @JsonValue, @JsonEncode and @JsonDecode
  /// annotations on generated data classes.
  ///
  /// When disabled a data class will be generated without
  /// any of these annotations.
  ///
  /// When enabled then annotations will be added where applicable.
  ///
  /// {@category generator}
  final bool includeJsonAnnotations;

  /// Is ignored when [includeJsonAnnotations] is set to false.
  ///
  /// When [alwaysAddJsonValue] is false then @JsonValue will only be added
  /// when the JSON node key and generated TypeMember name are not identical.
  ///
  /// Example:
  ///
  /// Given a JSON node:
  ///
  /// "metallica":"awesome"
  ///
  /// With [alwaysAddJsonValue] set to true will return:
  ///
  /// ```
  /// @JsonValue("metallica"
  /// final String metallica;
  /// ```
  ///
  /// But with [alwaysAddJsonValue] set to false will return:
  ///
  /// ```
  /// final String metallica;
  /// ```
  ///
  /// TypeMember name and JSON node key are identical so @JsonValue is not mandatory.
  ///
  /// Given a JSON node:
  ///
  /// "metallica-awesome":"doh!"
  ///
  /// With [alwaysAddJsonValue] set to false will still return:
  ///
  /// ```
  /// @JsonValue("metallica"
  /// final String metallica;
  /// ```
  ///
  /// TypeMember name and JSON node key are different so the @JsonValue is added.
  /// To disable adding annotations entirely set [includeJsonAnnotations] to false.
  ///
  /// {@category generator}
  final bool alwaysAddJsonValue;

  /// Add a blank line between data class fields.
  ///
  /// Example with blank lines if [blankLineBetweenFields] is set to true:
  ///
  /// ```
  /// class MyExample {
  ///   ... constructor omitted...
  ///
  /// final String foo;
  ///
  /// final String bar;
  ///
  /// @JsonValue("need-caffeine")
  /// final double espresso;
  ///
  /// }
  /// ```
  ///
  /// {@category generator}
  final bool blankLineBetweenFields;

  /// Configure to generate child classes or not.
  ///
  /// If set to true then a data class will be
  /// generated for every CustomType child.
  ///
  /// Example:
  ///
  /// Given this class containing a TypeMember with data type SomethingElse:
  ///
  /// ```
  /// @squint
  /// class Something {
  ///   const Something({
  ///     required this.y,
  ///   });
  ///
  ///   final SomethingElse y;
  /// }
  /// ```
  ///
  /// Will generate a data class if [generateChildClasses] is set to true:
  ///
  /// ```
  /// @squint
  /// class SomethingElse {
  ///   const SomethingElse({
  ///     ... code omitted for brevity
  ///   });
  ///
  /// }
  /// ```
  ///
  /// If set to false then only the parent class will be generated.
  final bool generateChildClasses;

  /// Configure to add import statements for each TypeMember CustomType/EnumType.
  ///
  /// Will be overridden to false if [generateChildClasses] is set to true.
  ///
  /// If set to true then import statements will be added for each
  /// CustomType and/or EnumType.
  ///
  /// Example:
  ///
  /// Given this class containing a TypeMember with data type SomethingElse:
  ///
  /// ```
  /// @squint
  /// class Something {
  ///   const Something({
  ///     required this.y,
  ///   });
  ///
  ///   final SomethingElse y;
  /// }
  /// ```
  ///
  /// Will add an import statement if [includeCustomTypeImports] is set to true:
  ///
  /// ```
  /// import 'something_else_dataclass.dart';
  /// ```
  ///
  /// If set to false then only the parent class will be generated.
  final bool includeCustomTypeImports;
}

/// Default code generation options.
///
/// {@category generator}
const standardSquintGeneratorOptions = SquintGeneratorOptions(
  includeJsonAnnotations: true,
  alwaysAddJsonValue: true,
  blankLineBetweenFields: true,
  generateChildClasses: true,
  includeCustomTypeImports: false,
);

/// Generate data class without annotations.
///
/// {@category generator}
const noAnnotationsGeneratorOptions = SquintGeneratorOptions(
  includeJsonAnnotations: false,
  alwaysAddJsonValue: false,
  blankLineBetweenFields: false,
  generateChildClasses: true,
  includeCustomTypeImports: false,
);

/// Builder to customize [SquintGeneratorOptions]
/// without building an instance from scratch.
///
/// {@category generator}
extension SquintGeneratorOptionsBuilder on SquintGeneratorOptions {
  /// Copy the [standardSquintGeneratorOptions] with custom overrides.
  ///
  /// {@category generator}
  SquintGeneratorOptions copyWith({
    bool? includeJsonAnnotations,
    bool? alwaysAddJsonValue,
    bool? blankLineBetweenFields,
    bool? generateChildClasses,
    bool? includeCustomTypeImports,
  }) =>
      SquintGeneratorOptions(
        includeJsonAnnotations: includeJsonAnnotations ??
            standardSquintGeneratorOptions.includeJsonAnnotations,
        alwaysAddJsonValue: alwaysAddJsonValue ??
            standardSquintGeneratorOptions.alwaysAddJsonValue,
        blankLineBetweenFields: blankLineBetweenFields ??
            standardSquintGeneratorOptions.blankLineBetweenFields,
        generateChildClasses: generateChildClasses ??
            standardSquintGeneratorOptions.generateChildClasses,
        includeCustomTypeImports: includeCustomTypeImports ??
            standardSquintGeneratorOptions.includeCustomTypeImports,
      );
}
