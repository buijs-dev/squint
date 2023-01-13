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

import "package:squint_json/squint.dart";
import "package:test/test.dart";

void main() {
  test(
      "verify an exception is thrown if the child type of a List can not be determined",
      () {
    expect(
        () => "List<>".toAbstractType(),
        throwsA(predicate((e) =>
            e is SquintException &&
            e.cause.startsWith("Unable to determine type:") &&
            e.cause.contains("List<>"))));

    expect(
        () => "List".toAbstractType(),
        throwsA(predicate((e) =>
            e is SquintException &&
            e.cause.startsWith("Unable to determine List child type:") &&
            e.cause.contains("List"))));
  });

  test(
      "verify an exception is thrown if the key type of a Map can not be determined",
      () {
    expect(
        () => "Map".toAbstractType(),
        throwsA(predicate((e) =>
            e is SquintException &&
            e.cause.startsWith("Unable to determine Map key type:") &&
            e.cause.contains("'Map'"))));
  });

  test("verify an exception is thrown if the a class name is invalid", () {
    expect(
        () => r"""bla$""".toAbstractType(),
        throwsA(predicate((e) =>
            e is SquintException &&
            e.cause.startsWith("Unable to determine type:") &&
            e.cause.contains(r"""bla$"""))));
  });
}
