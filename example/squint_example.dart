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

import "package:squint_json/squint.dart";

/// Example DTO as defined by the user.
@squint
class TestingExample {
  const TestingExample({
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

/// Method generated by Squint library
extension _TestExampleJsonBuilder on TestingExample {
  JsonObject get toJsonObject => JsonObject.fromNodes(nodes: [
    JsonString(key: "foo", data: foo),
    JsonBoolean(key: "isOk", data: isOk),
    JsonArray<dynamic>(key: "random", data: random),
    JsonArray<dynamic>(key: "multiples", data: multiples),
  ]);

  String get toJson => toJsonObject.stringify;
}

/// Method generated by Squint library
extension _TestExampleJsonString2Class on String {
  TestingExample get toTestingExample => jsonDecode.toTestingExample;
}

/// Method generated by Squint library
extension _TestExampleJsonObject2Class on JsonObject {
  TestingExample get toTestingExample => TestingExample(
    foo: stringNode("foo").data,
    isOk: booleanNode("isOk").data,
    random: arrayNode<double>("random").data,
    multiples: arrayNode<List<String>>("multiples").data,
  );
}

void main() {
  const example = """
  {
    "foo": "squint",
    "isOk": true,
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
  }""";

  final response = example.toTestingExample;
  print("foo is ${response.foo}"); // Prints: foo is squint.
  print("isOk is ${response.isOk}"); // Prints: isOk is true.
  print("random is ${response.random}"); // Prints: random is [0.0,3.0,2.0].
  print("multiples is ${response.multiples}"); // Prints: multiples is [[hooray!]].
}
