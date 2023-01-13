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

import "package:squint_json/src/common/common.dart";
import "package:test/test.dart";

const example = """
    {
    "greeting": "Welcome to quicktype!",
    "instructions": [
      "Type or paste JSON here",
      "Or choose a sample above",
      "quicktype will generate code in your",
      "chosen language to parse the sample data"
    ],
    "nestedInstructions": [ [ [ ["hi!", "aye"], ["hi3!" ] ], [ ["hi2!"] ] ], [ [ [" Bye! " ] ] ] ]
  }""";

// 1 "hi!" depth 4 - width 0
// 2 "aye" depth 4 - width 1
// 2 "hi3!" depth 4 - width 1
// 3 "hi2!" depth 4 -
// 4 "Bye!"

const example2 = """
       {
        "data": [{
          "type": "articles",
          "id": "1",
          "attributes": {
            "title": "JSON:API paints my bikeshed!",
            "body": "The shortest article. Ever."
          },
          "relationships": {
            "author": {
              "data": {"id": "42", "type": "people"}
            }
          }
        }],
        "blabla": 9,
        "included": [
          {
            "type": "people",
            "id": "42",
            "attributes": {
              "name": "John"
            }
          }
        ]
      }""";

void main() {
  test("normalizeSpaces deletes unnecessary spaces and new lines", () {
    // given:
    final input = """
           [[["hi !", "aye" ], 
                  ["lol", 
                  
                  
                  "x"]      
                  ]       ]"""
        .split("");

    // when:
    final actual = input.normalizeSpaces.join();

    // then:
    expect(actual, """[[["hi !","aye"],["lol","x"]]]""");
  });

  test("normalizeSpaces saves spaces and new lines when inside quotation marks",
      () {
    // given:
    final input = """
           [[["hi !", "aye" ], 
                  ["lol", "
", "x"]      
                  ]       ]"""
        .split("");

    // when:
    final actual = input.normalizeSpaces.join();

    // then:
    expect(actual, """[[["hi !","aye"],["lol","\n","x"]]]""");
  });
}
