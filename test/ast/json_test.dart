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

  test("verify an exception is thrown if the request key is not found", () {
    expect(() =>  JsonObject({}).byKey("xyz"),
        throwsA(predicate((e) =>
        e is SquintException &&
            e.cause == "JSON key not found: 'xyz'"
        )));
  });

  test("verify object getter returns an object", () {
    expect(decoded.object("foobject").string("x").data, "y");
  });

  test("verify array getter returns an object", () {
    expect(decoded.array<List<String?>>("nestedness").data[0][0], "a");
    expect(decoded.array<List<String?>>("nestedness").data[0][1], null);
    expect(decoded.array<List<String?>>("nestedness").data[1][0], "b");
  });

  test("verify String getter returns an object", () {
    expect(decoded.string("greeting").data, "Welcome to Squint!");
  });

  test("verify number getter returns an object", () {
    expect(decoded.number("numberuno").data, 1);
  });

  test("verify object getter returns an object", () {
    expect(decoded.boolean("nowaiii").data, true);
  });

  test("verify object getter returns an object", () {
    expect(decoded.stringOrNull("nothing")?.data, null);
  });

}