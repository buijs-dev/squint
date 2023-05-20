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
import "../common/common.dart";
import "../generator/generator.dart";
import "node2abstract.dart";

/// Convert a [JsonObject] String to a [CustomType].
extension Json2CustomType on JsonObject {
  /// Convert a [JsonObject] to a [CustomType].
  CustomType toCustomType({
    required String className,
  }) {
    final customType = CustomType(
      className: className,
      members: data.toTypeMembers,
    ).normalizeMemberNames;

    return customType.withDataClassMetadata;
  }
}

extension on CustomType {
  CustomType get normalizeMemberNames => CustomType(
      className: className,
      members: members.map((TypeMember typeMember) {
        return typeMember.normalizeNameAndJsonKey;
      }).toList());
}

extension on TypeMember {
  /// Normalize a JSON node key to be a valid TypeMember name in dart
  /// and store the original JSON node key for data encoding/decoding.
  ///
  /// A JSON node key might not be a valid dart TypeMember name.
  /// To be able to generate data classes and do JSON encoding/decoding,
  /// both the normalized name and original JSON node key need to stored.
  ///
  /// The JSON node key will be stored in the annotations list as [TypeAnnotation]
  /// named 'JsonValue' with key 'tag' and value the JSON node key.
  ///
  /// It will then be converted to lower camelcase and saved as [TypeMember] name.
  ///
  /// Return [TypeMember]:
  /// - [name] normalized name in lower camelcase
  /// - [type] [AbstractType]
  /// - [annotations] containing JsonValue [TypeAnnotation]
  /// and JSON node key if not identical to [name].
  TypeMember get normalizeNameAndJsonKey {
    final memberType =
        type is CustomType ? (type as CustomType).normalizeMemberNames : type;

    final memberName = name
        .replaceAll(" ", "_")
        .replaceAll("-", "_")
        .camelCase(capitalize: false);

    final memberAnnotations = maybeAddJsonValue(
      jsonKey: name,
      memberName: memberName,
    );

    return TypeMember(
      name: memberName,
      type: memberType,
      annotations: memberAnnotations,
    );
  }

  /// Add JsonValue [TypeAnnotation] with [jsonKey] to
  /// TypeAnnotations list if:
  /// - jsonKey != memberName
  /// - [annotations] does NOT contain a TypeAnnotation named JsonValue.
  ///
  /// Return List [TypeAnnotation].
  List<TypeAnnotation> maybeAddJsonValue({
    required String jsonKey,
    required String memberName,
  }) {
    // JSON node key and TypeMember name are identical
    // so there is no need to add a JsonValue TypeAnnotation.
    if (memberName == name) {
      return annotations;
    }

    // If there already is a JsonValue annotation
    // then do not overwrite it's value.
    final annotationsContainsJsonValue =
        annotations.map((annotation) => annotation.name).contains("JsonValue");

    if (annotationsContainsJsonValue) {
      return annotations;
    }

    // Return current annotations + JsonValue containing [jsonKey].
    return [
      TypeAnnotation(
        name: "JsonValue",
        data: <String, String>{"tag": name},
      ),
      ...annotations
    ];
  }
}

extension on Map<String, JsonNode> {
  List<TypeMember> get toTypeMembers {
    final typeMembers = reduce<TypeMember>(
      (key, value) => TypeMember(
        name: key,
        type: value.toAbstractType(key),
        annotations: value.annotations,
      ),
    );

    return typeMembers.map((t) {
      final types = typeMembers.map((e) => e.type);
      final custom = types.whereType<CustomType>();
      return TypeMember(
        name: t.name,
        type: t.type.maybeReplaceType(custom.toSet()),
        annotations: t.annotations,
      );
    }).toList();
  }
}

extension on AbstractType {
  /// Find all CustomTypes that have the same definition, apart from their name.
  ///
  /// If all members are identical, meaning their lists of TypeMembers are of
  /// same length and contain the exact same TypeMember instances,
  /// then forget this instance and return the [CustomType] of [customTypes] list.
  ///
  /// If multiple CustomTypes are defined that have the same definition,
  /// besides the classname, then it is pointless to generate
  /// multiple data classes for them. It is impossible, impractical, to
  /// find overlapping definitions during first pass, hence this second pass
  /// is required.
  AbstractType maybeReplaceType(Set<CustomType> customTypes) {
    if (this is CustomType) {
      return (this as CustomType).findMatch(customTypes) ?? this;
    }

    if (this is ListType) {
      return ListType((this as ListType).child.maybeReplaceType(customTypes));
    }

    if (this is NullableListType) {
      return NullableListType(
        (this as ListType).child.maybeReplaceType(customTypes),
      );
    }

    if (this is MapType) {
      return MapType(
        key: (this as MapType).key.maybeReplaceType(customTypes),
        value: (this as MapType).value.maybeReplaceType(customTypes),
      );
    }

    if (this is NullableMapType) {
      return NullableMapType(
        key: (this as MapType).key.maybeReplaceType(customTypes),
        value: (this as MapType).value.maybeReplaceType(customTypes),
      );
    }

    return this;
  }
}

extension on CustomType {
  /// Find a CustomType with the same definition as the current CustomType.
  ///
  /// If all members are identical, meaning their lists of TypeMembers are of
  /// same length and contain the exact same TypeMember instances,
  /// then return the [CustomType] of [customTypes] Set.
  ///
  /// Returns null if no match is found.
  CustomType? findMatch(Set<CustomType> customTypes) {
    final match = customTypes.firstWhere((CustomType ct) {
      if (ct.members.length != members.length) {
        return false;
      }

      for (final member in ct.members) {
        if (!members.contains(member)) {
          return false;
        }
      }

      return true;
    }, orElse: () => _notFound);

    return match == _notFound ? null : match;
  }
}

final _notFound = _CustomTypeNotFound();

/// Helper object to represent a match not found when
/// looking for duplicate CustomType definitions.
class _CustomTypeNotFound extends CustomType {
  _CustomTypeNotFound() : super(className: "", members: <TypeMember>[]);
}
