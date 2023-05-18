// Copyright (c) 2021 - 2023 Buijs Software
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

import "../ast/ast.dart";
import "../common/common.dart";
import "generator.dart";

/// Convert a [EnumType] to an enum class.
///
/// {@category generator}
extension EnumType2EnumClass on EnumType {
  /// Generate data class from [EnumType].
  ///
  /// {@category generator}
  String generateEnumClassFile({
    SquintGeneratorOptions options = standardSquintGeneratorOptions,
  }) {
    final buffer = StringBuffer()..write("""
      |// Copyright (c) 2021 - 2023 Buijs Software
      |//
      |// Permission is hereby granted, free of charge, to any person obtaining a copy
      |// of this software and associated documentation files (the "Software"), to deal
      |// in the Software without restriction, including without limitation the rights
      |// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      |// copies of the Software, and to permit persons to whom the Software is
      |// furnished to do so, subject to the following conditions:
      |//
      |// The above copyright notice and this permission notice shall be included in all
      |// copies or substantial portions of the Software.
      |//
      |// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      |// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      |// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      |// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      |// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      |// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
      |// SOFTWARE.
      |
      |import 'package:squint_json/squint_json.dart';
      |
      |/// Autogenerated enum class by Squint.
      ${generateEnumClassBody(options)}""");

    return buffer.toString().formattedDartCode;
  }

  /// Generate data class from [CustomType].
  ///
  /// {@category generator}
  String generateEnumClassBody(SquintGeneratorOptions options) {
    if (values.length != valuesJSON.length) {
      throw SquintException(
        "Failed to generate enum class because values and valuesJSON are not of equal size.",
      );
    }

    var hasJsonValues = false;
    var index = 0;

    while (index < values.length) {
      if (values[index] != valuesJSON[index]) {
        hasJsonValues = true;
      }
      index += 1;
    }

    return hasJsonValues
        ? _enumWithAnnotations(options)
        : _enumWithoutAnnotations(options);
  }

  String _enumWithoutAnnotations(SquintGeneratorOptions options) =>
      _generateEnumerationClass(
          className: className, members: values..add("none"));

  String _enumWithAnnotations(SquintGeneratorOptions options) {
    final members = <String>[];

    var index = 0;

    while (index < values.length) {
      members.add("""@JsonValue("${valuesJSON[index]}") ${values[index]}""");
      index += 1;
    }
    members.add("""@JsonValue("") none""");
    return _generateEnumerationClass(className: className, members: members);
  }

  String _generateEnumerationClass({
    required String className,
    required List<String> members,
  }) =>
      "@squint\nenum $className {${members.join(",")}}";
}
