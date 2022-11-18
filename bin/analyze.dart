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

// ignore_for_file: avoid_print

import "package:squint/src/cli/cli.dart" as cli;

/// Run tasks for a Consumer project.
Future<void> main(List<String> args) async {
  print("""
  ════════════════════════════════════════════
     KLUTTER (v0.0.1)                               
  ════════════════════════════════════════════
  """);

  if(args.length != 2) {
    print("Invalid arguments for command 'analyze'.");
    print("Specify file to scan and output folder to store scan result.");
    print("Example command: 'flutter pub run squint:analyze foo/some_class_file.dart foo/bar/output'");
    return;
  }

  final pathToFile = args[0];

  final pathToOutputFolder = args[1];

  cli.analyzeFile(
      pathToFile: pathToFile,
      pathToOutputFolder: pathToOutputFolder,
  );

}