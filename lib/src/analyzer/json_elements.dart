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

import '../../squint.dart';
import 'json_decoder.dart';
import "list_decoder.dart";

/// A (part of) JSON, one of:
/// - [UnparsedJsonElement] unprocessed.
/// - [ParsedJsonElement] processed.
abstract class JsonElement {
  /// Construct a new [JsonElement].
  const JsonElement();
}

/// A JsonObject that needs processing.
class UnparsedJsonElement extends JsonElement {
  /// Construct a new [UnparsedJsonElement].
  const UnparsedJsonElement(this.text);

  /// The JSON content to be processed.
  final String text;
}

/// A (part of) JSON.
class ParsedJsonElement<T> extends JsonElement {
  /// Construct a new [ParsedJsonElement].
  const ParsedJsonElement({
    required this.key,
    required this.data,
  });

  /// The JSON key (tag name).
  final String key;

  /// The JSON data of type T.
  final T data;
}

/// JSON Object (Map) element.
class JsonObject extends JsonElement {

  /// Construct a new [JsonObject] instance.
  JsonObject(this.data);

  /// JSON content parsed as Map.
  final Map<String, JsonElement> data;

  /// Get JsonElement by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonElement byKey(String key) {
    if(!data.containsKey(key)) {
      throw SquintException("JSON key not found: '$key'");
    }

    return data[key]!;
  }

  /// Get JsonElement by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonString string(String key) {
    if(!data.containsKey(key)) {
      throw SquintException("JSON key not found: '$key'");
    }

    return data[key]! as JsonString;
  }

  ///
  JsonArray<dynamic> array(String key) {
    if(!data.containsKey(key)) {
      throw SquintException("JSON key not found: '$key'");
    }

    return data[key]! as JsonArray;
  }

  ///
  JsonObject object(String key) {
    if(!data.containsKey(key)) {
      throw SquintException("JSON key not found: '$key'");
    }

    return data[key]! as JsonObject;
  }
}

/// A JSON element containing a String value.
///
/// Example:
///
/// ```
/// {"name":"Luke Skywalker"}
/// ```
///
/// key = name
/// data = Luke Skywalker
class JsonString extends ParsedJsonElement<String> {

  /// Construct a new [JsonString] instance.
  const JsonString({
    required String key,
    required String data,
  }): super(key: key, data: data);

}

/// A JSON element containing a double value.
///
/// Example:
///
/// ```
/// {"friends":0}
/// ```
///
/// key = friends
/// data = 0
class JsonNumber extends ParsedJsonElement<double> {

  /// Construct a new [JsonNumber] instance.
  const JsonNumber({
    required String key,
    required double data,
  }): super(key: key, data: data);

  factory JsonNumber.parse({
    required String key,
    required String data,
  }) => JsonNumber(key: key, data: double.parse(data));

}

/// A JSON element containing a null value.
///
/// Example:
///
/// ```
/// {"foo":null}
/// ```
///
/// key = foo
/// data = null
class JsonNull extends ParsedJsonElement<Object?> {

  /// Construct a new [JsonNull] instance.
  const JsonNull({
    required String key,
  }): super(key: key, data: null);

}

/// A JSON element containing a bool value.
///
/// Example:
///
/// ```
/// {"dark-side":false}
/// ```
///
/// key = dark-side
/// data = false
class JsonBoolean extends ParsedJsonElement<bool> {

  /// Construct a new [JsonBoolean] instance.
  const JsonBoolean({
    required String key,
    required bool data,
  }): super(key: key, data: data);

}

/// A JSON element containing an Array value.
///
/// Example:
///
/// ```
///   "padawans":["Anakin", "Obi-Wan"]
/// ```
///
/// key = padawans
/// data = ["Anakin", "Obi-Wan"]
/// T = String
class JsonArray<T> extends ParsedJsonElement<List<T>> {

  /// Construct a new [JsonArray] instance.
  const JsonArray({
    required String key,
    required List<T> data,
  }): super(key: key, data: data);

  ///
  static JsonArray<dynamic> parse({
    required String key,
    required String content,
    int depth = 1,
  }) => JsonArray<dynamic>(
      key: key,
      data: content.unwrapList(maxDepth: depth).toList(),
  );

}