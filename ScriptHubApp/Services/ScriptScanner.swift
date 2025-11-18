//
//  ScriptScanner.swift
//  ScriptHub
//
//  Automatically scans and analyzes script files to detect entry points and parameters
//

import Foundation

class ScriptScanner {

    // MARK: - Script Analysis

    static func analyzeScript(at path: String) -> Script? {
        let fileExtension = (path as NSString).pathExtension.lowercased()

        switch fileExtension {
        case "java":
            return analyzeJavaScript(at: path)
        case "py":
            return analyzePythonScript(at: path)
        case "sh", "bash":
            return analyzeShellScript(at: path)
        default:
            return nil
        }
    }

    // MARK: - Java Script Analysis

    private static func analyzeJavaScript(at path: String) -> Script? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }

        // Extract class name
        let classPattern = #"public\s+class\s+(\w+)"#
        guard let className = extractPattern(classPattern, from: content) else {
            return nil
        }

        // Check for main method
        if !content.contains("public static void main(String") {
            return nil
        }

        // Extract parameters from main method comments or usage
        let parameters = extractJavaParameters(from: content)

        // Try to extract description from comments
        let description = extractJavaDescription(from: content) ?? "Java 脚本"

        let fileName = (path as NSString).lastPathComponent
        let scriptId = UUID().uuidString

        return Script(
            id: scriptId,
            name: className,
            description: description,
            type: "java",
            scriptPath: path,
            className: className,
            icon: "doc.text.fill",
            parameters: parameters,
            warnings: nil
        )
    }

    private static func extractJavaParameters(from content: String) -> [Parameter] {
        var parameters: [Parameter] = []

        // Look for args usage patterns: args[0], args[1], etc.
        let argsPattern = #"args\[(\d+)\]"#
        let regex = try? NSRegularExpression(pattern: argsPattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []

        let maxIndex = matches.compactMap { match -> Int? in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return Int(content[range])
        }.max() ?? -1

        // Look for usage comments or patterns
        let lines = content.components(separatedBy: .newlines)
        var paramDescriptions: [String] = []

        for line in lines {
            if line.contains("Usage:") || line.contains("usage:") || line.contains("*") {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("//") || trimmed.hasPrefix("*") {
                    paramDescriptions.append(trimmed)
                }
            }
        }

        // Create parameters based on detected args
        for i in 0...maxIndex {
            var label = "参数 \(i + 1)"
            var description = "命令行参数 \(i)"
            var type = "text"
            var defaultValue: String? = nil

            // Try to infer type and description from context
            let contextPattern = #"args\[\#(i)\][^\n]{0,100}"#
            if let contextMatch = try? NSRegularExpression(pattern: contextPattern)
                .firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
               let range = Range(contextMatch.range, in: content) {
                let context = String(content[range]).lowercased()

                if context.contains("int") || context.contains("size") || context.contains("count") {
                    type = "integer"
                    defaultValue = "100"
                }
                else if context.contains("bool") || context.contains("true") || context.contains("false") {
                    type = "boolean"
                    defaultValue = "true"
                }
                else if context.contains("dir") || context.contains("path") && context.contains("folder") {
                    type = "directory"
                }
                else if context.contains("file") && !context.contains("folder") {
                    type = "file"
                }
            }

            // Try to get better label from comments
            if i < paramDescriptions.count {
                let desc = paramDescriptions[i]
                if let colonIndex = desc.firstIndex(of: ":") {
                    let afterColon = desc[desc.index(after: colonIndex)...].trimmingCharacters(in: .whitespaces)
                    if !afterColon.isEmpty {
                        description = String(afterColon)
                    }
                }
            }

            parameters.append(Parameter(
                name: "arg_\(i)",
                label: label,
                type: type,
                required: true,
                defaultValue: defaultValue,
                description: description,
                options: nil
            ))
        }

        return parameters
    }

    private static func extractJavaDescription(from content: String) -> String? {
        // Look for class-level JavaDoc or comments
        let patterns = [
            #"/\*\*\s*\n\s*\*\s*(.+?)\n"#,  // JavaDoc first line
            #"//\s*(.+?)\n\s*public\s+class"#  // Single line comment before class
        ]

        for pattern in patterns {
            if let desc = extractPattern(pattern, from: content) {
                return desc.trimmingCharacters(in: .whitespaces)
            }
        }

        return nil
    }

    // MARK: - Python Script Analysis

    private static func analyzePythonScript(at path: String) -> Script? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }

        let fileName = (path as NSString).lastPathComponent
        let scriptName = (fileName as NSString).deletingPathExtension

        // Extract description from docstring or comments
        var description = "Python 脚本"
        if let docstring = extractPythonDocstring(from: content) {
            description = docstring
        }

        // Extract parameters from argparse or sys.argv
        let parameters = extractPythonParameters(from: content)

        return Script(
            id: UUID().uuidString,
            name: scriptName,
            description: description,
            type: "python",
            scriptPath: path,
            className: scriptName,
            icon: "doc.text.fill",
            parameters: parameters,
            warnings: nil
        )
    }

    private static func extractPythonDocstring(from content: String) -> String? {
        let patterns = [
            #"\"\"\"(.+?)\"\"\""#,  // Triple double quotes
            #"'''(.+?)'''"#,  // Triple single quotes
            #"#\s*(.+?)\n"#  // First comment line
        ]

        for pattern in patterns {
            if let match = extractPattern(pattern, from: content) {
                return match.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        return nil
    }

    private static func extractPythonParameters(from content: String) -> [Parameter] {
        var parameters: [Parameter] = []

        // Check for argparse usage
        if content.contains("argparse") {
            parameters = extractArgparseParameters(from: content)
        }
        // Check for sys.argv usage
        else if content.contains("sys.argv") {
            parameters = extractSysArgvParameters(from: content)
        }

        return parameters
    }

    private static func extractArgparseParameters(from content: String) -> [Parameter] {
        var parameters: [Parameter] = []

        // Match add_argument patterns
        let pattern = #"add_argument\(['"](--?[\w-]+)['"][^)]*\)"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []

        for match in matches {
            guard let range = Range(match.range(at: 1), in: content) else { continue }
            let argName = String(content[range]).replacingOccurrences(of: "-", with: "_")

            // Get the full add_argument line for context
            guard let fullRange = Range(match.range, in: content) else { continue }
            let argLine = String(content[fullRange])

            var type = "text"
            var defaultValue: String? = nil
            var description = argName
            var required = true

            // Detect type
            if argLine.contains("type=int") {
                type = "integer"
            } else if argLine.contains("action='store_true'") || argLine.contains("action='store_false'") {
                type = "boolean"
                defaultValue = "false"
                required = false
            }

            // Extract help text
            if let helpMatch = argLine.range(of: #"help=['"](.*?)['"]"#, options: .regularExpression) {
                description = String(argLine[helpMatch]).replacingOccurrences(of: #"help=['"]"#, with: "").replacingOccurrences(of: #"['"]"#, with: "")
            }

            // Extract default
            if let defaultMatch = argLine.range(of: #"default=['"](.*?)['"]"#, options: .regularExpression) {
                defaultValue = String(argLine[defaultMatch]).replacingOccurrences(of: #"default=['"]"#, with: "").replacingOccurrences(of: #"['"]"#, with: "")
                required = false
            }

            parameters.append(Parameter(
                name: argName,
                label: argName.replacingOccurrences(of: "_", with: " ").capitalized,
                type: type,
                required: required,
                defaultValue: defaultValue,
                description: description,
                options: nil
            ))
        }

        return parameters
    }

    private static func extractSysArgvParameters(from content: String) -> [Parameter] {
        var parameters: [Parameter] = []

        // Look for sys.argv[n] patterns
        let pattern = #"sys\.argv\[(\d+)\]"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []

        let maxIndex = matches.compactMap { match -> Int? in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return Int(content[range])
        }.max() ?? 0

        // sys.argv[0] is script name, so start from 1
        for i in 1...maxIndex {
            parameters.append(Parameter(
                name: "arg_\(i)",
                label: "参数 \(i)",
                type: "text",
                required: true,
                defaultValue: nil,
                description: "命令行参数 \(i)",
                options: nil
            ))
        }

        return parameters
    }

    // MARK: - Shell Script Analysis

    private static func analyzeShellScript(at path: String) -> Script? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }

        let fileName = (path as NSString).lastPathComponent
        let scriptName = (fileName as NSString).deletingPathExtension

        // Extract description from comments
        var description = "Shell 脚本"
        if let firstComment = content.components(separatedBy: .newlines)
            .first(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("#") && !$0.contains("#!/") }) {
            description = firstComment.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespaces)
        }

        // Detect parameters from $1, $2, etc.
        let parameters = extractShellParameters(from: content)

        return Script(
            id: UUID().uuidString,
            name: scriptName,
            description: description,
            type: "shell",
            scriptPath: path,
            className: scriptName,
            icon: "terminal.fill",
            parameters: parameters,
            warnings: nil
        )
    }

    private static func extractShellParameters(from content: String) -> [Parameter] {
        var parameters: [Parameter] = []

        // Look for $1, $2, etc. patterns
        let pattern = #"\$(\d+)"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []

        let maxIndex = matches.compactMap { match -> Int? in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return Int(content[range])
        }.max() ?? 0

        for i in 1...maxIndex {
            parameters.append(Parameter(
                name: "arg_\(i)",
                label: "参数 \(i)",
                type: "text",
                required: true,
                defaultValue: nil,
                description: "命令行参数 \(i)",
                options: nil
            ))
        }

        return parameters
    }

    // MARK: - Helper Methods

    private static func extractPattern(_ pattern: String, from text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            return nil
        }

        guard let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }

        return String(text[range])
    }

    // MARK: - Directory Scanning

    static func scanDirectory(at path: String, recursive: Bool = true) -> [Script] {
        var scripts: [Script] = []
        let fileManager = FileManager.default

        guard let enumerator = fileManager.enumerator(atPath: path) else {
            return scripts
        }

        let scriptExtensions = ["java", "py", "sh", "bash"]

        for case let fileName as String in enumerator {
            let fullPath = (path as NSString).appendingPathComponent(fileName)

            // Skip if not recursive and file is in subdirectory
            if !recursive && fileName.contains("/") {
                continue
            }

            let ext = (fileName as NSString).pathExtension.lowercased()
            if scriptExtensions.contains(ext) {
                if let script = analyzeScript(at: fullPath) {
                    scripts.append(script)
                }
            }
        }

        return scripts
    }
}
