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
class SquintGeneratorOptions {
  /// Construct a [SquintGeneratorOptions] instance.
  const SquintGeneratorOptions({
    required this.includeJsonAnnotations,
    required this.alwaysAddJsonValue,
    required this.blankLineBetweenFields,
  });

  /// Include @JsonValue, @JsonEncode and @JsonDecode
  /// annotations on generated data classes.
  ///
  /// When disabled a data class will be generated without
  /// any of these annotations.
  ///
  /// When enabled then annotations will be added where applicable.
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
  final bool blankLineBetweenFields;
}

/// Default code generation options.
const standardSquintGeneratorOptions = SquintGeneratorOptions(
  includeJsonAnnotations: true,
  alwaysAddJsonValue: true,
  blankLineBetweenFields: true,
);

/// Generate data class without annotations.
const noAnnotationsGeneratorOptions = SquintGeneratorOptions(
  includeJsonAnnotations: false,
  alwaysAddJsonValue: false,
  blankLineBetweenFields: false,
);

/// Builder to customize [SquintGeneratorOptions]
/// without building an instance from scratch.
extension SquintGeneratorOptionsBuilder on SquintGeneratorOptions {
  /// Copy the [standardSquintGeneratorOptions] with custom overrides.
  SquintGeneratorOptions copyWith({
    bool? includeJsonAnnotations,
    bool? alwaysAddJsonValue,
    bool? blankLineBetweenFields,
  }) =>
      SquintGeneratorOptions(
        includeJsonAnnotations: includeJsonAnnotations ??
            standardSquintGeneratorOptions.includeJsonAnnotations,
        alwaysAddJsonValue: alwaysAddJsonValue ??
            standardSquintGeneratorOptions.alwaysAddJsonValue,
        blankLineBetweenFields: blankLineBetweenFields ??
            standardSquintGeneratorOptions.blankLineBetweenFields,
      );
}
