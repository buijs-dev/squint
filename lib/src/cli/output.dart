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
import "shared.dart";

/// Either containing a File or a List of String log messages.
typedef Result = Either<File, List<String>>;

Result _outputFolderDoesNotExist(Directory folder) => Result.nok([
      "The ouput folder specified with --$generateArgumentOutput does not exist: ${folder.path}"
    ]);

Result _fileAlreadyExists(File file) => Result.nok([
      "Failed to write generated code because File already exists: ${file.path}.",
      "Use '--$generateArgumentOverwrite true' to allow overwriting existing files.",
    ]);

/// Helper to parse the argument '--output' and --overwrite
/// and return a [File] instance to write generated code to.
///
/// {@category generator}
extension Output on Map<GenerateArgs, dynamic> {
  /// Return path to outputFolder + filename if output is present
  /// or default to current folder + filename.
  Result outputFile({
    required String filename,
    required Directory currentFolder,
  }) {
    final outputFileOrLog = _toOutputFileOrLog(
      filename: filename,
      currentFolder: currentFolder,
    );

    if (!outputFileOrLog.isOk) {
      return outputFileOrLog;
    }

    final outputFile = outputFileOrLog.ok!;

    if (outputFile.existsSync()) {
      if (!_mayOverwriteFile) {
        return _fileAlreadyExists(outputFile);
      } else {
        outputFile.deleteSync();
      }
    }

    return Result.ok(outputFile..createSync());
  }

  /// Return [Result] containing a [File] which parent exists
  /// or [Result] containing a [List] of [String] log output.
  Result _toOutputFileOrLog({
    required String filename,
    required Directory currentFolder,
  }) {
    final pathToOutputFolder = this[GenerateArgs.output] as String?;

    if (pathToOutputFolder == null) {
      return Result.ok(currentFolder.resolve(filename));
    }

    final outputFolder = Directory(pathToOutputFolder);

    if (!outputFolder.existsSync()) {
      return _outputFolderDoesNotExist(outputFolder);
    }

    return Result.ok(Directory(pathToOutputFolder).resolve(filename));
  }

  bool get _mayOverwriteFile =>
      dynamicToBoolOrNull(this[GenerateArgs.overwrite]) ?? false;
}
