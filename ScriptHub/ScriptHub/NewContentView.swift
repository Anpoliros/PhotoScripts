//
//  NewContentView.swift
//  ScriptHub
//
//  Main view with tabs for Scripts, Groups, Workflows, and Management
//

import SwiftUI

struct NewContentView: View {
    @StateObject private var dataStore = DataStore.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Scripts Tab
            GroupedScriptsView()
                .tabItem {
                    Label("脚本", systemImage: "terminal.fill")
                }
                .tag(0)

            // Workflows Tab
            WorkflowEditorView()
                .tabItem {
                    Label("工作流", systemImage: "flowchart.fill")
                }
                .tag(1)

            // Management Tab
            ScriptManagementView()
                .tabItem {
                    Label("管理", systemImage: "hammer.fill")
                }
                .tag(2)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(3)
        }
        .environmentObject(dataStore)
    }
}

// MARK: - Grouped Scripts View

struct GroupedScriptsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedGroup: ScriptGroup?
    @State private var selectedScript: Script?
    @State private var searchText = ""
    @State private var showingGroupEditor = false

    var filteredScripts: [Script] {
        let scripts = selectedGroup != nil
            ? dataStore.getScriptsInGroup(selectedGroup!.id)
            : dataStore.scripts

        if searchText.isEmpty {
            return scripts
        }

        return scripts.filter { script in
            script.name.localizedCaseInsensitiveContains(searchText) ||
            script.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationSplitView {
            // Groups sidebar
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "folder.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text("分组")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: { showingGroupEditor = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                Divider()

                List(selection: $selectedGroup) {
                    // All scripts
                    Button(action: { selectedGroup = nil }) {
                        HStack {
                            Image(systemName: "tray.full.fill")
                                .foregroundColor(.blue)
                            Text("所有脚本")
                            Spacer()
                            Text("\(dataStore.scripts.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    Divider()

                    // Groups
                    ForEach(dataStore.scriptGroups) { group in
                        ScriptGroupRow(group: group, count: dataStore.getScriptsInGroup(group.id).count)
                            .tag(group)
                            .contextMenu {
                                Button("编辑") {
                                    // Edit group
                                }
                                Button("删除", role: .destructive) {
                                    dataStore.deleteGroup(group)
                                }
                            }
                    }

                    // Ungrouped
                    let ungrouped = dataStore.getUngroupedScripts()
                    if !ungrouped.isEmpty {
                        Divider()
                        Label {
                            HStack {
                                Text("未分类")
                                Spacer()
                                Text("\(ungrouped.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "tray")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(.sidebar)
            }
            .frame(minWidth: 200)
        } content: {
            // Scripts list
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "terminal.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text(selectedGroup?.name ?? "所有脚本")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                Divider()

                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("搜索...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .padding()

                // List
                if filteredScripts.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("没有脚本")
                            .font(.headline)
                    }
                    Spacer()
                } else {
                    List(filteredScripts, selection: $selectedScript) { script in
                        ScriptListItem(script: script)
                            .tag(script)
                            .contextMenu {
                                Menu("添加到分组") {
                                    ForEach(dataStore.scriptGroups) { group in
                                        Button(group.name) {
                                            dataStore.addScriptToGroup(scriptId: script.id, groupId: group.id)
                                        }
                                    }
                                }
                            }
                    }
                    .listStyle(.inset)
                }
            }
            .frame(minWidth: 280)
        } detail: {
            // Detail
            if let script = selectedScript {
                ScriptDetailView(script: script)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "arrow.left.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("选择脚本")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingGroupEditor) {
            GroupEditorSheet()
        }
    }
}

// MARK: - Script Group Row

struct ScriptGroupRow: View {
    let group: ScriptGroup
    let count: Int

    var body: some View {
        Label {
            HStack {
                Text(group.name)
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } icon: {
            Image(systemName: group.icon)
                .foregroundColor(colorForName(group.color))
        }
    }

    private func colorForName(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        default: return .gray
        }
    }
}

// MARK: - Group Editor Sheet

struct GroupEditorSheet: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var icon = "folder.fill"
    @State private var color = "blue"

    let availableIcons = ["folder.fill", "photo.fill", "doc.fill", "wrench.fill", "star.fill"]
    let availableColors = ["blue", "green", "orange", "purple", "red", "gray"]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("新建分组")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("取消") {
                    dismiss()
                }
            }

            Form {
                TextField("分组名称", text: $name)

                Picker("图标", selection: $icon) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Label("", systemImage: icon).tag(icon)
                    }
                }
                .pickerStyle(.segmented)

                Picker("颜色", selection: $color) {
                    ForEach(availableColors, id: \.self) { color in
                        Text(color).tag(color)
                    }
                }
            }

            HStack {
                Spacer()
                Button("创建") {
                    let group = ScriptGroup(name: name, icon: icon, color: color)
                    dataStore.addGroup(group)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 250)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var projectRoot = ConfigLoader.getProjectRoot()

    var body: some View {
        Form {
            Section("项目设置") {
                HStack {
                    Text("项目根目录:")
                    Spacer()
                    Text(projectRoot)
                        .foregroundColor(.secondary)
                    Button("选择") {
                        selectProjectRoot()
                    }
                }
            }

            Section("数据") {
                HStack {
                    Text("脚本数量:")
                    Spacer()
                    Text("\(dataStore.scripts.count)")
                }
                HStack {
                    Text("分组数量:")
                    Spacer()
                    Text("\(dataStore.scriptGroups.count)")
                }
                HStack {
                    Text("工作流数量:")
                    Spacer()
                    Text("\(dataStore.workflows.count)")
                }

                Divider()

                Button("导出所有数据") {
                    exportData()
                }
                Button("导入数据") {
                    importData()
                }
                Button("重置所有数据", role: .destructive) {
                    resetData()
                }
            }

            Section("关于") {
                HStack {
                    Text("Script Hub")
                        .font(.headline)
                    Spacer()
                    Text("v1.0")
                        .foregroundColor(.secondary)
                }
                Text("一个通用的脚本管理和自动化工具")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }

    private func selectProjectRoot() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false

        if panel.runModal() == .OK, let url = panel.url {
            projectRoot = url.path
        }
    }

    private func exportData() {
        guard let json = dataStore.exportToJSON() else { return }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = "script_hub_export.json"

        if panel.runModal() == .OK, let url = panel.url {
            try? json.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    private func importData() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            if let json = try? String(contentsOf: url, encoding: .utf8) {
                _ = dataStore.importFromJSON(json)
            }
        }
    }

    private func resetData() {
        // Show confirmation dialog
        let alert = NSAlert()
        alert.messageText = "确认重置"
        alert.informativeText = "这将删除所有脚本、分组和工作流数据。此操作无法撤销。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "取消")
        alert.addButton(withTitle: "重置")

        if alert.runModal() == .alertSecondButtonReturn {
            UserDefaults.standard.removeObject(forKey: "scripthub_scripts")
            UserDefaults.standard.removeObject(forKey: "scripthub_groups")
            UserDefaults.standard.removeObject(forKey: "scripthub_workflows")
            dataStore.loadData()
        }
    }
}

#Preview {
    NewContentView()
}
