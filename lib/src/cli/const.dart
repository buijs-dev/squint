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

import "generate_arguments.dart";

/// Library name.
const libName = "squintjson";

/// Name of CLI Task generate.
const generateTaskName = "generate";

/// (Required) CLI Task generate argument to specify type.
final generateArgumentType = GenerateArgs.type.name;

/// Possible value of CLI Task generate [generateArgumentType] to generate a dataclass.
const generateArgumentTypeValueDataclass = "dataclass";

/// Possible value of CLI Task generate [generateArgumentType] to generate serializer extensions.
const generateArgumentTypeValueSerializer = "serializer";

/// (Required) CLI Task generate argument to specify input file.
final generateArgumentInput = GenerateArgs.input.name;

/// (Optional) CLI Task generate argument to specify output folder.
final generateArgumentOutput = GenerateArgs.output.name;

/// (Optional) CLI Task generate argument to specify if existing files may be overwritten.
final generateArgumentOverwrite = GenerateArgs.overwrite.name;

/// (Optional) CLI Task generate argument to configure data class code generation output.
const generateArgumentAlwaysAddJsonValue = "alwaysAddJsonValue";

/// (Optional) CLI Task generate argument to configure data class code generation output.
const generateArgumentBlankLineBetweenFields = "blankLineBetweenFields";

/// (Optional) CLI Task generate argument to configure data class code generation output.
const generateArgumentIncludeJsonAnnotations = "includeJsonAnnotations";
