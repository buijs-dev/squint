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

import "dart:io";

import "../common/common.dart";
import "const.dart";
import "generate_arguments.dart";

/// Either containing a File or a List of String log messages.
typedef Result = Either<File, List<String>>;

/// Helper to parse the argument '--input'.
///
/// {@category generator}
extension Input on Map<GenerateArgs, dynamic> {
  /// Return the [File] path value of --input if present and if File exists.
  Result get inputFile {
    if (!containsKey(GenerateArgs.input)) {
      return Result.nok([
        "Missing argument '$generateArgumentInput'.",
        "Specify path to input file with --$generateArgumentInput.",
        "Example to generate dataclass from JSON file: ",
        "flutter pub run $libName:$generateTaskName --$generateArgumentType dataclass --$generateArgumentInput message.json",
        "Example to generate serializer extensions for dart class: ",
        "flutter pub run $libName:$generateTaskName --$generateArgumentType serializer --$generateArgumentInput foo.dart",
      ]);
    }

    /// Absolute or relative path retrieved from the arguments.
    final pathToInputFile = this[GenerateArgs.input] as String;

    /// Create a File instance of the given path and verify it exists.
    final inputFile = File(pathToInputFile);

    if (!inputFile.existsSync()) {
      /// Return NOK result because the File does not exist.
      return Result.nok(["File does not exist: ${inputFile.absolute.path}"]);
    }

    /// Return OK because File is present.
    return Result.ok(inputFile);
  }
}
