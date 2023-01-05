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

// ignore_for_file: unnecessary_this

import '../../squint.dart';
import "../ast/ast.dart";
import "../common/common.dart";
import "../encoder/encoder.dart";

///
class JsonMapper {
  /// Construct a new [JsonMapper] instance.
  const JsonMapper({this.formatting = standardJsonFormatting});

  ///
  final JsonFormattingOptions formatting;

  ///
  String writeValueAsString(SquintJson object) {
    return object.toString();
  }
  //
  // T readValue<T>(String json, T type) {
  //   final object = json.jsonDecode;
  //
  // }

}

///
mixin SquintJson<T> {
  ///
  T readValue(String json);

  ///
  String writeValue(T t);
}
