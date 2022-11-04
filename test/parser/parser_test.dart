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

import "dart:convert";
import "dart:typed_data";

import "package:squint/squint.dart";
import "package:test/test.dart";

void main() {
  test("Verify (de)serializing with Parser", () {
    final response = _simpleResponseFromJson(responseWithAllElements);
    expect(response.a1, 1);
    expect(response.a2, 2);
    expect(response.b1, 1.0);
    expect(response.b2, 2.0);
    expect(response.c1, true);
    expect(response.c2, false);
    expect(response.d1, "D Value");
    expect(response.d2, "Also D2 value");
    expect(response.e1[0], "Value!");
    expect(response.e2[0], "Value!");
    expect(response.e3![0], "Value!");
    expect(response.e4![0], "Value!");
    expect(response.f1[0], 1);
    expect(response.f2[0], 2);
    expect(response.f3![0], 3);
    expect(response.f4![0], 4);
    expect(response.g1[0], 1.0);
    expect(response.g2[0], 2.0);
    expect(response.g3![0], 3.0);
    expect(response.g4![0], 4.0);
    expect(response.h1.length, 2);
    expect(response.h1[0], false);
    expect(response.h1[1], true);
    expect(response.h2.length, 2);
    expect(response.h2[0], true);
    expect(response.h2[1], false);
    expect(response.h3?.length, 3);
    expect(response.h3![0], false);
    expect(response.h3![1], false);
    expect(response.h3![2], true);
    expect(response.h4?.length, 2);
    expect(response.h4![0], false);
    expect(response.h4![1], true);
    expect(response.i1[0][0], 3.33);
  });

  test("Nullable fields are allowed to be missing", () {
    final response = _simpleResponseFromJson(responseWithNulls);
    expect(response.a1, 1);
  });

  test("No matter how nested it gets, the value will be found", () {
    final nestednestednestednestedlist = {
      "key1": [
        [
          [
            ["Value!"]
          ]
        ]
      ]
    };

    final retrievedValue = nestednestednestednestedlist
        .listValueOrThrow(key: "key1")
        .map(listOrThrow)
        .map((e) => e.map(listOrThrow))
        .map((e) => e.map((e) => e.map(listOrThrow)))
        .map((e) => e.map((e) => e.map((e) => e.map(stringOrThrow).toList()).toList()).toList()).toList();

    expect(retrievedValue[0][0][0][0], "Value!");
  });

  test("Unwrap Map", () {
    final map = {
      "key1": {1.0: true, 2.0: false}
    };

    final retrievedValue = map.mapValueOrThrow(key: "key1").map<double, bool>(
        (dynamic key, dynamic value) =>
            MapEntry(doubleOrThrow(key), boolOrThrow(value)));

    expect(retrievedValue[1.0], true);
  });

  test("Unwrap multiple nested map", () {
    final map = {
      "key1": {
        1.0: {"a": true},
        2.0: {"a": false}
      }
    };

    final retrievedValue = map.mapValueOrThrow(key: "key1").map<double, Map>(
        (dynamic key, dynamic value) => MapEntry(
            doubleOrThrow(key),
            mapOrThrow(value).map<String, bool>((dynamic key, dynamic value) =>
                MapEntry(stringOrThrow(key), boolOrThrow(value)))));

    expect(retrievedValue[1.0]!["a"], true);
  });

  test("Parse Uint8List", () {
    final jsonmap = {
      "alist": Uint8List.fromList([0, 1, 2, 3, 4, 5])
    };
    final uint8List = jsonmap.uint8ListValueOrNull(key: "alist");
    expect(uint8List![0], 0);
    expect(uint8List[1], 1);
  });

  test("Parse Int32List", () {
    final jsonmap = {
      "alist": Int32List.fromList([0, 1, 2, 3, 4, 5])
    };
    final uint8List = jsonmap.int32ListValueOrNull(key: "alist");
    expect(uint8List![0], 0);
    expect(uint8List[1], 1);
  });

  test("Parse Int64List", () {
    final jsonmap = {
      "alist": Int64List.fromList([0, 1, 2, 3, 4, 5])
    };
    final uint8List = jsonmap.int64ListValueOrNull(key: "alist");
    expect(uint8List![0], 0);
    expect(uint8List[1], 1);
  });

  test("Parse Float32List", () {
    final jsonmap = {
      "alist": Float32List.fromList([0.1, 1.1, 2.1, 3.1, 4.1, 5.1])
    };
    final uint8List = jsonmap.float32ListValueOrNull(key: "alist");
    expect(uint8List![0], 0.10000000149011612);
    expect(uint8List[1], 1.100000023841858);
  });

  test("Parse Float64List", () {
    final jsonmap = {
      "alist": Float64List.fromList([0.1, 1.1, 2.1, 3.1, 4.1, 5.1])
    };
    final uint8List = jsonmap.float64ListValueOrNull(key: "alist");
    expect(uint8List![0], 0.1);
    expect(uint8List[1], 1.1);
  });
}

@squint
class SimpleResponse {
  ///
  SimpleResponse(
      {required this.a1,
      required this.a2,
      required this.b1,
      required this.b2,
      required this.c1,
      required this.c2,
      required this.d1,
      required this.d2,
      required this.e1,
      required this.e2,
      required this.e3,
      required this.e4,
      required this.f1,
      required this.f2,
      required this.f3,
      required this.f4,
      required this.g1,
      required this.g2,
      required this.g3,
      required this.g4,
      required this.h1,
      required this.h2,
      required this.h3,
      required this.h4,
      required this.i1});

  final int a1;
  final int? a2;
  final double b1;
  final double? b2;
  final bool c1;
  final bool? c2;
  final String d1;
  final String? d2;
  final List<String> e1;
  final List<String?> e2;
  final List<String>? e3;
  final List<String?>? e4;
  final List<int> f1;
  final List<int?> f2;
  final List<int>? f3;
  final List<int?>? f4;
  final List<double> g1;
  final List<double?> g2;
  final List<double>? g3;
  final List<double?>? g4;
  final List<bool> h1;
  final List<bool?> h2;
  final List<bool>? h3;
  final List<bool?>? h4;
  final List<List<double>> i1;
}

SimpleResponse _simpleResponseFromJson(String json) =>
    _simpleResponseFromJsonMap(jsonDecode(json) as Map<String, dynamic>);

SimpleResponse _simpleResponseFromJsonMap(Map<String, dynamic> data) =>
    SimpleResponse(
        a1: data.intValueOrThrow(key: "a1"),
        a2: data.intValueOrNull(key: "a2"),
        b1: data.doubleValueOrThrow(key: "b1"),
        b2: data.doubleValueOrNull(key: "b2"),
        c1: data.boolValueOrThrow(key: "c1"),
        c2: data.boolValueOrNull(key: "c2"),
        d1: data.stringValueOrThrow(key: "d1"),
        d2: data.stringValueOrNull(key: "d2"),

        // List String
        e1: data
            .listValueOrThrow(key: "e1")
            .map<String>(stringOrThrow)
            .toList(),
        e2: data
            .listValueOrThrow(key: "e2")
            .map<String?>(stringOrNull)
            .toList(),
        e3: data
            .listValueOrNull(key: "e3")
            ?.map<String>(stringOrThrow)
            .toList(),
        e4: data
            .listValueOrNull(key: "e4")
            ?.map<String?>(stringOrNull)
            .toList(),

        // List int
        f1: data.listValueOrThrow(key: "f1").map<int>(intOrThrow).toList(),
        f2: data.listValueOrThrow(key: "f2").map<int?>(intOrNull).toList(),
        f3: data.listValueOrNull(key: "f3")?.map<int>(intOrThrow).toList(),
        f4: data.listValueOrNull(key: "f4")?.map<int?>(intOrNull).toList(),

        // List double
        g1: data
            .listValueOrThrow(key: "g1")
            .map<double>(doubleOrThrow)
            .toList(),
        g2: data
            .listValueOrThrow(key: "g2")
            .map<double?>(doubleOrNull)
            .toList(),
        g3: data
            .listValueOrNull(key: "g3")
            ?.map<double>(doubleOrThrow)
            .toList(),
        g4: data
            .listValueOrNull(key: "g4")
            ?.map<double?>(doubleOrNull)
            .toList(),

        // List bool
        h1: data.listValueOrThrow(key: "h1").map<bool>(boolOrThrow).toList(),
        h2: data.listValueOrThrow(key: "h2").map<bool?>(boolOrNull).toList(),
        h3: data.listValueOrNull(key: "h3")?.map<bool>(boolOrThrow).toList(),
        h4: data.listValueOrNull(key: "h4")?.map<bool?>(boolOrNull).toList(),

        // Nested List => List<List<double>>
        i1: data
            .listValueOrThrow(key: "i1")
            .map<List<double>>(
                (dynamic o) => listOrThrow(o).map(doubleOrThrow).toList())
            .toList());

const responseWithAllElements = """
 {
    "a1": 1,
    "a2": 2,
    "b1": 1.0,
    "b2": 2.0,
    "c1": true,
    "c2": false,
    "d1": "D Value",
    "d2": "Also D2 value",
    "e1": ["Value!"],
    "e2": ["Value!"],
    "e3": ["Value!"],
    "e4": ["Value!"],
    "f1": [1],
    "f2": [2],
    "f3": [3],
    "f4": [4],
    "g1": [1.0],
    "g2": [2.0],
    "g3": [3.0],
    "g4": [4.0],
    "h1": [false, true],
    "h2": [true, false],
    "h3": [false, false, true],
    "h4": [false, true],
    "i1": [[3.33]]
  }
  """;

const responseWithNulls = """
 {
    "a1": 1,
    "b1": 1.0,
    "c1": true,
    "d1": "D Value",
    "e1": ["Value!"],
    "e2": ["Value!", null],
    "f1": [1],
    "f2": [2, null],
    "g1": [1.0],
    "g2": [2.0, null],
    "h1": [false, true],
    "h2": [true, false, null],
    "i1": [[3.33]]
  }
  """;
