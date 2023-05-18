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

// ignore_for_file: avoid_annotating_with_dynamic

import "../common/common.dart";
import "../converters/converters.dart";
import "../decoder/decoder.dart";
import "../encoder/encoder.dart";
import "ast.dart";

/// A single JSON node representation consisting of
/// a [String] key and [T] data.
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
abstract class JsonNode<T> {
  ///extends JsonNode<T> {
  /// Construct a new [JsonNode].
  const JsonNode({
    required this.key,
    required this.data,
    this.annotations = const <TypeAnnotation>[],
  });

  /// The JSON key (tag name).
  final String key;

  /// The JSON data of type T.
  final T data;

  /// Metadata annotations which alter (de)serialization of this node.
  final List<TypeAnnotation> annotations;

  /// Convert to formatted JSON String.
  String get stringify => '"$key": ${maybeAddQuotes(data)}';
}

/// JSON node of unknown type.
///
/// The data is stored as dynamic
/// because the type can not be determined.
/// Value is possibly null.
UntypedJsonNode dynamicValue({
  required String key,
  dynamic data,
}) =>
    UntypedJsonNode(key: key, data: data);

/// JSON Object (Map) element.
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
class JsonObjectOrNull extends JsonNode<Map<String, JsonNode>?> {
  /// Construct a new [JsonObjectOrNull] instance.
  const JsonObjectOrNull({required super.key, required super.data});

  /// Construct a new [JsonObjectOrNull] using the specified key values of each [JsonNode].
  factory JsonObjectOrNull.fromMap(
          {Map<String, dynamic>? data, String key = ""}) =>
      JsonObjectOrNull(
        data: data?.map(_buildJsonNodeMap),
        key: key,
      );

  /// Get data wrapped in [JsonObject] or null if data is not present.
  JsonObject? get asObjectOrNull =>
      data == null ? null : JsonObject(data: data!);
}

///
class JsonEnumeratedObject<T> extends JsonObject {
  ///
  JsonEnumeratedObject({
    required super.data,
    required this.keyToString,
    required this.keyToEnumValue,
    String key = "",
  }) : super(key: key);

  /// Convert enumerated key to String value.
  final String Function(T) keyToString;

  /// Convert String key to enumerated value.
  final T Function(String) keyToEnumValue;

  /// Construct a new [JsonObject] where each key is an enumerated value.
  static JsonObject fromEnumMap<T>(
          {required Map<T, dynamic> data,

          /// Convert enumerated key to String key.
          required String Function(T) keyToString,

          /// Convert String key to enumerated value.
          required T Function(String) keyToEnumValue,

          /// Node key.
          String key = ""}) =>
      JsonEnumeratedObject(
          keyToEnumValue: keyToEnumValue,
          keyToString: keyToString,
          key: key,
          data: data
              .map((key, value) => MapEntry(keyToString.call(key), value))
              .map(_buildJsonNodeMap));
}

/// JSON Object (Map) element.
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
class JsonObject extends JsonNode<Map<String, JsonNode>> {
  /// Construct a new [JsonObject] instance.
  JsonObject({
    required Map<String, JsonNode> data,
    String key = "",
  }) : super(key: key, data: data);

  /// Construct a new [JsonObject] using the specified key values of each [JsonNode].
  factory JsonObject.fromNodes({
    required List<JsonNode> nodes,
    String key = "",
  }) =>
      JsonObject(
        data: {for (var node in nodes) node.key: node},
        key: key,
      );

  /// Construct a new [JsonObject] using the specified key values of each [JsonNode].
  factory JsonObject.fromMap(
          {required Map<String, dynamic> data, String key = ""}) =>
      JsonObject(
        data: data.map(_buildJsonNodeMap),
        key: key,
      );

  /// Construct a new [JsonObject] where each key is an enumerated value.
  static JsonObject fromEnumMap<T>(
          {required Map<T, dynamic> data,

          /// Convert enumerated key to String key.
          required String Function(T) keyToString,

          /// Node key.
          String key = ""}) =>
      JsonObject(
          key: key,
          data: data
              .map((key, value) => MapEntry(keyToString.call(key), value))
              .map(_buildJsonNodeMap));

  /// Get JsonNode by [String] key.
  ///
  /// Return [JsonMissing] is key is not found.
  JsonNode byKey(String key) {
    if (hasKey(key)) {
      return data[key]!;
    }
    return JsonMissing(key: key);
  }

  /// Returns true if JSON content contains key.
  bool hasKey(String key) => data.containsKey(key);

  /// Get [String] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  String string(String key) => stringNode(key).data;

  /// Get [String] or null by [String] key.
  String? stringOrNull(String key) => stringNodeOrNull(key)?.data;

  /// Get [JsonString] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonString stringNode(String key) => _byKeyOfType<JsonString>(key, false)!;

  /// Get [JsonString] or null by [String] key.
  JsonString? stringNodeOrNull(String key) =>
      _byKeyOfType<JsonString>(key, true);

  /// Get [double] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  double float(String key) => floatNode(key).data;

  /// Get [double] or null by [String] key.
  double? floatOrNull(String key) => floatNodeOrNull(key)?.data;

  /// Get [JsonFloatingNumber] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonFloatingNumber floatNode(String key) =>
      _byKeyOfType<JsonFloatingNumber>(key, false)!;

  /// Get [JsonFloatingNumber] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonFloatingNumber? floatNodeOrNull(String key) =>
      _byKeyOfType<JsonFloatingNumber>(key, true);

  /// Get [int] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  int integer(String key) => integerNode(key).data;

  /// Get [int] or null by [String] key.
  int? integerOrNull(String key) => integerNodeOrNull(key)?.data;

  /// Get [JsonIntegerNumber] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonIntegerNumber integerNode(String key) =>
      _byKeyOfType<JsonIntegerNumber>(key, false)!;

  /// Get [JsonIntegerNumber] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonIntegerNumber? integerNodeOrNull(String key) =>
      _byKeyOfType<JsonIntegerNumber>(key, true);

  /// Get [List] with child [T] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  List<T> array<T>(
    String key, {
    T Function(JsonObject)? decodeFromJsonObject,
    Function? decoder,
    List? childType,
  }) =>
      arrayNode<T>(key,
              decodeFromJsonObject: decodeFromJsonObject,
              decoder: decoder,
              childType: childType)
          .data;

  /// Get [List] with child [T] or null by [String] key.
  List<T>? arrayOrNull<T>(
    String key, {
    T Function(JsonObject)? decodeFromJsonObject,
    Function? decoder,
    List? childType,
  }) =>
      arrayNodeOrNull<T>(key,
              decodeFromJsonObject: decodeFromJsonObject,
              decoder: decoder,
              childType: childType)
          ?.data;

  /// Get [JsonArray] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonArray<List<T>> arrayNode<T>(
    String key, {
    T Function(JsonObject)? decodeFromJsonObject,
    Function? decoder,
    List? childType,
  }) {
    final dynamicData = byKey(key).data as List;
    final expectedChildType = T.toString();
    final actualChildType = dynamicData.runtimeType
        .toString()
        .removePrefixIfPresent("List<")
        .removePostfixIfPresent(">");

    // Types match so cast and return List<T>.
    if (expectedChildType == actualChildType) {
      return JsonArray<List<T>>(
        key: key,
        data: dynamicData.cast<T>().toList(),
      );
    }

    // Use decoder to convert to expected child Type
    // and return as List<T>.
    if (decodeFromJsonObject != null) {
      final objects = dynamicData.map<JsonObject>((dynamic e) {
        if (e is Map) {
          if (e.values.isNotEmpty && e.values.first is JsonNode) {
            return JsonObject(data: e as Map<String, JsonNode>);
          } else {
            return JsonObject.fromMap(data: e as Map<String, dynamic>);
          }
        } else {
          throw SquintException(
              "Expected Map type but found: ${e.runtimeType}");
        }
      }).toList();
      return JsonArray<List<T>>(
        key: key,
        data: objects.map(decodeFromJsonObject).toList().cast<T>().toList(),
      );
    }

    var depth = 0;
    var nextChild = actualChildType;
    while (nextChild.startsWith("List<")) {
      nextChild =
          nextChild.removePrefixIfPresent("List<").removePostfixIfPresent(">");
      depth += 1;
    }

    final isMapType = mapRegex.firstMatch(nextChild);
    if (isMapType != null) {
      if (depth == 0) {
        final objects = dynamicData.map<JsonObject>((dynamic e) {
          if (e is Map) {
            if (e.values.isNotEmpty && e.values.first is JsonNode) {
              return JsonObject(data: e as Map<String, JsonNode>);
            } else {
              return JsonObject.fromMap(data: e as Map<String, dynamic>);
            }
          } else {
            throw SquintException(
                "Expected Map type but found: ${e.runtimeType}");
          }
        }).toList();
        final maps = objects.map<dynamic>((e) {
          final type = e.valuesAllOfSameType;
          if (type is StringType) {
            final stringMap = <String, String>{};
            e.data.forEach((key, value) {
              stringMap[key] = value.data as String;
            });
            return stringMap;
          } else if (type is IntType) {
            final intMap = <String, int>{};
            e.data.forEach((key, value) {
              intMap[key] = value.data as int;
            });
            return intMap;
          } else if (type is DoubleType) {
            final doubleMap = <String, double>{};
            e.data.forEach((key, value) {
              doubleMap[key] = value.data as double;
            });
            return doubleMap;
          } else if (type is BooleanType) {
            final boolMap = <String, bool>{};
            e.data.forEach((key, value) {
              boolMap[key] = value.data as bool;
            });
            return boolMap;
          } else {
            if (decoder != null) {
              try {
                return decoder.call(e);
              } catch (e) {
                "Tried to decode data with $decoder but failed."
                    .log(context: e);
              }
            }

            return e.data;
          }
        }).toList();
        return JsonArray<List<T>>(
          key: key,
          data: maps.toList().cast<T>().toList(),
        );
      }
    }

    final nodes = dynamicData.decodeList;
    final decoded = <String, JsonNode>{};

    if (decoder != null) {
      try {
        nodes.forEach((key, value) {
          decoded[key] = CustomJsonNode(data: decoder.call(value));
        });
      } catch (e) {
        "Decoding failed due to:".log(context: e);
        throw SquintException("Tried to decode data with $decoder but failed.");
      }
    }

    if (decoded.isNotEmpty) {
      final decodedList = decoded.toList(valueList: childType);
      return JsonArray<List<T>>(
        key: key,
        data: decodedList.cast<T>(),
      );
    }

    // Return as List with child T.
    return JsonArray<List<T>>(
      key: key,
      data: nodes.toList().cast<T>().toList(),
    );
  }

  /// Get [JsonArray] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonArray<List<T>>? arrayNodeOrNull<T>(
    String key, {
    T Function(JsonObject)? decodeFromJsonObject,
    Function? decoder,
    List? childType,
  }) {
    final element = byKey(key);

    if (element.data == null) {
      return null;
    }

    return JsonArray<List<T>>(
      key: key,
      data: (byKey(key).data as List).cast<T>().toList(),
    );
  }

  /// Get [bool] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  bool boolean(String key) => booleanNode(key).data;

  /// Get [bool] or null by [String] key.
  bool? booleanOrNull(String key) => booleanNodeOrNull(key)?.data;

  /// Get [JsonBoolean] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonBoolean booleanNode(String key) => _byKeyOfType<JsonBoolean>(key, false)!;

  /// Get [JsonBoolean] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonBoolean? booleanNodeOrNull(String key) =>
      _byKeyOfType<JsonBoolean>(key, true);

  /// Get Map<String,R> by [String] key.
  ///
  /// Throws [SquintException] if key is not found
  /// or values are not all of type [R].
  Map<String, R> object<R>(String key) => objectNode(key).getDataAsMap();

  /// Get Map<String,R> by [String] key.
  ///
  /// Throws [SquintException] if key is not found
  /// or values are not all of type [R].
  Map<String, R>? objectOrNull<R>(String key) =>
      objectNodeOrNull(key)?.getDataAsMap();

  /// Get [JsonObject] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonObject objectNode(String key) => objectNodeOrNull(key)!;

  /// Get [JsonObject] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonObject? objectNodeOrNull(String key) {
    final object = _byKeyOfType<JsonNode<Map<String, JsonNode>>>(key, true);

    if (object == null) {
      return null;
    }

    return JsonObject(data: object.data, key: object.key);
  }

  /// Get Map<T,R> by [String] key.
  ///
  /// Throws [SquintException] if key is not found
  /// or values are not all of type [R].
  Map<T, R> enumObject<T, R>({
    required String key,
    required T Function(String) keyToEnumValue,
  }) =>
      objectNode(key).getDataAsEnumMap(keyToEnumValue: keyToEnumValue);

  /// Get Map<T,R> by [String] key.
  ///
  /// Throws [SquintException] if key is not found
  /// or values are not all of type [R].
  Map<T, R>? enumObjectOrNull<T, R>({
    required String key,
    required T Function(String) keyToEnumValue,
  }) =>
      objectNodeOrNull(key)?.getDataAsEnumMap(keyToEnumValue: keyToEnumValue);

  /// Return raw (unwrapped) object data as Map<String, R>
  /// where R is not of type JsonNode but a dart StandardType (String, bool, etc).
  Map<T, R> getDataAsEnumMap<T, R>({
    required T Function(String) keyToEnumValue,
  }) =>
      data.map(
          (key, value) => MapEntry(keyToEnumValue.call(key), value.data as R));

  /// Return raw (unwrapped) object data as Map<String, R>
  /// where R is not of type JsonNode but a dart StandardType (String, bool, etc).
  Map<String, R> getDataAsMap<R>() =>
      data.map((key, value) => MapEntry(key, value.data as R));

  R? _byKeyOfType<R>(String key, bool nullable) {
    final data = byKey(key);

    if (data is R) {
      return data as R;
    }

    if (!nullable) {
      if (data is JsonNull) {
        throw SquintException(
          "JSON key ($key) has null value which is not allowed for a non-null Type.",
        );
      }

      if (data is JsonMissing) {
        throw SquintException("JSON key not found: '$key'");
      }

      throw SquintException(
        "Data is not of expected type. Expected: '$R'. Actual: ${data.runtimeType}",
      );
    }

    return null;
  }

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

/// A JsonObject which children are all of the same type.
///
/// When all children are of the same type then
/// a JSON node can be deserialized as Map with
/// strongly typed children. This is mostly useful
/// when a Map is nested inside one or more Lists.
class JsonMap<T> extends JsonNode<Map<String, JsonNode<T>>> {
  /// Create a new JsonMap.
  const JsonMap({required super.key, required super.data});

  /// Convert to (standard) formatted JSON String.
  @override
  String get stringify => _toRawJson.formatJson();

  String get _toRawJson => key == ""
      ? '{\n ${data.values.map((o) => o.stringify).join(",\n")}\n}'
      : '"$key": {\n ${data.values.map((o) => o.stringify).join(",\n")}\n}';

  /// Return raw (unwrapped) object data as Map<String, R>
  /// where R is not of type JsonNode but a dart StandardType (String, bool, etc).
  Map<String, T> get dataTyped => data.map((key, value) {
        return MapEntry(key, value.data);
      });
}

MapEntry<String, JsonNode> _buildJsonNodeMap(String key, dynamic value) {
  if (value == null) {
    return MapEntry(key, JsonNull(key: key));
  }

  if (value is JsonNode) {
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
    return MapEntry(
        key, JsonObject.fromMap(data: value as Map<String, dynamic>));
  }

  throw SquintException(
    "Unable to convert Map<String, dynamic> to Map<String,JsonNode>",
  );
}

///
class CustomJsonNode extends JsonNode<dynamic> {
  ///
  CustomJsonNode({required super.data}) : super(key: "");
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
class JsonString extends JsonNode<String> {
  /// Construct a new [JsonString] instance.
  const JsonString({
    required String key,
    required String data,
  }) : super(key: key, data: data);
}

/// A JSON element containing a String or null value.
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
class JsonStringOrNull extends JsonNode<String?> {
  /// Construct a new [JsonStringOrNull] instance.
  const JsonStringOrNull({
    required String key,
    required String? data,
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
class JsonFloatingNumber extends JsonNode<double> {
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

/// A JSON element containing a double value or null.
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
class JsonFloatingNumberOrNull extends JsonNode<double?> {
  /// Construct a new [JsonFloatingNumberOrNull] instance.
  const JsonFloatingNumberOrNull({
    required String key,
    required double? data,
  }) : super(key: key, data: data);

  /// Construct a new [JsonFloatingNumber] instance
  /// by parsing the data as double value.
  factory JsonFloatingNumberOrNull.parse({
    required String key,
    required String? data,
  }) =>
      JsonFloatingNumberOrNull(
          key: key, data: data != null ? double.parse(data) : null);
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
class JsonIntegerNumber extends JsonNode<int> {
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

/// A JSON element containing an int value or null.
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
class JsonIntegerNumberOrNull extends JsonNode<int?> {
  /// Construct a new [JsonIntegerNumberOrNull] instance.
  const JsonIntegerNumberOrNull({
    required String key,
    required int? data,
  }) : super(key: key, data: data);

  /// Construct a new [JsonIntegerNumberOrNull] instance
  /// by parsing the data as int value.
  factory JsonIntegerNumberOrNull.parse({
    required String key,
    required String? data,
  }) =>
      JsonIntegerNumberOrNull(
          key: key, data: data == null ? null : int.parse(data));
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
class JsonNull extends JsonNode<Object?> {
  /// Construct a new [JsonNull] instance.
  const JsonNull({
    required String key,
  }) : super(key: key, data: null);

  /// Convert to formatted JSON String.
  @override
  String get stringify => '"$key":null';
}

/// A JSON element containing a null value and key.
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
class JsonMissing extends JsonNode<Object?> {
  /// Construct a new [JsonMissing] instance.
  const JsonMissing({
    required String key,
  }) : super(key: key, data: null);

  /// Convert to formatted JSON String.
  @override
  String get stringify => "";
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
class JsonBoolean extends JsonNode<bool> {
  /// Construct a new [JsonBoolean] instance.
  const JsonBoolean({
    required String key,
    required bool data,
  }) : super(key: key, data: data);
}

/// A JSON element containing a bool value or null.
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
class JsonBooleanOrNull extends JsonNode<bool?> {
  /// Construct a new [JsonBooleanOrNull] instance.
  const JsonBooleanOrNull({
    required String key,
    required bool? data,
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
class JsonArray<T> extends JsonNode<T> {
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
  }) {
    final data = content.decodeJsonArray(maxDepth: depth).toList();
    return JsonArray<dynamic>(
      key: key,
      data: data,
    );
  }

  /// Convert to formatted JSON String.
  @override
  String get stringify => '"$key":${maybeAddQuotes(data)}';
}

/// A JSON element containing an Array value or null.
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
class JsonArrayOrNull<T> extends JsonNode<T> {
  /// Construct a new [JsonArrayOrNull] instance.
  const JsonArrayOrNull({
    required String key,
    required T data,
  }) : super(key: key, data: data);

  /// Construct a new [JsonFloatingNumber] instance
  /// by parsing the data as List value.
  static JsonArrayOrNull parse({
    required String key,
    required String? content,
    int depth = 1,
  }) {
    if (content == null) {
      return JsonArrayOrNull(key: key, data: null);
    }

    final data = content.decodeJsonArray(maxDepth: depth).toList();

    return JsonArrayOrNull<dynamic>(
      key: key,
      data: data,
    );
  }

  /// Convert to formatted JSON String.
  @override
  String get stringify => '"$key":${maybeAddQuotes(data)}';
}
