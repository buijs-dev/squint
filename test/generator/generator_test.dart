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

import "package:squint/squint.dart";
import "package:squint/src/encoder/formatter.dart";
import "package:test/test.dart";

void main() {
  const object = _TestingExample(
    foo: "bar",
    isOk: true,
    random: [0,3,2],
    multiples: [["hooray!"]],
  );

  // This tests makes sure the examples that are used to compare
  // are itself valid, otherwise testing is useless.
  test("Verify examples toJsonObject method", () {
    // when:
    final jsonObject = object.toJsonObject;

    // then:
    expect(jsonObject.string("foo").data, "bar");
    expect(jsonObject.boolean("isOk").data, true);
    expect(jsonObject.array("random").data[0], 0);
    expect(jsonObject.array("random").data[1], 3);
    expect(jsonObject.array("random").data[2], 2);
    expect(jsonObject.array("multiples").data[0][0], "hooray!");
  });

  test("Verify examples toJson method", () {
    // when:
    final jsonString = object.toJson;

    // then:
    expect(jsonString, """
{
    "foo" : "bar",
    "isOk" : true,
    "random" : [
        0.0,
        3.0,
        2.0
    ],
    "multiples" : [
        [
            "hooray!"
        ]
    ]
}""");
  });

}

class _TestingExample {
  const _TestingExample({
    required this.foo,
    required this.isOk,
    required this.random,
    required this.multiples,
  });

  final String foo;
  final bool isOk;
  final List<double> random;
  final List<List<String>> multiples;
}

extension _TestExampleJson on _TestingExample {

  JsonObject get toJsonObject =>
    JsonObject(<String, JsonElement>{
      "foo": JsonString(key: "foo", data: foo),
      "isOk": JsonBoolean(key: "isOk", data: isOk),
      "random": JsonArray<double>(key: "random", data: random),
      "multiples": JsonArray<List<String>>(key: "multiples", data: multiples),
    });

  String get toJson => toJsonObject.stringify;

}

// _TestingExample fromJson(String json) {
//
// }
//
// _TestingExample fromJsonObject(JsonObject jsonObject) {
//
// }