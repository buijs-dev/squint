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

///
List buildListStructure<T>(List<List<int>> positions, {List<T>? valueList}) {
  positions.sort((a, b) => a.length.compareTo(b.length));
  final maxDepth = positions.last.length -1;
  final maxEntriesForEachDepth = <int>[];
  for(var i = 0; i <= maxDepth; i++) {
    final indexes = <int>[];
    for(final position in positions) {
      if(position.length > i) {
        indexes.add(position[i]);
      }
    }
    indexes.sort((int a, int b) => a.compareTo(b));
    maxEntriesForEachDepth.add(indexes.last);
  }
  maxEntriesForEachDepth.sort((a,b) => a.compareTo(b));
  return getNestedList<T>(
      depth: maxDepth,
      valueList: valueList ?? <T>[],
  );
}

///
int calculateMaxListDepth(List<List<int>> positions) {
  positions.sort((a, b) => a.length.compareTo(b.length));
  return positions.last.length -1;
}

///
int calculateMaxListWidth(List<List<int>> positions) {
  final maxDepth = calculateMaxListDepth(positions);
  final maxEntriesForEachDepth = <int>[];
  for(var i = 0; i <= maxDepth; i++) {
    final indexes = <int>[];
    for(final position in positions) {
      if(position.length > i) {
        indexes.add(position[i]);
      }
    }
    indexes.sort((int a, int b) => a.compareTo(b));
    maxEntriesForEachDepth.add(indexes.first);
  }
  maxEntriesForEachDepth.sort((a,b) => a.compareTo(b));
  return maxEntriesForEachDepth.first;
}

/// Get a List<T> with 0 or more parent lists.
///
/// Specify [depth] to added one or more parent Lists.
///
/// Example:
/// [depth] 0 = List<T>
/// [depth] 2 = List<List<List<T>>>.
List getNestedList<T>({
  required int depth,
  required List<T> valueList,
}) {

  if(depth == 0) {
    return valueList;
  }

  return getNestedList(depth: depth-1, valueList: _addParent(valueList));
}

/// Add another List arround the given List and keep the it strongly typed.
List<List<T>> _addParent<T>(List<T> list) => [list];

/// Get a List<String> with 0 or more parent lists.
///
/// Specify [depth] to added one or more parent Lists.
///
/// Example:
/// [depth] 0 = List<String>
/// [depth] 2 = List<List<List<String>>>.
List getNestedStringList(int depth) =>
    getNestedList<String>(depth: depth, valueList: <String>[]);

/// Get nested List with a nullable String child. See [getNestedStringList].
List getNestedNullableStringList(int depth) =>
    getNestedList<String?>(depth: depth, valueList: <String?>[]);

/// Get a List<int> with 0 or more parent lists.
///
/// Specify [depth] to added one or more parent Lists.
///
/// Example:
/// [depth] 0 = List<int>
/// [depth] 2 = List<List<List<int>>>.
List getNestedIntList(int depth) =>
    getNestedList<int>(depth: depth, valueList: <int>[]);

/// Get nested List with a nullable int child. See [getNestedIntList].
List getNestedNullableIntList(int depth) =>
    getNestedList<int?>(depth: depth, valueList: <int?>[]);

/// Get a List<double> with 0 or more parent lists.
///
/// Specify [depth] to added one or more parent Lists.
///
/// Example:
/// [depth] 0 = List<double>
/// [depth] 2 = List<List<List<double>>>.
List getNestedDoubleList(int depth) =>
    getNestedList<double>(depth: depth, valueList: <double>[]);

/// Get nested List with a nullable double child. See [getNestedDoubleList].
List getNestedNullableDoubleList(int depth) =>
    getNestedList<double?>(depth: depth, valueList: <double?>[]);

/// Get a List<bool> with 0 or more parent lists.
///
/// Specify [depth] to added one or more parent Lists.
///
/// Example:
/// [depth] 0 = List<bool>
/// [depth] 2 = List<List<List<bool>>>.
List getNestedBoolList(int depth) =>
    getNestedList<bool>(depth: depth, valueList: <bool>[]);

/// Get nested List with a nullable bool child. See [getNestedBoolList].
List getNestedNullableBoolList(int depth) =>
    getNestedList<bool?>(depth: depth, valueList: <bool?>[]);