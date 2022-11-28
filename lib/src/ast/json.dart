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

/// A (part of) JSON.
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
abstract class JsonElement<T> {
  /// Construct a new [JsonElement].
  const JsonElement();

  /// The JSON data value.
  T get data;

  /// Convert to formatted JSON String.
  String get stringify;
}

/// A (part of) JSON containing data of type T.
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
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

  /// Convert to formatted JSON String.
  @override
  String get stringify => '"$key": ${maybeAddQuotes(data)}';
}

/// JSON Object (Map) element.
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
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

  /// Get [JsonString] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonString string(String key) =>
      _byKeyOfType<JsonString>(key, false)!;

  /// Get [JsonString] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonString? stringOrNull(String key) =>
      _byKeyOfType<JsonString>(key, true);

  /// Get [JsonNumber] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonNumber number(String key) =>
      _byKeyOfType<JsonNumber>(key, false)!;

  /// Get [JsonNumber] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonNumber? numberOrNull(String key) =>
      _byKeyOfType<JsonNumber>(key, true);

  /// Get [JsonArray] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonArray<List<T>> array<T>(String key) => JsonArray<List<T>>(
    key: key,
    data: (byKey(key).data as List).cast<T>().toList(),
  );

  /// Get [JsonArray] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonArray<List<T>>? arrayOrNull<T>(String key) {
    final element = byKey(key);

    if(element.data == null) {
      return null;
    }

    return JsonArray<List<T>>(
      key: key,
      data: (byKey(key).data as List).cast<T>().toList(),
    );
  }

  /// Get [JsonBoolean] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonBoolean boolean(String key) =>
      _byKeyOfType<JsonBoolean>(key, false)!;

  /// Get [JsonBoolean] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonBoolean? booleanOrNull(String key) =>
      _byKeyOfType<JsonBoolean>(key, true);

  /// Get [JsonObject] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonObject object(String key) =>
      _byKeyOfType<JsonObject>(key, false)!;

  /// Get [JsonObject] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonObject? objectOrNull(String key) =>
      _byKeyOfType<JsonObject>(key, true);

  R? _byKeyOfType<R>(String key, bool nullable) {
    final data = byKey(key);

    if (data is R) {
      return data as R;
    }

    if(nullable && data is JsonNull) {
      return null;
    }

    throw SquintException(
      "Data is not of expected type. Expected: '$R'. Actual: ${data.runtimeType}",
    );
  }

  /// Convert to formatted JSON String.
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
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
class JsonString extends JsonElementType<String> {
  /// Construct a new [JsonString] instance.
  const JsonString({
    required String key,
    required String data,
  }) : super(key: key, data: data);
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
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
class JsonNumber extends JsonElementType<double> {
  /// Construct a new [JsonNumber] instance.
  const JsonNumber({
    required String key,
    required double data,
  }) : super(key: key, data: data);

  /// Construct a new [JsonNumber] instance
  /// by parsing the data as double value.
  factory JsonNumber.parse({
    required String key,
    required String data,
  }) =>
      JsonNumber(key: key, data: double.parse(data));
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
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
class JsonNull extends JsonElementType<Object?> {
  /// Construct a new [JsonNull] instance.
  const JsonNull({
    required String key,
  }) : super(key: key, data: null);

  /// Convert to formatted JSON String.
  @override
  String get stringify => '"$key": null';
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
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
class JsonBoolean extends JsonElementType<bool> {
  /// Construct a new [JsonBoolean] instance.
  const JsonBoolean({
    required String key,
    required bool data,
  }) : super(key: key, data: data);
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
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
class JsonArray<T> extends JsonElementType<T> {
  /// Construct a new [JsonArray] instance.
  const JsonArray({
    required String key,
    required T data,
  }) : super(key: key, data: data);

  /// Construct a new [JsonNumber] instance
  /// by parsing the data as List value.
  static JsonArray parse({
    required String key,
    required String content,
    int depth = 1,
  }) =>
      JsonArray<dynamic>(
        key: key,
        data: content.unwrapList(maxDepth: depth).toList(),
      );

  /// Convert to formatted JSON String.
  @override
  String get stringify => '"$key":${maybeAddQuotes(data)}';
}
