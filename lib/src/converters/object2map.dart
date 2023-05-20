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

import "../ast/ast.dart";
import "node2abstract.dart";

/// Convert a [JsonObject] to a [JsonMap].
///
/// {@category decoder}
extension JsonObject2JsonMap on JsonObject {
  ///
  AbstractType? get valuesAllOfSameType {
    final values = data.values.map((e) => e.toAbstractType(e.key)).toSet();
    if (values.length == 1) {
      return values.first;
    }
    return null;
  }

  /// Convert a [JsonObject]
  /// to a [JsonMap] with [String] children.
  ///
  /// {@category decoder}
  JsonMap<String> get toStringMap {
    final output = <String, JsonString>{};
    data.forEach((key, node) {
      output[key] = JsonString(
        key: node.key,
        data: node.data as String,
      );
    });
    return JsonMap<String>(key: key, data: output);
  }

  /// Convert a [JsonObject]
  /// to a [JsonMap] with [int] children.
  ///
  /// {@category decoder}
  JsonMap<int> get toIntegerMap {
    final output = <String, JsonIntegerNumber>{};
    data.forEach((key, node) {
      output[key] = JsonIntegerNumber(
        key: node.key,
        data: node.data as int,
      );
    });
    return JsonMap<int>(key: key, data: output);
  }

  /// Convert a [JsonObject]
  /// to a [JsonMap] with [double] children.
  ///
  /// {@category decoder}
  JsonMap<double> get toFloatMap {
    final output = <String, JsonFloatingNumber>{};
    data.forEach((key, node) {
      output[key] = JsonFloatingNumber(
        key: node.key,
        data: node.data as double,
      );
    });
    return JsonMap<double>(key: key, data: output);
  }

  /// Convert a [JsonObject]
  /// to a [JsonMap] with [bool] children.
  ///
  /// {@category decoder}
  JsonMap<bool> get toBooleanMap {
    final output = <String, JsonBoolean>{};
    data.forEach((key, node) {
      output[key] = JsonBoolean(
        key: node.key,
        data: node.data as bool,
      );
    });
    return JsonMap<bool>(key: key, data: output);
  }
}
