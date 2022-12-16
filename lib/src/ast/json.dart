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
import '../converters/object2map.dart';
import "../converters/undetermined.dart";
import "../decoder/decoder.dart";
import "../encoder/encoder.dart";
import 'ast.dart';

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
  });

  /// The JSON key (tag name).
  final String key;

  /// The JSON data of type T.
  final T data;

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
}) => UntypedJsonNode(key: key, data: data);

/// JSON Object (Map) element.
///
/// {@category ast}
/// {@category encoder}
/// {@category decoder}
class JsonObject extends JsonNode<Map<String, JsonNode>> {
  /// Construct a new [JsonObject] instance.
  JsonObject(Map<String, JsonNode> data, [String key = ""])
      : super(key: key, data: data);

  /// Construct a new [JsonObject] using the specified key values of each [JsonNode].
  factory JsonObject.elements(List<JsonNode> elements, [String key = ""]) =>
      JsonObject({for (var element in elements) element.key: element}, key);

  /// Construct a new [JsonObject] using the specified key values of each [JsonNode].
  factory JsonObject.fromMap(Map<String, dynamic> data, [String key = ""]) =>
      JsonObject(data.map(_buildJsonNodeMap), key);

  /// Get JsonNode by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonNode byKey(String key) {
    if (data.containsKey(key)) {
      return data[key]!;
    }
    throw SquintException("JSON key not found: '$key'");
  }

  /// Get [String] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  String stringValue(String key) => string(key).data;

  /// Get [String] or null by [String] key.
  String? stringValueOrNull(String key) => stringOrNull(key)?.data;

  /// Get [JsonString] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonString string(String key) => _byKeyOfType<JsonString>(key, false)!;

  /// Get [JsonString] or null by [String] key.
  JsonString? stringOrNull(String key) => _byKeyOfType<JsonString>(key, true);

  /// Get [double] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  double floatValue(String key) => float(key).data;

  /// Get [double] or null by [String] key.
  double? floatValueOrNull(String key) => floatOrNull(key)?.data;

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

  /// Get [int] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  int integerValue(String key) => integer(key).data;

  /// Get [int] or null by [String] key.
  int? integerValueOrNull(String key) => integerOrNull(key)?.data;

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

  /// Get [List] with child [T] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  List<T> arrayValue<T>(
      String key, {
        T Function(JsonObject)? decodeFromJsonObject,
        List<Function> decoders = const [],
        List? childType,
      }) =>
      array<T>(key, decodeFromJsonObject: decodeFromJsonObject, decoders: decoders, childType: childType).data;

  /// Get [List] with child [T] or null by [String] key.
  List<T>? arrayValueOrNull<T>(String key, {
    T Function(JsonObject)? decodeFromJsonObject,
    List<Function> decoders = const [],
    List? childType,
  }) =>
      arrayOrNull<T>(key, decodeFromJsonObject: decodeFromJsonObject, decoders: decoders, childType: childType)?.data;

  /// Get [JsonArray] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonArray<List<T>> array<T>(
      String key, {
        T Function(JsonObject)? decodeFromJsonObject,
        List<Function> decoders = const [],
        List? childType,
      }) {

    final dynamicData = byKey(key).data as List;
    final expectedChildType = T.toString();
    final actualChildType = dynamicData.runtimeType.toString()
        .removePrefixIfPresent("List<")
        .removePostfixIfPresent(">");

    // Types match so cast and return List<T>.
    if(expectedChildType == actualChildType) {
      return JsonArray<List<T>>(
        key: key,
        data: dynamicData.cast<T>().toList(),
      );
    }

    // Use decoder to convert to expected child Type
    // and return as List<T>.
    if(decodeFromJsonObject != null) {
      final objects = dynamicData.map<JsonObject>((dynamic e) {
        if(e is Map) {
          if(e.values.isNotEmpty && e.values.first is JsonNode) {
            return JsonObject(e as Map<String,JsonNode>);
          } else {
            return JsonObject.fromMap(e as Map<String, dynamic>);
          }
        } else {
          throw SquintException("Expected Map type but found: ${e.runtimeType}");
        }
      }).toList();
      return JsonArray<List<T>>(
        key: key,
        data: objects.map(decodeFromJsonObject).toList().cast<T>().toList(),
      );
    }

    var depth = 0;
    var nextChild = actualChildType;
    while(nextChild.startsWith("List<")) {
      nextChild = nextChild
          .removePrefixIfPresent("List<")
          .removePostfixIfPresent(">");
      depth +=1;
    }

    final isMapType = mapRegex.firstMatch(nextChild);
    if(isMapType != null) {
      if (depth == 0) {
        final objects = dynamicData.map<JsonObject>((dynamic e) {
          if(e is Map) {
            if(e.values.isNotEmpty && e.values.first is JsonNode) {
              return JsonObject(e as Map<String,JsonNode>);
            } else {
              return JsonObject.fromMap(e as Map<String, dynamic>);
            }
          } else {
            throw SquintException("Expected Map type but found: ${e.runtimeType}");
          }
        }).toList();
        final maps = objects.map<dynamic>((e) {
          final type = e.valuesAllOfSameType;
          if(type is StringType) {
            final stringMap = <String,String>{};
            e.data.forEach((key, value) {
              stringMap[key] = value.data as String;
            });
            return stringMap;
          } else if(type is IntType) {
            final intMap = <String,int>{};
            e.data.forEach((key, value) {
              intMap[key] = value.data as int;
            });
            return intMap;
          } else if(type is DoubleType) {
            final doubleMap = <String,double>{};
            e.data.forEach((key, value) {
              doubleMap[key] = value.data as double;
            });
            return doubleMap;
          } else if(type is BooleanType) {
            final boolMap = <String,bool>{};
            e.data.forEach((key, value) {
              boolMap[key] = value.data as bool;
            });
            return boolMap;
          } else {

            if(decoders.isNotEmpty) {

              for(final decoder in decoders) {
                try {
                  return decoder.call(e);
                } catch (e) {
                  "Tried to decode data with $decoder but failed.".log(context: e);
                }
              }

            }

            "All decoders failed or there are no decoders present. Returning data as-is.".log();
            return e.data;
          }
        }).toList();
        return JsonArray<List<T>>(
          key: key,
          data: maps.toList().cast<T>().toList(),
        );
      }
    }

    var hasDecodingFailure = false;
    final nodes = dynamicData.decodeList;
    final decoded = <String, JsonNode>{};

    if(decoders.isNotEmpty) {
      for(final decoder in decoders) {
        try {
          nodes.forEach((key, value) {
            decoded[key] = CustomJsonNode(data: decoder.call(value));
          });
        } catch (e) {
          "Tried to decode data with $decoder but failed.".log(context: e);
          hasDecodingFailure = true;
        }
      }
    }

    if(decoded.isNotEmpty && !hasDecodingFailure) {
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
  JsonArray<List<T>>? arrayOrNull<T>(String key, {
    T Function(JsonObject)? decodeFromJsonObject,
        List<Function> decoders = const [],
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
  bool booleanValue(String key) => boolean(key).data;

  /// Get [bool] or null by [String] key.
  bool? booleanValueOrNull(String key) => booleanOrNull(key)?.data;

  /// Get [JsonBoolean] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonBoolean boolean(String key) => _byKeyOfType<JsonBoolean>(key, false)!;

  /// Get [JsonBoolean] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonBoolean? booleanOrNull(String key) =>
      _byKeyOfType<JsonBoolean>(key, true);

  /// Get Map<String,R> by [String] key.
  ///
  /// Throws [SquintException] if key is not found
  /// or values are not all of type [R].
  Map<String, R> mapValue<R>(String key) => object(key).rawData();

  /// Get Map<String,R> by [String] key.
  ///
  /// Throws [SquintException] if key is not found
  /// or values are not all of type [R].
  Map<String, R>? mapValueOrNull<R>(String key) => objectOrNull(key)?.rawData();

  /// Get [JsonObject] by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonObject object(String key) => objectOrNull(key)!;

  /// Get [JsonObject] or null by [String] key.
  ///
  /// Throws [SquintException] if key is not found.
  JsonObject? objectOrNull(String key) {
    final object = _byKeyOfType<JsonNode<Map<String,JsonNode>>>(key, true);

    if(object == null) {
      return null;
    }

    return JsonObject(object.data, object.key);
  }

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
  /// where R is not of type JsonNode but a dart StandardType (String, bool, etc).
  Map<String, R> rawData<R>() => data.map((key, value) {
    return MapEntry(key, value.data as R);
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

/// A JsonObject which children are all of the same type.
///
/// When all children are of the same type then
/// a JSON node can be deserialized as Map with
/// strongly typed children. This is mostly useful
/// when a Map is nested inside one or more Lists.
class JsonMap<T> extends JsonNode<Map<String,JsonNode<T>>> {
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
  Map<String, T> get rawData => data.map((key, value) {
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
    return MapEntry(key, JsonObject.fromMap(value as Map<String, dynamic>));
  }

  throw SquintException(
    "Unable to convert Map<String, dynamic> to Map<String,JsonNode>",
  );
}

///
class CustomJsonNode extends JsonNode<dynamic> {
  ///
  CustomJsonNode({required super.data}):super(key: "");
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
