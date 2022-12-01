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

import "../ast/ast.dart";

/// All classes annotated with @squint will be processed by the squint library.
const squint = _Squint();

class _Squint {
  const _Squint();
}

/// Set value of field with value of JSON element with [name].
class JsonValue {
  /// Configure [JsonValue] to use this [name] tag.
  const JsonValue(this.name);

  /// Json tag to retrieve.
  final String name;
}

/// Encode a (non-standard) dart type to a JsonElement.
class JsonEncode<T> {
  /// Configure [JsonEncode] to encode a value [using].
  const JsonEncode({required this.using});

  /// Function to convert data of type T to a [JsonElement].
  final JsonElement Function(T t) using;
}

/// Decode a JsonElement to a non-standard dart type.
class JsonDecode<T, R> {
  /// Configure [JsonDecode] to decode a [JsonElement] [using].
  const JsonDecode({required this.using});

  /// Function to convert a [JsonElement] to data of type T.
  final T Function(R t) using;
}
