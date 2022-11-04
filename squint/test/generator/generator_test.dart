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
import "package:squint/src/ast/types.dart";
import "package:squint/src/generator/generator.dart" as generator;
import "package:test/test.dart";

void main() {

  test("Generate", () {
    given:
    const customType = CustomType(
        className: "SchoolIsOut4Summer",
        members: [
          TypeMember(
              name: "name",
              type: StringType()
          ),
          TypeMember(
              name: "friends",
              type: ListType(StringType())
          )
        ]
    );

    and:
    const expected = """
     SchoolIsOut4Summer deserializeExampleResponse(String json) =>
    deserializeSchoolIsOut4SummerMap(jsonDecode(json) as Map<String, dynamic>);
    
    SchoolIsOut4Summer deserializeSchoolIsOut4SummerMap(Map<String, dynamic> data) =>
      SchoolIsOut4Summer(
          name: data.stringValueOrThrow(key: "name"),
          friends: data.listValueOrThrow(key: "friends").map<String>(stringOrThrow).toList());
    """;

    when:
    final generated = generator.generateMethods(type: customType);
    print(generated);

    then:
    expect(generated.replaceAll(" ", "").replaceAll("\n", "") == expected.replaceAll(" ", "").replaceAll("\n", ""), true);
  });

}