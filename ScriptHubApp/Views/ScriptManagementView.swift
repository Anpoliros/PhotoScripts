//
//  ScriptManagementView.swift
//  ScriptHub
//
//  View for managing scripts - add, edit, delete, import
//

import SwiftUI

struct ScriptManagementView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showingImportSheet = false
    @State private var showingScanSheet = false
    @State private var searchText = ""
    @State private var selectedScript: Script?
    @State private var showingEditSheet = false

    var filteredScripts: [Script] {
        if searchText.isEmpty {
            return dataStore.scripts
        }
        return dataStore.scripts.filter { script in
            script.name.localizedCaseInsensitiveContains(searchText) ||
            script.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "hammer.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("脚本管理")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()

                // Action buttons
                Menu {
                    Button(action: { showingImportSheet = true }) {
                        Label("导入脚本文件", systemImage: "doc.badge.plus")
                    }

                    Button(action: { showingScanSheet = true }) {
                        Label("扫描目录", systemImage: "folder.badge.questionmark")
                    }

                    Divider()

                    Button(action: exportScripts) {
                        Label("导出配置", systemImage: "square.and.arrow.up")
                    }

                    Button(action: importConfiguration) {
                        Label("导入配置", systemImage: "square.and.arrow.down")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .menuStyle(.borderlessButton)
                .help("添加脚本")
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("搜索脚本...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .padding()

            // Scripts list
            if filteredScripts.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: searchText.isEmpty ? "tray" : "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text(searchText.isEmpty ? "还没有脚本" : "未找到匹配的脚本")
                        .font(.headline)
                    if searchText.isEmpty {
                        Text("点击 + 按钮导入或扫描脚本")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            } else {
                List(filteredScripts, selection: $selectedScript) { script in
                    ScriptManagementRow(script: script)
                        .contextMenu {
                            Button(action: { editScript(script) }) {
                                Label("编辑", systemImage: "pencil")
                            }
                            Button(action: { duplicateScript(script) }) {
                                Label("复制", systemImage: "doc.on.doc")
                            }
                            Divider()
                            Button(role: .destructive, action: { deleteScript(script) }) {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
                .listStyle(.inset)
            }

            // Footer
            HStack {
                Text("\(dataStore.scripts.count) 个脚本")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if let selected = selectedScript {
                    HStack(spacing: 8) {
                        Button("编辑") {
                            editScript(selected)
                        }
                        .buttonStyle(.borderedProminent)

                        Button("删除", role: .destructive) {
                            deleteScript(selected)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .sheet(isPresented: $showingImportSheet) {
            ImportScriptsSheet()
        }
        .sheet(isPresented: $showingScanSheet) {
            ScanDirectorySheet()
        }
        .sheet(isPresented: $showingEditSheet) {
            if let script = selectedScript {
                ScriptEditorSheet(script: script)
            }
        }
    }

    private func editScript(_ script: Script) {
        selectedScript = script
        showingEditSheet = true
    }

    private func duplicateScript(_ script: Script) {
        var duplicate = script
        duplicate.id = UUID().uuidString
        duplicate.name = script.name + " (副本)"
        dataStore.addScript(duplicate)
    }

    private func deleteScript(_ script: Script) {
        dataStore.deleteScript(script)
        if selectedScript?.id == script.id {
            selectedScript = nil
        }
    }

    private func exportScripts() {
        guard let json = dataStore.exportToJSON() else {
            return
        }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = "script_hub_export.json"
        panel.allowedContentTypes = [.json]

        if panel.runModal() == .OK, let url = panel.url {
            try? json.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    private func importConfiguration() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            if let json = try? String(contentsOf: url, encoding: .utf8) {
                _ = dataStore.importFromJSON(json)
            }
        }
    }
}

// MARK: - Script Management Row

struct ScriptManagementRow: View {
    let script: Script

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: script.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(script.name)
                    .font(.headline)

                Text(script.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label(script.type.uppercased(), systemImage: "doc.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)

                    Label("\(script.parameters.count) 参数", systemImage: "slider.horizontal.3")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // File path badge
            Text((script.scriptPath as NSString).lastPathComponent)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Import Scripts Sheet

struct ImportScriptsSheet: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedFiles: [String] = []
    @State private var importedScripts: [Script] = []

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("导入脚本文件")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("取消") {
                    dismiss()
                }
            }

            if importedScripts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("选择要导入的脚本文件")
                        .font(.headline)

                    Text("支持 Java (.java), Python (.py), Shell (.sh) 脚本")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: selectFiles) {
                        Label("选择文件", systemImage: "folder")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("已识别 \(importedScripts.count) 个脚本")
                        .font(.headline)

                    List(importedScripts) { script in
                        HStack {
                            Image(systemName: script.icon)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(script.name)
                                    .font(.headline)
                                Text(script.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 300)

                    HStack {
                        Spacer()
                        Button("重新选择") {
                            importedScripts = []
                            selectedFiles = []
                        }
                        Button("导入") {
                            for script in importedScripts {
                                dataStore.addScript(script)
                            }
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .padding()
        .frame(width: 500, height: 450)
    }

    private func selectFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .init(filenameExtension: "java")!,
            .init(filenameExtension: "py")!,
            .init(filenameExtension: "sh")!
        ]

        if panel.runModal() == .OK {
            selectedFiles = panel.urls.map { $0.path }
            importedScripts = dataStore.importScripts(from: selectedFiles)
        }
    }
}

// MARK: - Scan Directory Sheet

struct ScanDirectorySheet: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedPath: String = ""
    @State private var recursive = true
    @State private var foundScripts: [Script] = []
    @State private var isScanning = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("扫描目录")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("取消") {
                    dismiss()
                }
            }

            if foundScripts.isEmpty && !isScanning {
                VStack(spacing: 16) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    Text("选择包含脚本的目录")
                        .font(.headline)

                    Toggle("递归扫描子目录", isOn: $recursive)

                    Button(action: selectDirectory) {
                        Label("选择目录", systemImage: "folder")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if isScanning {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("扫描中...")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("发现 \(foundScripts.count) 个脚本")
                        .font(.headline)

                    List(foundScripts) { script in
                        HStack {
                            Image(systemName: script.icon)
                                .foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(script.name)
                                    .font(.headline)
                                Text(script.scriptPath)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 300)

                    HStack {
                        Spacer()
                        Button("重新扫描") {
                            foundScripts = []
                            selectedPath = ""
                        }
                        Button("导入全部") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .padding()
        .frame(width: 500, height: 450)
    }

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            selectedPath = url.path
            scanDirectory(at: selectedPath)
        }
    }

    private func scanDirectory(at path: String) {
        isScanning = true
        DispatchQueue.global(qos: .userInitiated).async {
            let scripts = dataStore.scanDirectory(path, recursive: recursive)
            DispatchQueue.main.async {
                foundScripts = scripts
                isScanning = false
            }
        }
    }
}

// MARK: - Script Editor Sheet

struct ScriptEditorSheet: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    let script: Script
    @State private var name: String
    @State private var description: String
    @State private var icon: String

    init(script: Script) {
        self.script = script
        _name = State(initialValue: script.name)
        _description = State(initialValue: script.description)
        _icon = State(initialValue: script.icon)
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("编辑脚本")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("取消") {
                    dismiss()
                }
            }

            Form {
                Section("基本信息") {
                    TextField("名称", text: $name)
                    TextField("描述", text: $description)
                    TextField("图标 (SF Symbol)", text: $icon)
                }

                Section("脚本信息") {
                    LabeledContent("类型", value: script.type.uppercased())
                    LabeledContent("路径", value: script.scriptPath)
                    LabeledContent("参数数量", value: "\(script.parameters.count)")
                }
            }

            HStack {
                Spacer()
                Button("保存") {
                    var updated = script
                    updated.name = name
                    updated.description = description
                    updated.icon = icon
                    dataStore.updateScript(updated)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 450, height: 400)
    }
}

#Preview {
    ScriptManagementView()
        .environmentObject(DataStore.shared)
}
