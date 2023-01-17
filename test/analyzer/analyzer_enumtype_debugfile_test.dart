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

import "dart:io";

import "package:squint_json/squint_json.dart";
import "package:squint_json/src/analyzer/analyzer.dart" as analyzer;
import "package:test/test.dart";

void main() {
  test("Analyze Enum", () {
    given:
    final basePath =
        "${Directory.systemTemp.absolute.path}${Platform.pathSeparator}";

    final file = File("$basePath${metadataMarkerPrefix}my_enum.dart")
      ..createSync()
      ..writeAsStringSync(
        """
           {
              "className": "MyEnum",
              "values": [ 
                "FOO",
                "BAR"
              ],
              "valuesJSON": [
                "foo!",
                "bar!"
              ]
            }""",
      );

    when:
    final result = analyzer.analyze(pathToFile: file.absolute.path);
    final types = result.childrenEnumTypes;

    then:
    expect(types.length, 1, reason: "Should have found 1 enum");

    final type = types.first;
    expect(type.values.length, 2);
    expect(type.values[0], "FOO");
    expect(type.values[1], "BAR");
    expect(type.valuesJSON[0], "foo!");
    expect(type.valuesJSON[1], "bar!");
    return true;
  });
}