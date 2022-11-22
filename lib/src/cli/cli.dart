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

import "../../squint.dart";
import "../analyzer/analyzer.dart" as analyzer;
import "../ast/ast.dart";
import "../common/common.dart";

///
void analyzeFile(
    {required String pathToFile, required String pathToOutputFolder}) {
  if (!File(pathToFile).existsSync()) {
    throw SquintException("File does not exist: $pathToFile");
  }

  if (!Directory(pathToOutputFolder).existsSync()) {
    throw SquintException("Output folder does not exist: $pathToOutputFolder");
  }

  analyzer.analyze(pathToFile).whereType<CustomType>().forEach((type) {
    pathToOutputFolder
        .resolve("${type.className.toLowerCase()}.txt")
        .writeAsStringSync("${type.className}\n${type.members}");
  });
}

extension on String {
  File resolve(String filename) =>
      File("${this}${Platform.pathSeparator}$filename");
}
