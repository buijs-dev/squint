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

import "package:squint_json/squint_json.dart";
import "package:test/test.dart";

void main() {
  const example = """
        {
          "greeting": "Welcome to Squint!",
          "instructions": [
            "Type or paste JSON here",
            "Or choose a sample above",
            "squint will generate code in your",
            "chosen language to parse the sample data"
          ],
          "nestedness": [["a", null], ["b"], ["c"]], 
          "foobject": {  "x": "y" },
          "numberuno": 1,
          "nowaiii": true,
          "nothing": null 
        }""";

  final decoded = example.jsonDecode;

  test("verify JsonNull stringifies null value", () {
    expect(const JsonNull(key: "xyz").stringify, '"xyz":null');
  });

  test("verify an exception is thrown if the request key is not found", () {
    expect(
        () => JsonObject(data: {}).byKey("xyz"),
        throwsA(predicate((e) =>
            e is SquintException && e.cause == "JSON key not found: 'xyz'")));
  });

  test(
      "verify an exception is thrown if the request type does not match the decoded type",
      () {
    expect(
        () => decoded.floatNode("greeting"),
        throwsA(predicate((e) =>
            e is SquintException &&
            e.cause ==
                "Data is not of expected type. Expected: 'JsonFloatingNumber'. Actual: JsonString")));
  });

  test("verify object getter returns an object", () {
    expect(decoded.objectNode("foobject").getDataAsMap<String>()["x"], "y");
  });

  test("verify array getter returns an object", () {
    expect(decoded.arrayNode<List<String?>>("nestedness").data[0][0], "a");
    expect(decoded.arrayNode<List<String?>>("nestedness").data[0][1], null);
    expect(decoded.arrayNode<List<String?>>("nestedness").data[1][0], "b");
  });

  test("verify String getter returns an object", () {
    expect(decoded.stringNode("greeting").data, "Welcome to Squint!");
  });

  test("verify number getter returns an object", () {
    expect(decoded.integerNode("numberuno").data, 1);
  });

  test("verify boolean getter returns a bool", () {
    expect(decoded.booleanNode("nowaiii").data, true);
  });

  test("verify nullable String getter can return null", () {
    expect(decoded.stringNodeOrNull("nothing")?.data, null);
  });

  test("verify nullable number getter can return null", () {
    expect(decoded.floatNodeOrNull("nothing")?.data, null);
  });

  test("verify nullable array getter can return null", () {
    expect(decoded.arrayNodeOrNull<String>("nothing")?.data, null);
  });

  test("verify nullable object getter can return null", () {
    expect(decoded.objectNodeOrNull("nothing")?.data, null);
  });

  test("verify nullable boolean getter returns a bool", () {
    expect(decoded.booleanNodeOrNull("nowaiii")!.data, true);
  });

  test("verify nullable object getter returns an object", () {
    expect(decoded.objectNode("foobject").getDataAsMap<String>()["x"], "y");
  });

  test("verify nullable array getter returns a List", () {
    expect(
        decoded.arrayNodeOrNull<List<String?>>("nestedness")!.data[0][0], "a");
    expect(
        decoded.arrayNodeOrNull<List<String?>>("nestedness")!.data[0][1], null);
    expect(
        decoded.arrayNodeOrNull<List<String?>>("nestedness")!.data[1][0], "b");
    expect(
        decoded.arrayNodeOrNull<List<String?>>("nestedness")!.data[2][0], "c");
  });

  test("verify nullable String getter returns a String", () {
    expect(decoded.stringNodeOrNull("greeting")!.data, "Welcome to Squint!");
  });

  test("verify nullable number getter returns a number", () {
    expect(decoded.integerNodeOrNull("numberuno")!.data, 1);
  });

  test("verify nullable boolean getter returns a bool", () {
    expect(decoded.booleanNodeOrNull("nowaiii")!.data, true);
  });

  test("verify building a JsonObject from a Map with dynamic data", () {
    // given:
    final data = {
      "aString": "a",
      "bNumber": 1.0,
      "cBoolean": false,
      "dNull": null,
      "eList": ["Hi!"],
      "fMap": {"x": 12.0}
    };

    // when:
    final jsonObject = JsonObject.fromMap(data: data);

    // then:
    expect(jsonObject.stringNode("aString").data, "a");
    expect(jsonObject.floatNode("bNumber").data, 1.0);
    expect(jsonObject.booleanNode("cBoolean").data, false);
    expect(jsonObject.byKey("dNull").data, null);
    expect(jsonObject.arrayNode<String>("eList").data[0], "Hi!");
    expect(jsonObject.objectNode("fMap").getDataAsMap<double>()["x"], 12.0);
  });

  test("verify building a JsonObject from a Map with JsonElements data", () {
    // given:
    final data = {"aString": const JsonString(key: "aString", data: "Hi!")};

    // when:
    final jsonObject = JsonObject.fromMap(data: data);

    // then:
    expect(jsonObject.stringNode("aString").data, "Hi!");
  });

  test("verify an exception is thrown if the data types are not supported", () {
    // given:
    final data = <String, dynamic>{"x": _Dummy()};

    // expect:
    expect(
        () => JsonObject.fromMap(data: data),
        throwsA(predicate((e) =>
            e is SquintException &&
            e.cause ==
                "Unable to convert Map<String, dynamic> to Map<String,JsonNode>")));
  });
}

class _Dummy {}
