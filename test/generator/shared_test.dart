// Copyright (c) 2021 - 2025 Buijs Software
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

import "dart:core";

import "package:squint_json/src/ast/ast.dart";
import "package:squint_json/src/generator/shared.dart";
import "package:test/test.dart";

void main() {
  test("When a CustomType contains a nested CustomType then it is collected",
      () {
    // given:
    const childChildCustomType = CustomType(
        className: "Bar1",
        members: [TypeMember(name: "name", type: StringType())]);
    const childCustomType = CustomType(
        className: "Bar2",
        members: [TypeMember(name: "name", type: childChildCustomType)]);
    const parentCustomType = CustomType(
        className: "Foo",
        members: [TypeMember(name: "bar", type: childCustomType)]);

    // when
    final unwrapped = parentCustomType.unwrapNestedTypes();

    expect(unwrapped.contains(childCustomType), true,
        reason: "should contain child type");
    expect(unwrapped.contains(childChildCustomType), true,
        reason: "should contain child of child type");
  });
}
