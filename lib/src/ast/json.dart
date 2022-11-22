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

import "../../squint.dart";
import "../common/common.dart";
import "../decoder/array.dart";
import "../encoder/formatter.dart";

/// A (part of) JSON.
abstract class JsonElement<T> {
  /// Construct a new [JsonElement].
  const JsonElement();

  ///
  T get data;

  ///
  String get stringify;
}

/// A (part of) JSON containing data of type T.
abstract class JsonElementType<T> extends JsonElement<T> {
  /// Construct a new [JsonElementType].
  const JsonElementType({
    required this.key,
    required this.data,
  });

  /// The JSON key (tag name).
  final String key;

  /// The JSON data of type T.
  @override
  final T data;
}

/// JSON Object (Map) element.
class JsonObject extends JsonElementType<Map<String, JsonElement>> {
  /// Construct a new [JsonObject] instance.
  JsonObject(Map<String, JsonElement> data, [String key = ""])
      : super(key: key, data: data);

  /// Construct a new [JsonObject] using the specified key values of each [JsonElementType].
  factory JsonObject.elements(List<JsonElementType> elements) =>
      JsonObject({for (var element in elements) element.key: element});

  /// Get JsonElement by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonElement byKey(String key) {
    if (!data.containsKey(key)) {
      throw SquintException("JSON key not found: '$key'");
    }

    return data[key]!;
  }

  /// Get JsonElement by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonString string(String key) {
    if (!data.containsKey(key)) {
      throw SquintException("JSON key not found: '$key'");
    }

    return data[key]! as JsonString;
  }

  ///
  JsonArray<List<T>> array<T>(String key) {
    if (!data.containsKey(key)) {
      throw SquintException("JSON key not found: '$key'");
    }

    final array = data[key]!;

    return JsonArray<List<T>>(
      key: key,
      data: (array.data as List).cast<T>().toList(),
    );
  }

  ///
  JsonBoolean boolean(String key) {
    if (!data.containsKey(key)) {
      throw SquintException("JSON key not found: '$key'");
    }

    return data[key]! as JsonBoolean;
  }

  ///
  JsonObject object(String key) {
    if (!data.containsKey(key)) {
      throw SquintException("JSON key not found: '$key'");
    }

    return data[key]! as JsonObject;
  }

  ///
  @override
  String get stringify {
    final json = key == ""
        ? '{\n ${data.values.map((o) => o.stringify).join(",\n")}\n}'
        : '"$key": {\n ${data.values.map((o) => o.stringify).join(",\n")}\n}';
    return json.formatJson();
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
class JsonString extends JsonElementType<String> {
  /// Construct a new [JsonString] instance.
  const JsonString({
    required String key,
    required String data,
  }) : super(key: key, data: data);

  ///
  @override
  String get stringify {
    return '"$key": "$data"';
  }
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
class JsonNumber extends JsonElementType<double> {
  /// Construct a new [JsonNumber] instance.
  const JsonNumber({
    required String key,
    required double data,
  }) : super(key: key, data: data);

  ///
  factory JsonNumber.parse({
    required String key,
    required String data,
  }) =>
      JsonNumber(key: key, data: double.parse(data));

  ///
  @override
  String get stringify {
    return '"$key": $data';
  }
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
class JsonNull extends JsonElementType<Object?> {
  /// Construct a new [JsonNull] instance.
  const JsonNull({
    required String key,
  }) : super(key: key, data: null);

  ///
  @override
  String get stringify {
    return '"$key": null';
  }
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
class JsonBoolean extends JsonElementType<bool> {
  /// Construct a new [JsonBoolean] instance.
  const JsonBoolean({
    required String key,
    required bool data,
  }) : super(key: key, data: data);

  ///
  @override
  String get stringify {
    return '"$key": $data';
  }
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
class JsonArray<T> extends JsonElementType<T> {
  /// Construct a new [JsonArray] instance.
  const JsonArray({
    required String key,
    required T data,
  }) : super(key: key, data: data);

  ///
  static JsonArray parse({
    required String key,
    required String content,
    int depth = 1,
  }) =>
      JsonArray<dynamic>(
        key: key,
        data: content.unwrapList(maxDepth: depth).toList(),
      );

  ///
  @override
  String get stringify {
    return '"$key":${(data as List).map<dynamic>(_quotedStringValue).toList()}';
  }
}

dynamic _quotedStringValue(dynamic value) {
  if (value is List) {
    return value.map<dynamic>(_quotedStringValue).toList();
  }

  if (value is String) {
    return '"$value"';
  }

  if (value is JsonElement) {
    return _quotedStringValue(value.data);
  }

  return value;
}
