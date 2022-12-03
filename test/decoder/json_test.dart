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

import "package:squint/src/ast/ast.dart";
import "package:squint/src/decoder/decoder.dart";
import "package:test/test.dart";

void main() {
  test("decode JSON object", () {
    // given
    const example = """
        {
          "greeting": "Welcome to Squint!",
          "instructions": [
            "Type or paste JSON here",
            "Or choose a sample above",
            "squint will generate code in your",
            "chosen language to parse the sample data"
          ],
          "nestedness": [ 
                    [ 
                      [ 
                        [ 
                          "hi!", "aye"
                        ], 
                        [
                          "hi3!" 
                        ] 
                      ]
                    ], 
                    
                    [
                      [
                        [
                          "byebye"
                         ]
                       ]
                    ]
                 ],
                 
          "foobject": { 
            "x": "y"
          }
          
        }""";

    // when
    final decoded = example.jsonDecode;

    // then
    final greeting = decoded.string("greeting");
    expect(greeting.data, "Welcome to Squint!");

    // and
    final instructions = decoded.array<String>("instructions");
    expect(instructions.data[0], "Type or paste JSON here");
    expect(instructions.data[1], "Or choose a sample above");
    expect(instructions.data[2], "squint will generate code in your");
    expect(instructions.data[3], "chosen language to parse the sample data");

    // and
    final nestedness = decoded.array<dynamic>("nestedness");
    expect(nestedness.data[0][0][0][0], "hi!");
    expect(nestedness.data[0][0][0][1], "aye");
    expect(nestedness.data[0][0][1][0], "hi3!");
    expect(nestedness.data[1][1][1][0], "byebye");

    // and
    final foobject = decoded.object("foobject");
    final x = foobject.data["x"]! as JsonString;
    expect(x.data, "y");
  });


  test("verify decoding standard types", () {

    const json = """
{
  "id": 1,
  "fake-data": true,
  "real_data": false,
  "greeting": "Welcome to Squint!",
  "instructions": [
    "Type or paste JSON here",
    "Or choose a sample above",
    "squint will generate code in your",
    "chosen language to parse the sample data"
  ],
  "numbers": [22, 4.4, -15],
  "objective": { 
    "indicator": false,
    "instructions": [false, true, true, false]
  },
  "objectList": [
    { "a" : 1 }
  ]
}""";

    final decoded = json.jsonDecode;

    final id = decoded.integer("id");
    expect(id.key, "id");
    expect(id.data, 1);

    final fakeData = decoded.boolean("fake-data");
    expect(fakeData.key, "fake-data");
    expect(fakeData.data, true);

    final realData = decoded.boolean("real_data");
    expect(realData.key, "real_data");
    expect(realData.data, false);

    final greeting = decoded.string("greeting");
    expect(greeting.key, "greeting");
    expect(greeting.data, "Welcome to Squint!");

    final instructions = decoded.array<String>("instructions");
    expect(instructions.key, "instructions");
    expect(instructions.data[0], "Type or paste JSON here");
    expect(instructions.data[1], "Or choose a sample above");
    expect(instructions.data[2], "squint will generate code in your");
    expect(instructions.data[3], "chosen language to parse the sample data");

    final numbers = decoded.array<double>("numbers");
    expect(numbers.key, "numbers");
    // If any number in a List is a floating point,
    // then they are all stored as double values.
    expect(numbers.data[0], 22.0);
    expect(numbers.data[1], 4.4);
    expect(numbers.data[2], -15);

    final objective = decoded.object("objective");
    expect(objective.key, "objective");
    expect(objective.boolean("indicator").data, false);
    expect(objective.array<bool>("instructions").data[1], true);

    final objectList = decoded.array<dynamic>("objectList");
    expect(objectList.key, "objectList");
    expect(objectList.data[0]["a"], 1);

  });
}
