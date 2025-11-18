//
//  ScriptExecutor.swift
//  ScriptHub
//
//  Handles script execution and output capture
//

import Foundation

class ScriptExecutor {
    static func executeJavaScript(
        script: Script,
        parameters: [ParameterValue],
        projectRoot: String,
        runner: ScriptRunner
    ) {
        runner.reset()
        runner.isRunning = true

        DispatchQueue.global(qos: .userInitiated).async {
            // Build command arguments
            let args = parameters.map { self.formatParameterValue($0) }

            // Construct Java command
            let classPath = projectRoot + "/out/production/Scripts"
            let srcPath = projectRoot + "/src"

            // Check if class file exists, otherwise compile first
            let classFilePath = "\(classPath)/\(script.className).class"
            let needsCompilation = !FileManager.default.fileExists(atPath: classFilePath)

            var output = ""
            var errorOutput = ""

            if needsCompilation {
                output += "📝 Compiling \(script.className)...\n\n"
                let compileResult = self.compileJavaClass(
                    className: script.className,
                    srcPath: srcPath,
                    outputPath: classPath
                )
                output += compileResult.output
                errorOutput += compileResult.error

                if compileResult.exitCode != 0 {
                    DispatchQueue.main.async {
                        runner.output = output
                        runner.error = errorOutput
                        runner.exitCode = compileResult.exitCode
                        runner.isRunning = false
                    }
                    return
                }
            }

            output += "🚀 Running \(script.name)...\n"
            output += "Command: java -cp \(classPath) \(script.className) \(args.joined(separator: " "))\n\n"

            // Execute Java command
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/java")
            process.arguments = ["-cp", classPath, script.className] + args

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            do {
                try process.run()

                // Read output in real-time
                let outputHandle = outputPipe.fileHandleForReading
                let errorHandle = errorPipe.fileHandleForReading

                var outputData = Data()
                var errorData = Data()

                while process.isRunning {
                    if let data = try? outputHandle.availableData, !data.isEmpty {
                        outputData.append(data)
                        if let str = String(data: data, encoding: .utf8) {
                            output += str
                            DispatchQueue.main.async {
                                runner.output = output
                            }
                        }
                    }

                    if let data = try? errorHandle.availableData, !data.isEmpty {
                        errorData.append(data)
                        if let str = String(data: data, encoding: .utf8) {
                            errorOutput += str
                            DispatchQueue.main.async {
                                runner.error = errorOutput
                            }
                        }
                    }

                    Thread.sleep(forTimeInterval: 0.1)
                }

                process.waitUntilExit()

                // Read any remaining output
                if let data = try? outputHandle.readToEnd(), !data.isEmpty {
                    if let str = String(data: data, encoding: .utf8) {
                        output += str
                    }
                }

                if let data = try? errorHandle.readToEnd(), !data.isEmpty {
                    if let str = String(data: data, encoding: .utf8) {
                        errorOutput += str
                    }
                }

                let exitCode = process.terminationStatus

                if exitCode == 0 {
                    output += "\n✅ Script completed successfully"
                } else {
                    output += "\n❌ Script failed with exit code: \(exitCode)"
                }

                DispatchQueue.main.async {
                    runner.output = output
                    runner.error = errorOutput
                    runner.exitCode = exitCode
                    runner.isRunning = false
                }

            } catch {
                let errorMsg = "❌ Failed to execute: \(error.localizedDescription)"
                DispatchQueue.main.async {
                    runner.output = output
                    runner.error = errorMsg
                    runner.exitCode = -1
                    runner.isRunning = false
                }
            }
        }
    }

    private static func compileJavaClass(
        className: String,
        srcPath: String,
        outputPath: String
    ) -> (output: String, error: String, exitCode: Int32) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/javac")
        process.arguments = ["-d", outputPath, "\(srcPath)/\(className).java"]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        var output = ""
        var errorOutput = ""

        do {
            try process.run()
            process.waitUntilExit()

            if let data = try? outputPipe.fileHandleForReading.readToEnd(),
               let str = String(data: data, encoding: .utf8) {
                output = str
            }

            if let data = try? errorPipe.fileHandleForReading.readToEnd(),
               let str = String(data: data, encoding: .utf8) {
                errorOutput = str
            }

            let exitCode = process.terminationStatus

            if exitCode == 0 {
                output += "✅ Compilation successful\n\n"
            } else {
                errorOutput += "❌ Compilation failed\n"
            }

            return (output, errorOutput, exitCode)

        } catch {
            return ("", "❌ Failed to compile: \(error.localizedDescription)", -1)
        }
    }

    private static func formatParameterValue(_ paramValue: ParameterValue) -> String {
        let value = paramValue.value.trimmingCharacters(in: .whitespaces)

        // If it's a path type and contains spaces, quote it
        if ["directory", "file"].contains(paramValue.parameter.type) && value.contains(" ") {
            return "\"\(value)\""
        }

        return value
    }
}
