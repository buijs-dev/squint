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

/// JSON map element wrapper.
abstract class SquintElement {
  /// SquintElement const.
  const SquintElement();
}

/// Not-null value for JSON key.
class SquintValue extends SquintElement {
  /// Construct a new SquintValue instance with a not-null value.
  const SquintValue(this.value);

  /// The actual value as extracted from the JSON map.
  final dynamic value;
}

/// Null value for JSON key.
class SquintNullValue extends SquintElement {
  /// SquintNullValue const.
  const SquintNullValue();
}

/// An element which does not exist in the JSON map.
class UnknownKey extends SquintElement {
  /// UnknownKey const.
  const UnknownKey();
}
