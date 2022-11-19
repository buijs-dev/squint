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

import 'package:squint/src/ast/ast.dart';
import "package:squint/src/decoder/decoder.dart";
import "package:test/test.dart";

void main() {

  test("verify unwrapping a list of numbers", () {

    // when
    final unwrapped =  """
       ["hi !", 
                  
                  "aye" ]
                  """.unwrapList(
        normalizeSpaces: true,
        maxDepth: 1,
    );

    // then
    expect(unwrapped[".0.0"]!.data, "hi !");
    expect(unwrapped[".0.1"]!.data, "aye");

  });

  test("verify unwrapping multiple nested lists", () {

    // when
    final unwrapped = """
          [[["hi !", "aye" ], 
                  ["lol", 
                  
                  
                  "x"]      
                  ]       ]
          """.unwrapList(
      normalizeSpaces: true,
      maxDepth: 4,
    );

    // then
    expect(unwrapped[".0.0.0.0"]!.data, "hi !");
    expect(unwrapped[".0.0.0.1"]!.data, "aye");
    expect(unwrapped[".0.0.1.1"]!.data, "lol");
    expect(unwrapped[".0.0.1.2"]!.data, "x");

  });

  test("verify decoding a nested List", () {
    final json = """
          {
            "xyz":           [[["hi !", "aye" ], 
                  ["lol", 
                  
                  
                  "x"]      
                  ]       ]
          }
          """.jsonDecode;

    final arr = json.array("xyz");
    expect(arr.key, "xyz");

    final data = arr.data;
    expect(data[0][0][0], "hi !");
    expect(data[0][0][1], "aye");
    expect(data[0][1][0], "lol");
    expect(data[0][1][1], "x");
  });

  test("verify decoding a single list", () {
    final json = """
          {
            "xyz":["hi !", "aye" ]
          }
          """.jsonDecode;

    final arr = json.array("xyz");
    expect(arr.key, "xyz");

    final data = arr.data;
    expect(data[0], "hi !");
    expect(data[1], "aye");
  });

  test("verify decoding a null value", () {
    final json = """
          {
            "xyz": null
          }
          """.jsonDecode;

    final nullable = json.byKey("xyz") as JsonNull;
    expect(nullable.key, "xyz");
    expect(nullable.data, null);
  });

  test("verify decoding a bool value", () {
    final json = """
          {
            "sayYes": false,
            "sayNoNoNoCanDo": true,
          }
          """.jsonDecode;

    final sayYes = json.byKey("sayYes") as JsonBoolean;
    expect(sayYes.key, "sayYes");
    expect(sayYes.data, false);

    final sayNoNoNoCanDo = json.byKey("sayNoNoNoCanDo") as JsonBoolean;
    expect(sayNoNoNoCanDo.key, "sayNoNoNoCanDo");
    expect(sayNoNoNoCanDo.data, true);
  });

  test("verify decoding a number value", () {
    final json = """
          {
            "getReady4TheLaunch": 12345,
          }
          """.jsonDecode;

    final getReady4TheLaunch = json.byKey("getReady4TheLaunch") as JsonNumber;
    expect(getReady4TheLaunch.key, "getReady4TheLaunch");
    expect(getReady4TheLaunch.data, 12345);

  });

  test("verify decoding a list of numbers", () {
    final json = """
          {
            "getReady4TheLaunch": [0,2,44,33],
          }
          """.jsonDecode;

    // then
    final getReady4TheLaunch = json.byKey("getReady4TheLaunch") as JsonArray;
    expect(getReady4TheLaunch.key, "getReady4TheLaunch");
    expect(getReady4TheLaunch.data[0], 0);
    expect(getReady4TheLaunch.data[1], 2);
    expect(getReady4TheLaunch.data[2], 44);
    expect(getReady4TheLaunch.data[3], 33);
  });

  test("verify ListValueToken", () {
    // given
    final token = ListValueToken(
      currentCharacter: "y",
      currentKey: ".0.0",
      currentValue: "x",
      currentSize: {0:0},
      currentDepth: 0,
    );

    // expect
    expect(token.size, {0:0}, reason: "size does not change while processing a value");
    expect(token.depth, 0, reason: "depth does not change while processing a value");
    expect(token.key, ".0.0", reason: "key does not change while processing a value");
    expect(token.value, "xy", reason: "tokens are appended while processing a value");
  });

  test("verify ListValueSeparatorToken", () {
    // given
    final output = <String,JsonElement>{};
    final token = ListValueSeparatorToken(
      currentKey: ".0.0",
      currentValue: '"Anakin"',
      currentSize: {0:0},
      currentDepth: 0,
      output: output,
    );

    // expect
    expect(token.size, {0:1}, reason: "at depth 0 there is 1 value added (width is 1)");
    expect(token.depth, 0, reason: "depth does not change while processing a value");
    expect(token.key, ".0.1", reason: "final width (.0) marker is incremented by 1 (.0.1)");
    expect(token.value, "", reason: "value is resetted after storing it");
    expect(output.length, 1, reason: "value is added to the output map");
    expect(output[".0.0"]!.data, "Anakin", reason: "value is added to the output map");
  });

  test("verify ListClosingBracketToken", () {
    // given
    final output = <String,JsonElement>{};
    final token = ListClosingBracketToken(
      currentKey: ".1.5",
      currentValue: '"Anakin"',
      currentSize: {0:0, 1:0},
      currentDepth: 1,
      output: output,
    );

    // expect
    expect(token.size, {0:0, 1:1}, reason: "at depth 1 there is 1 value added (width is 1)");
    expect(token.depth, 0, reason: "depth is decreased by 1 after closing a list");
    expect(token.key, ".1", reason: "final width (.0) marker is removed from key");
    expect(token.value, "", reason: "value is resetted after storing it");
    expect(output.length, 1, reason: "value is added to the output map");
    expect(output[".1.5"]!.data, "Anakin", reason: "value is added to the output map");
  });

  test("verify ListOpeningBracketToken", () {
    // given
    final token = ListOpeningBracketToken(
      currentKey: ".1.0.0",
      currentValue: "",
      currentSize: {
        0:0,
        1:0,
        2:0
      },
      currentDepth: 2,
    );

    // expect
    expect(token.size, { 0:0, 1:0, 2:0}, reason: "size does not change when adding depth");
    expect(token.depth, 3, reason: "depth is increased by 1 after opening a list");
    expect(token.key, ".1.0.0.0", reason: "final width marker is added to key");
    expect(token.value, "", reason: "value does not change");
  });
}