//
//  WorkflowExecutor.swift
//  ScriptHub
//
//  Executes workflows by running scripts in sequence and passing data between them
//

import Foundation

class WorkflowExecutor {

    static func executeWorkflow(
        _ workflow: Workflow,
        scripts: [Script],
        projectRoot: String,
        runner: WorkflowRunner
    ) {
        runner.reset()
        runner.isRunning = true

        DispatchQueue.global(qos: .userInitiated).async {
            // Build execution order using topological sort
            guard let executionOrder = topologicalSort(workflow: workflow) else {
                DispatchQueue.main.async {
                    runner.error = "❌ 工作流包含循环依赖，无法执行"
                    runner.isRunning = false
                }
                return
            }

            var output = "🚀 开始执行工作流: \(workflow.name)\n"
            output += "执行顺序: \(executionOrder.count) 个节点\n\n"

            DispatchQueue.main.async {
                runner.overallOutput = output
            }

            // Execute nodes in order
            for nodeId in executionOrder {
                guard let node = workflow.nodes.first(where: { $0.id == nodeId }),
                      let script = scripts.first(where: { $0.id == node.scriptId }) else {
                    continue
                }

                DispatchQueue.main.async {
                    runner.currentNodeId = nodeId
                }

                output += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
                output += "▶️  执行: \(script.name)\n"
                output += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

                DispatchQueue.main.async {
                    runner.overallOutput = output
                }

                // Resolve parameters
                let resolvedParams = resolveParameters(
                    node: node,
                    script: script,
                    nodeOutputs: runner.nodeOutputs
                )

                // Execute script
                let result = executeScriptNode(
                    script: script,
                    parameters: resolvedParams,
                    projectRoot: projectRoot
                )

                // Store output
                let nodeOutput = WorkflowRunner.NodeOutput(
                    stdout: result.stdout,
                    stderr: result.stderr,
                    exitCode: result.exitCode,
                    workingDirectory: result.workingDirectory
                )

                DispatchQueue.main.async {
                    runner.nodeOutputs[nodeId] = nodeOutput
                }

                // Append to overall output
                if !result.stdout.isEmpty {
                    output += result.stdout + "\n"
                }

                if !result.stderr.isEmpty {
                    output += "⚠️ 错误输出:\n" + result.stderr + "\n"
                }

                if result.exitCode != 0 {
                    output += "\n❌ 节点执行失败 (退出码: \(result.exitCode))\n"
                    output += "⏸️  工作流已停止\n"

                    DispatchQueue.main.async {
                        runner.overallOutput = output
                        runner.error = "节点 \(script.name) 执行失败"
                        runner.isRunning = false
                    }
                    return
                }

                output += "✅ 节点执行成功\n\n"

                DispatchQueue.main.async {
                    runner.overallOutput = output
                }
            }

            output += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            output += "🎉 工作流执行完成！\n"
            output += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

            DispatchQueue.main.async {
                runner.overallOutput = output
                runner.currentNodeId = nil
                runner.isRunning = false
            }
        }
    }

    // MARK: - Parameter Resolution

    private static func resolveParameters(
        node: WorkflowNode,
        script: Script,
        nodeOutputs: [String: WorkflowRunner.NodeOutput]
    ) -> [ParameterValue] {
        var resolvedParams: [ParameterValue] = []

        for param in script.parameters {
            var value = param.defaultValue ?? ""

            // Check if there's a mapping for this parameter
            if let mapping = node.parameterMappings[param.name] {
                switch mapping {
                case .constant(let constantValue):
                    value = constantValue

                case .output(let nodeId, let outputType):
                    if let nodeOutput = nodeOutputs[nodeId] {
                        value = getOutputValue(from: nodeOutput, type: outputType)
                    }

                case .userInput:
                    // For now, use default value
                    // In a real implementation, this would prompt the user
                    value = param.defaultValue ?? ""
                }
            }

            let paramValue = ParameterValue(parameter: param)
            var mutableParamValue = paramValue
            mutableParamValue.value = value
            resolvedParams.append(mutableParamValue)
        }

        return resolvedParams
    }

    private static func getOutputValue(
        from nodeOutput: WorkflowRunner.NodeOutput,
        type: ParameterMapping.OutputType
    ) -> String {
        switch type {
        case .stdout:
            return nodeOutput.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        case .stderr:
            return nodeOutput.stderr.trimmingCharacters(in: .whitespacesAndNewlines)
        case .exitCode:
            return String(nodeOutput.exitCode)
        case .workingDirectory:
            return nodeOutput.workingDirectory
        }
    }

    // MARK: - Script Execution

    private static func executeScriptNode(
        script: Script,
        parameters: [ParameterValue],
        projectRoot: String
    ) -> (stdout: String, stderr: String, exitCode: Int32, workingDirectory: String) {
        let semaphore = DispatchSemaphore(value: 0)

        var stdout = ""
        var stderr = ""
        var exitCode: Int32 = 0
        let workingDirectory = FileManager.default.currentDirectoryPath

        // Use appropriate executor based on script type
        switch script.type {
        case "java":
            executeJavaScriptSync(
                script: script,
                parameters: parameters,
                projectRoot: projectRoot
            ) { result in
                stdout = result.stdout
                stderr = result.stderr
                exitCode = result.exitCode
                semaphore.signal()
            }

        case "python":
            executePythonScriptSync(
                script: script,
                parameters: parameters
            ) { result in
                stdout = result.stdout
                stderr = result.stderr
                exitCode = result.exitCode
                semaphore.signal()
            }

        case "shell":
            executeShellScriptSync(
                script: script,
                parameters: parameters
            ) { result in
                stdout = result.stdout
                stderr = result.stderr
                exitCode = result.exitCode
                semaphore.signal()
            }

        default:
            stderr = "不支持的脚本类型: \(script.type)"
            exitCode = -1
            semaphore.signal()
        }

        semaphore.wait()

        return (stdout, stderr, exitCode, workingDirectory)
    }

    private static func executeJavaScriptSync(
        script: Script,
        parameters: [ParameterValue],
        projectRoot: String,
        completion: @escaping (stdout: String, stderr: String, exitCode: Int32) -> Void
    ) {
        let args = parameters.map { formatParameterValue($0) }
        let classPath = projectRoot + "/out/production/Scripts"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/java")
        process.arguments = ["-cp", classPath, script.className] + args

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()

            let outputData = try outputPipe.fileHandleForReading.readToEnd() ?? Data()
            let errorData = try errorPipe.fileHandleForReading.readToEnd() ?? Data()

            let stdout = String(data: outputData, encoding: .utf8) ?? ""
            let stderr = String(data: errorData, encoding: .utf8) ?? ""

            completion(stdout, stderr, process.terminationStatus)
        } catch {
            completion("", "执行失败: \(error.localizedDescription)", -1)
        }
    }

    private static func executePythonScriptSync(
        script: Script,
        parameters: [ParameterValue],
        completion: @escaping (stdout: String, stderr: String, exitCode: Int32) -> Void
    ) {
        let args = parameters.map { $0.value }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = [script.scriptPath] + args

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()

            let outputData = try outputPipe.fileHandleForReading.readToEnd() ?? Data()
            let errorData = try errorPipe.fileHandleForReading.readToEnd() ?? Data()

            let stdout = String(data: outputData, encoding: .utf8) ?? ""
            let stderr = String(data: errorData, encoding: .utf8) ?? ""

            completion(stdout, stderr, process.terminationStatus)
        } catch {
            completion("", "执行失败: \(error.localizedDescription)", -1)
        }
    }

    private static func executeShellScriptSync(
        script: Script,
        parameters: [ParameterValue],
        completion: @escaping (stdout: String, stderr: String, exitCode: Int32) -> Void
    ) {
        let args = parameters.map { $0.value }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [script.scriptPath] + args

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()

            let outputData = try outputPipe.fileHandleForReading.readToEnd() ?? Data()
            let errorData = try errorPipe.fileHandleForReading.readToEnd() ?? Data()

            let stdout = String(data: outputData, encoding: .utf8) ?? ""
            let stderr = String(data: errorData, encoding: .utf8) ?? ""

            completion(stdout, stderr, process.terminationStatus)
        } catch {
            completion("", "执行失败: \(error.localizedDescription)", -1)
        }
    }

    private static func formatParameterValue(_ paramValue: ParameterValue) -> String {
        let value = paramValue.value.trimmingCharacters(in: .whitespaces)

        if ["directory", "file"].contains(paramValue.parameter.type) && value.contains(" ") {
            return "\"\(value)\""
        }

        return value
    }

    // MARK: - Topological Sort

    private static func topologicalSort(workflow: Workflow) -> [String]? {
        var inDegree: [String: Int] = [:]
        var adjacencyList: [String: [String]] = [:]

        // Initialize
        for node in workflow.nodes {
            inDegree[node.id] = 0
            adjacencyList[node.id] = []
        }

        // Build graph
        for connection in workflow.connections {
            adjacencyList[connection.fromNodeId]?.append(connection.toNodeId)
            inDegree[connection.toNodeId, default: 0] += 1
        }

        // Find nodes with no dependencies
        var queue: [String] = []
        for (nodeId, degree) in inDegree {
            if degree == 0 {
                queue.append(nodeId)
            }
        }

        var result: [String] = []

        while !queue.isEmpty {
            let current = queue.removeFirst()
            result.append(current)

            for neighbor in adjacencyList[current] ?? [] {
                inDegree[neighbor, default: 0] -= 1
                if inDegree[neighbor] == 0 {
                    queue.append(neighbor)
                }
            }
        }

        // Check for cycles
        if result.count != workflow.nodes.count {
            return nil
        }

        return result
    }
}
