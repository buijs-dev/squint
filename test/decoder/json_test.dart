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

import "package:squint_json/squint.dart";
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
    final greeting = decoded.stringNode("greeting");
    expect(greeting.data, "Welcome to Squint!");

    // and
    final instructions = decoded.arrayNode<String>("instructions");
    expect(instructions.data[0], "Type or paste JSON here");
    expect(instructions.data[1], "Or choose a sample above");
    expect(instructions.data[2], "squint will generate code in your");
    expect(instructions.data[3], "chosen language to parse the sample data");

    // and
    final nestedness = decoded.arrayNode<dynamic>("nestedness");
    expect(nestedness.data[0][0][0][0], "hi!");
    expect(nestedness.data[0][0][0][1], "aye");
    expect(nestedness.data[0][0][1][0], "hi3!");
    expect(nestedness.data[1][0][0][0], "byebye");

    // and
    final foobject = decoded.objectNode("foobject");
    expect(foobject.string("x"), "y");
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

    final id = decoded.integerNode("id");
    expect(id.key, "id");
    expect(id.data, 1);

    final fakeData = decoded.booleanNode("fake-data");
    expect(fakeData.key, "fake-data");
    expect(fakeData.data, true);

    final realData = decoded.booleanNode("real_data");
    expect(realData.key, "real_data");
    expect(realData.data, false);

    final greeting = decoded.stringNode("greeting");
    expect(greeting.key, "greeting");
    expect(greeting.data, "Welcome to Squint!");

    final instructions = decoded.arrayNode<String>("instructions");
    expect(instructions.key, "instructions");
    expect(instructions.data[0], "Type or paste JSON here");
    expect(instructions.data[1], "Or choose a sample above");
    expect(instructions.data[2], "squint will generate code in your");
    expect(instructions.data[3], "chosen language to parse the sample data");

    final numbers = decoded.arrayNode<double>("numbers");
    expect(numbers.key, "numbers");
    // If any number in a List is a floating point,
    // then they are all stored as double values.
    expect(numbers.data[0], 22.0);
    expect(numbers.data[1], 4.4);
    expect(numbers.data[2], -15);

    final objective = decoded.objectNode("objective");
    expect(objective.key, "objective");
    expect(objective.booleanNode("indicator").data, false);
    expect(objective.arrayNode<bool>("instructions").data[1], true);

    final objectList = decoded.arrayNode<dynamic>("objectList");
    expect(objectList.key, "objectList");
    expect(objectList.data[0]["a"], 1);
  });

  test("verify decoding and using direct value getters", () {
    const json = '''
         {
            "id": 1,
            "isJedi": true,
            "hasPadawan": false,
            "bff": "Leia",
            "jedi": [
              "Obi-Wan", "Anakin", "Luke Skywalker"
            ],
            "coordinates": [22, 4.4, -15],
            "objectives": {
              "in-mission": false,
              "mission-results": [false, true, true, false]
            },
            "annoyance-rate": [
              { "JarJarBinks" : 9000 }
            ]
          }
          ''';

    final object = json.jsonDecode;
    expect(object.integerNode("id").key, "id");
    expect(object.integerNode("id").data, 1);
    expect(object.integer("id"), 1);
    expect(object.boolean("isJedi"), true);
    expect(object.boolean("hasPadawan"), false);
    expect(object.string("bff"), "Leia");
    expect(object.array<String>("jedi")[0], "Obi-Wan");
    expect(object.array<String>("jedi")[1], "Anakin");
    expect(object.array<String>("jedi")[2], "Luke Skywalker");
    expect(object.array<double>("coordinates")[0], 22);
    expect(object.array<double>("coordinates")[1], 4.4);
    expect(object.array<double>("coordinates")[2], -15);
    expect(object.objectNode("objectives").boolean("in-mission"), false);
    expect(object.objectNode("objectives").array<bool>("mission-results")[0],
        false);
    expect(object.objectNode("objectives").array<bool>("mission-results")[1],
        true);
    expect(object.array<dynamic>("annoyance-rate")[0]["JarJarBinks"], 9000);
  });
}
