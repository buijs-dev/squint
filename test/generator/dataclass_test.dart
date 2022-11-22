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

import "package:squint/src/ast/ast.dart";
import "package:squint/src/decoder/decoder.dart";
import "package:squint/src/generator/dataclass.dart";
import "package:test/test.dart";

void main() {
  test("Verify Converting a JSON String to a CustomType", () {
    // given
    const example = """
        {
          "id": 1,
          "fake-data": true,
          "real_data": false,
          "greeting": "Welcome to Squint!",
          "empty": null,
          "instructions": [
            "Type or paste JSON here",
            "Or choose a sample above",
            "squint will generate code in your",
            "chosen language to parse the sample data"
          ],
          "numbers": [22,45,67, 4.4, -15],
          "objective": { 
            "indicator": false,
            "instructions": [false, true, true, false]
          }
        }""";

    // when:
    final podo = example.jsonDecode.toCustomType(className: "Example");

    // then:
    expect(podo.className, "Example");

    // JSON element 'id' is a number
    expect(podo.members[0].name, "id");
    expect(podo.members[0].type, const DoubleType());

    // JSON element 'id' is a number
    expect(podo.members[1].name, "fake-data");
    expect(podo.members[1].type, const BooleanType());

    // JSON element 'id' is a number
    expect(podo.members[2].name, "real_data");
    expect(podo.members[2].type, const BooleanType());

    // JSON element 'greeting' is a String
    expect(podo.members[3].name, "greeting");
    expect(podo.members[3].type, const StringType());

    // JSON element 'empty' is null and defaults to String
    expect(podo.members[4].name, "empty");
    expect(podo.members[4].type, const NullableStringType());

    // JSON element 'instructions' is a List of Strings
    expect(podo.members[5].name, "instructions");
    expect(podo.members[5].type.className, "List");
    expect((podo.members[5].type as ListType).child, const StringType());

    // JSON element 'numbers' is a List of doubles
    expect(podo.members[6].name, "numbers");
    expect(podo.members[6].type.className, "List");
    expect((podo.members[6].type as ListType).child, const DoubleType());

    // JSON element 'objective' is a CustomType
    // with classname Objective
    // and member 'indicator' of type Boolean
    expect(podo.members[7].name, "objective");
    expect(podo.members[7].type.className, "Objective");
    expect((podo.members[7].type as CustomType).members[0].type,
        const BooleanType());
  });
}
