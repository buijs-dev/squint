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

import "../analyzer/analyzer.dart" as analyzer;
import "../ast/ast.dart";
import "../common/common.dart";
import "../converters/converters.dart";
import "../decoder/decoder.dart";
import "../generator/generator.dart";
import "shared.dart";

/// Run the analyzer task.
List<AbstractType> runGenerateTask(List<String> args) {
  final arguments = args.generateArguments;

  if(!arguments.containsKey(GenerateArgs.type)) {
      "Missing argument 'type'.".log();
      "Specify what code to be generated with --type.".log();
      "Example to generate dataclass from JSON file: ".log(
        context: "flutter pub run squint:generate --type dataclass --input message.json",
      );
      "Example to generate serializer extensions for dart class: ".log(
        context: "flutter pub run squint:generate --type serializer --input foo.dart",
      );
      return [];
  }

  final toBeGenerated = arguments[GenerateArgs.type] as String;

  if(toBeGenerated == "dataclass") {
    return arguments.dataclass;
  }

  if(toBeGenerated == "serializer") {
    return arguments.serializer;
  }

  "Invalid value for argument --type: '$toBeGenerated'".log();
  "Possible values are:".log();
  "- dataclass (generate dataclass from JSON)".log();
  "- serializer (generate serializer extensions for dart class)".log();
  return [];

}

extension on Map<GenerateArgs,dynamic> {
  List<AbstractType> get dataclass {

    final file = inputFile;

    if(file == null) {
      return [];
    }

    if(!file.path.toLowerCase().endsWith(".json")) {
      "File is not a .json file: ${file.absolute.path}".log();
      return [];
    }

    final json = file.readAsStringSync();
    final object = json.jsonDecode;
    final className = file.toClassName;
    final customType = object.toCustomType(className: className);

     final dataclass = file.parent.resolve("${className.toLowerCase()}_dataclass.dart");
     if (dataclass.existsSync()) {
        final allowedToOverwrite = this[GenerateArgs.overwrite] as bool?;
        if(! (allowedToOverwrite??false))  {
          "Failed to write generated code because File already exists: ${dataclass.absolute.path}".log();
          "Use '--overwrite true' to allow overwriting existing files".log();
          return [];
        }
     }

     dataclass.writeAsStringSync(customType.generateDataClassFile(
       options: standardSquintGeneratorOptions.copyWith(
         includeJsonAnnotations: this[GenerateArgs.includeJsonAnnotations] as bool,
         alwaysAddJsonValue: this[GenerateArgs.alwaysAddJsonValue] as bool,
         blankLineBetweenFields: this[GenerateArgs.blankLineBetweenFields] as bool
       )
     ));
     return [];
  }

  List<AbstractType> get serializer {
    final file = inputFile;

    if(file == null) {
      return [];
    }

    if(!file.path.toLowerCase().endsWith(".dart")) {
      "File is not a .dart file: ${file.absolute.path}".log();
      return [];
    }

    final result = analyzer.analyze(pathToFile: file.absolute.path).whereType<CustomType>();

    for (final e in result) {
          final extensions =
            file.parent.resolve("${e.className.snakeCase}_extensions.dart");

          final allowedToOverwrite = this[GenerateArgs.overwrite] as bool?;
          if(extensions.existsSync() && !(allowedToOverwrite??false))  {
            "Failed to write generated code because File already exists: ${extensions.absolute.path}".log();
            "Use '--overwrite true' to allow overwriting existing files".log();
          } else {
            extensions.writeAsString(e.generateJsonDecodingFile(
                relativeImport: file.path.substring(
                    file.path.lastIndexOf(Platform.pathSeparator) + 1)));
          }
      }

    return result.toList();
  }

  File? get inputFile {
    if(!containsKey(GenerateArgs.input)) {
      "Missing argument 'input'.".log();
      "Specify path to input file with --input.".log();
      "Example to generate dataclass from JSON file: ".log(
        context: "flutter pub run squint:generate --type dataclass --input message.json",
      );
      "Example to generate serializer extensions for dart class: ".log(
        context: "flutter pub run squint:generate --type serializer --input foo.dart",
      );
      return null;
    }

    final pathToInputFile = this[GenerateArgs.input] as String;
    final inputFile = File(pathToInputFile);
    if (!inputFile.existsSync()) {
      "File does not exist: ${inputFile.absolute.path}".log();
      return null;
    }
    return inputFile;
  }
}

/// Command-line arguments utilties.
extension ArgumentSplitter on List<String> {
  /// Return Map containing [GenerateArgs] and their value (if any).
  Map<GenerateArgs, dynamic> get generateArguments {

    final arguments = <GenerateArgs, dynamic>{
      // Optional argument so set to false as default.
      GenerateArgs.overwrite: false,
      GenerateArgs.blankLineBetweenFields: standardSquintGeneratorOptions.blankLineBetweenFields,
      GenerateArgs.alwaysAddJsonValue: standardSquintGeneratorOptions.alwaysAddJsonValue,
      GenerateArgs.includeJsonAnnotations: standardSquintGeneratorOptions.includeJsonAnnotations,
    };

    var index = 0;

    for (final value in this) {
      index +=1;
      if(value.startsWith("--")) {
        if(length < index) {
          _logGeneratorExamples();
          throw SquintException("No value given for parameter: '$value'");
        }

        final lowercased = value
            .substring(2, value.length)
            .toLowerCase();

        switch(lowercased) {
          case "type":
            arguments[GenerateArgs.type] = this[index];
            break;
          case "input":
            arguments[GenerateArgs.input] = this[index];
            break;
          case "output":
            arguments[GenerateArgs.output] = this[index];
            break;
          case "overwrite":
            arguments[GenerateArgs.overwrite] = _boolOrThrow(index);
            break;
          case "blanklinebetweenfields":
            arguments[GenerateArgs.blankLineBetweenFields]  = _boolOrThrow(index);
            break;
          case "alwaysaddjsonvalue":
            arguments[GenerateArgs.alwaysAddJsonValue] = _boolOrThrow(index);
            break;
          case "includejsonannotations":
            arguments[GenerateArgs.includeJsonAnnotations] = _boolOrThrow(index);
            break;
          default:
            _logGeneratorExamples();
            throw SquintException("Invalid parameter: '$value'");
        }
      }
    }

    return arguments;
  }

  bool _boolOrThrow(int index) {
    final boolOrNull = this[index].asBoolOrNull;
    if(boolOrNull == null) {
      _logGeneratorExamples();
      throw SquintException("Expected a bool value but found: '${this[index]}'");
    }
   return boolOrNull;
  }

}

/// Arguments for the generate command-line task.
enum GenerateArgs {

  /// What type of code to be generated.
  type,

  /// Input file to be analyzed.
  input,

  /// Output folder where to store the result.
  output,

  /// Indicator if existing analysis results may be overwritten.
  overwrite,

  /// Configure to add a blank line between dataclass fields or not.
  blankLineBetweenFields,

  /// Configure to always add @JsonValue to dataclass fields or not.
  alwaysAddJsonValue,

  /// Configure to include annotations or not.
  includeJsonAnnotations,
}

extension on File {
  String get toClassName {
    final filename = path.replaceAll(parent.path, "");
    final name = filename.substring(1, filename.lastIndexOf("."));
    return name.camelCase();
  }
}

void _logGeneratorExamples() {
  "Task 'generate' requires 2 parameters.".log();
  "Specify what to be generated with --type (possible values: dataclass or serializer).".log();
  "Specify input file with --input.".log();
  "Optional parameters are".log();
  "--output (folder to write generated code which defaults to current folder)".log(
    context: "Example: flutter pub run squint:generate --type dataclass --input foo/bar/message.json --output foo/bar/gen"
  );
  "For dataclass only:".log();
  "--alwaysAddJsonValue (include @JsonValue annotation on all fields)".log(
      context: "Example: flutter pub run squint:generate --type dataclass --input foo/bar/message.json --alwaysAddJsonValue true"
  );
  "--includeJsonAnnotations (add annotations or not)".log(
      context: "Example: flutter pub run squint:generate --type dataclass --input foo/bar/message.json --includeJsonAnnotations false"
  );
  "--blankLineBetweenFields (add blank line between dataclass fields or not)".log(
      context: "Example: flutter pub run squint:generate --type dataclass --input foo/bar/message.json --blankLineBetweenFields true"
  );
  "".log();
}