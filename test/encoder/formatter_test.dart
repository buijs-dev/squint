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

// ignore_for_file: avoid_dynamic_calls

import "package:squint_json/src/ast/ast.dart";
import "package:squint_json/src/encoder/encoder.dart";
import "package:test/test.dart";

void main() {
  test("verify encoding and formatting a JsonObject with default options", () {
    // given:
    final object = JsonObject.fromNodes(nodes: [
      const JsonString(key: "foo", data: "hello"),
      const JsonBoolean(key: "isOk", data: true),
      const JsonArray<dynamic>(key: "random", data: [1, 0, 33]),
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
  });

  test("verify encoding and formatting a JsonObject with custom options", () {
    // given:
    final object = JsonObject.fromNodes(nodes: [
      const JsonString(key: "foo", data: "hello"),
      const JsonBoolean(key: "isOk", data: true),
      const JsonArray<dynamic>(key: "random", data: [1, 0, 33]),
    ]);

    // when:
    final json = object.stringifyWithFormatting(standardJsonFormatting.copyWith(
      indentationSize: JsonIndentationSize.doubleSpace,
      colonPadding: 20,
    ));

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
  });
}
