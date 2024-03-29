// Copyright (c) 2021 - 2023 Buijs Software
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

/// List processing utilities.
extension ListProcessor<T> on Iterable<T> {
  /// Find object on type T that matches criteria.
  T? firstBy(bool Function(T t) predicate) {
    T? maybeValue;
    forEach((entry) {
      if (predicate.call(entry)) {
        // Don't override the first found value.
        maybeValue = maybeValue ?? entry;
      }
    });

    return maybeValue;
  }

  /// Return true if iterable contains all [values].
  bool containsAll(Iterable<T> values) {
    for (final value in values) {
      if (!contains(value)) {
        return false;
      }
    }
    return true;
  }
}
