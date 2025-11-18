//
//  ScriptDetailView.swift
//  ScriptHub
//
//  Detail view for configuring and running a script
//

import SwiftUI

struct ScriptDetailView: View {
    let script: Script

    @StateObject private var runner = ScriptRunner()
    @State private var parameterValues: [ParameterValue] = []
    @State private var showingOutput = false
    @State private var projectRoot = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ScriptHeader(script: script)

            Divider()

            // Main content
            HSplitView {
                // Parameters panel
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Warnings
                        if let warnings = script.warnings, !warnings.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(warnings, id: \.self) { warning in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                        Text(warning)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }

                        // Parameters
                        ForEach(parameterValues.indices, id: \.self) { index in
                            ParameterInputView(
                                parameterValue: $parameterValues[index],
                                projectRoot: projectRoot
                            )
                        }

                        // Run button
                        HStack {
                            Spacer()
                            Button(action: runScript) {
                                HStack {
                                    if runner.isRunning {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                            .frame(width: 16, height: 16)
                                    } else {
                                        Image(systemName: "play.fill")
                                    }
                                    Text(runner.isRunning ? "运行中..." : "运行脚本")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(runner.isRunning || !validateParameters())
                            .controlSize(.large)
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
                .frame(minWidth: 350)

                // Output panel
                VStack(alignment: .leading, spacing: 0) {
                    // Output header
                    HStack {
                        Image(systemName: "terminal")
                        Text("输出")
                            .font(.headline)
                        Spacer()
                        Button(action: { runner.reset() }) {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                        .help("清除输出")
                        .disabled(runner.isRunning)
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))

                    Divider()

                    // Output content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if !runner.output.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("标准输出")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(runner.output)
                                        .font(.system(.body, design: .monospaced))
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }

                            if !runner.error.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("错误输出")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    Text(runner.error)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.red)
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }

                            if runner.output.isEmpty && runner.error.isEmpty && !runner.isRunning {
                                VStack(spacing: 12) {
                                    Image(systemName: "text.alignleft")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("脚本输出将显示在这里")
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .padding()
                    }
                }
                .frame(minWidth: 400)
            }
        }
        .onAppear {
            initializeParameters()
            projectRoot = ConfigLoader.getProjectRoot()
        }
    }

    private func initializeParameters() {
        parameterValues = script.parameters.map { ParameterValue(parameter: $0) }
    }

    private func validateParameters() -> Bool {
        for pv in parameterValues {
            if pv.parameter.required && pv.value.trimmingCharacters(in: .whitespaces).isEmpty {
                return false
            }
        }
        return true
    }

    private func runScript() {
        ScriptExecutor.executeJavaScript(
            script: script,
            parameters: parameterValues,
            projectRoot: projectRoot,
            runner: runner
        )
    }
}

// MARK: - Script Header

struct ScriptHeader: View {
    let script: Script

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: script.icon)
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(script.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text(script.description)
                    .font(.body)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    Label(script.type.uppercased(), systemImage: "doc.fill")
                        .font(.caption)
                        .foregroundColor(.blue)

                    Label(script.scriptPath, systemImage: "folder.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }

            Spacer()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Parameter Input View

struct ParameterInputView: View {
    @Binding var parameterValue: ParameterValue
    let projectRoot: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            HStack {
                Text(parameterValue.parameter.label)
                    .fontWeight(.medium)
                if parameterValue.parameter.required {
                    Text("*")
                        .foregroundColor(.red)
                }
                Spacer()
            }

            // Input based on type
            switch parameterValue.parameter.type {
            case "directory", "file":
                PathInputView(
                    value: $parameterValue.value,
                    isDirectory: parameterValue.parameter.type == "directory",
                    projectRoot: projectRoot
                )

            case "boolean":
                Toggle("", isOn: Binding(
                    get: { parameterValue.value.lowercased() == "true" },
                    set: { parameterValue.value = $0 ? "true" : "false" }
                ))
                .toggleStyle(.switch)

            case "choice":
                if let options = parameterValue.parameter.options {
                    Picker("", selection: $parameterValue.value) {
                        ForEach(options, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }

            case "integer":
                TextField("", text: $parameterValue.value)
                    .textFieldStyle(.roundedBorder)
                    .onReceive(parameterValue.value.publisher.collect()) {
                        let filtered = String($0.filter { "0123456789".contains($0) })
                        if filtered != parameterValue.value {
                            parameterValue.value = filtered
                        }
                    }

            default:
                TextField("", text: $parameterValue.value)
                    .textFieldStyle(.roundedBorder)
            }

            // Description
            Text(parameterValue.parameter.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Path Input View

struct PathInputView: View {
    @Binding var value: String
    let isDirectory: Bool
    let projectRoot: String

    var body: some View {
        HStack {
            TextField("", text: $value)
                .textFieldStyle(.roundedBorder)

            Button(action: selectPath) {
                Image(systemName: isDirectory ? "folder" : "doc")
            }
            .help(isDirectory ? "选择目录" : "选择文件")
        }
    }

    private func selectPath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = !isDirectory
        panel.canChooseDirectories = isDirectory
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: projectRoot)

        if panel.runModal() == .OK {
            if let url = panel.url {
                value = url.path
            }
        }
    }
}

#Preview {
    ScriptDetailView(script: Script(
        id: "test",
        name: "Test Script",
        description: "A test script",
        type: "java",
        scriptPath: "src/Test.java",
        className: "Test",
        icon: "star.fill",
        parameters: [],
        warnings: nil
    ))
}
