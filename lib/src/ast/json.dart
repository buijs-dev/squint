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

import "../common/common.dart";
import "../decoder/decoder.dart";
import "../encoder/encoder.dart";

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
  factory JsonObject.elements(List<JsonElementType> elements,
          [String key = ""]) =>
      JsonObject({for (var element in elements) element.key: element}, key);

  /// Construct a new [JsonObject] using the specified key values of each [JsonElementType].
  factory JsonObject.fromMap(Map<String, dynamic> data, [String key = ""]) =>
      JsonObject(data.map(_buildJsonElement), key);

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
  JsonString string(String key) => _byKeyOfType<JsonString>(key, false)!;

  /// Get [JsonString] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonString? stringOrNull(String key) => _byKeyOfType<JsonString>(key, true);

  /// Get [JsonFloatingNumber] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonFloatingNumber float(String key) =>
      _byKeyOfType<JsonFloatingNumber>(key, false)!;

  /// Get [JsonFloatingNumber] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonFloatingNumber? floatOrNull(String key) =>
      _byKeyOfType<JsonFloatingNumber>(key, true);

  /// Get [JsonIntegerNumber] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonIntegerNumber integer(String key) =>
      _byKeyOfType<JsonIntegerNumber>(key, false)!;

  /// Get [JsonIntegerNumber] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonIntegerNumber? integerOrNull(String key) =>
      _byKeyOfType<JsonIntegerNumber>(key, true);

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

    if (element.data == null) {
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
  JsonBoolean boolean(String key) => _byKeyOfType<JsonBoolean>(key, false)!;

  /// Get [JsonBoolean] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonBoolean? booleanOrNull(String key) =>
      _byKeyOfType<JsonBoolean>(key, true);

  /// Get [JsonObject] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonObject object(String key) => _byKeyOfType<JsonObject>(key, false)!;

  /// Get [JsonObject] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonObject? objectOrNull(String key) => _byKeyOfType<JsonObject>(key, true);

  R? _byKeyOfType<R>(String key, bool nullable) {
    final data = byKey(key);

    if (data is R) {
      return data as R;
    }

    if (nullable && data is JsonNull) {
      return null;
    }

    throw SquintException(
      "Data is not of expected type. Expected: '$R'. Actual: ${data.runtimeType}",
    );
  }

  /// Return raw (unwrapped) object data as Map<String, R>
  /// where R is not of type JsonElement but a dart StandardType (String, bool, etc).
  Map<String, R> rawData<R>() => data.map((key, value) {
        dynamic data = value;

        while (data is JsonElement) {
          data = data.data;
        }

        return MapEntry(key, data as R);
      });

  JsonFormattingOptions? _formattingOptions;

  /// Set JSON formatting options used when generating JSON with [stringify].
  set formattingOptions(JsonFormattingOptions options) {
    _formattingOptions = options;
  }

  /// Get JSON formatting options which returns [standardJsonFormatting] if not set.
  JsonFormattingOptions get formattingOptions =>
      _formattingOptions ?? standardJsonFormatting;

  /// Convert to (standard) formatted JSON String.
  @override
  String get stringify => _toRawJson.formatJson();

  /// Convert to (custom) formatted JSON String.
  String stringifyWithFormatting(JsonFormattingOptions options) =>
      _toRawJson.formatJson(options);

  String get _toRawJson => key == ""
      ? '{\n ${data.values.map((o) => o.stringify).join(",\n")}\n}'
      : '"$key": {\n ${data.values.map((o) => o.stringify).join(",\n")}\n}';
}

MapEntry<String, JsonElement> _buildJsonElement(String key, dynamic value) {
  if (value == null) {
    return MapEntry(key, JsonNull(key: key));
  }

  if (value is JsonElement) {
    return MapEntry(key, value);
  }

  if (value is String) {
    return MapEntry(key, JsonString(key: key, data: value));
  }

  if (value is double) {
    return MapEntry(key, JsonFloatingNumber(key: key, data: value));
  }

  if (value is int) {
    return MapEntry(key, JsonIntegerNumber(key: key, data: value));
  }

  if (value is bool) {
    return MapEntry(key, JsonBoolean(key: key, data: value));
  }

  if (value is List) {
    return MapEntry(key, JsonArray<dynamic>(key: key, data: value));
  }

  if (value is Map && value.keys.every((dynamic k) => k is String)) {
    return MapEntry(key, JsonObject.fromMap(value as Map<String, dynamic>));
  }

  throw SquintException(
      "Unable to convert Map<String, dynamic> to Map<String,JsonElement>");
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
/// {"friends":0.0}
/// ```
///
/// key = friends
/// data = 0.0
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
class JsonFloatingNumber extends JsonElementType<double> {
  /// Construct a new [JsonFloatingNumber] instance.
  const JsonFloatingNumber({
    required String key,
    required double data,
  }) : super(key: key, data: data);

  /// Construct a new [JsonFloatingNumber] instance
  /// by parsing the data as double value.
  factory JsonFloatingNumber.parse({
    required String key,
    required String data,
  }) =>
      JsonFloatingNumber(key: key, data: double.parse(data));
}

/// A JSON element containing an int value.
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
class JsonIntegerNumber extends JsonElementType<int> {
  /// Construct a new [JsonIntegerNumber] instance.
  const JsonIntegerNumber({
    required String key,
    required int data,
  }) : super(key: key, data: data);

  /// Construct a new [JsonIntegerNumber] instance
  /// by parsing the data as int value.
  factory JsonIntegerNumber.parse({
    required String key,
    required String data,
  }) =>
      JsonIntegerNumber(key: key, data: int.parse(data));
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
  String get stringify => '"$key":null';
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

  /// Construct a new [JsonFloatingNumber] instance
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
