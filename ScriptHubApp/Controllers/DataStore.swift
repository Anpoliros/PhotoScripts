//
//  DataStore.swift
//  ScriptHub
//
//  Manages persistent storage for scripts, groups, and workflows
//

import Foundation
import Combine

class DataStore: ObservableObject {
    static let shared = DataStore()

    @Published var scripts: [Script] = []
    @Published var scriptGroups: [ScriptGroup] = []
    @Published var workflows: [Workflow] = []

    private let scriptsKey = "scripthub_scripts"
    private let groupsKey = "scripthub_groups"
    private let workflowsKey = "scripthub_workflows"

    private init() {
        loadData()
    }

    // MARK: - Persistence

    func loadData() {
        // Load scripts
        if let data = UserDefaults.standard.data(forKey: scriptsKey),
           let decoded = try? JSONDecoder().decode([Script].self, from: data) {
            scripts = decoded
        } else {
            // Try to load from config file as fallback
            scripts = ConfigLoader.loadScripts()
        }

        // Load groups
        if let data = UserDefaults.standard.data(forKey: groupsKey),
           let decoded = try? JSONDecoder().decode([ScriptGroup].self, from: data) {
            scriptGroups = decoded
        } else {
            // Create default groups
            scriptGroups = createDefaultGroups()
        }

        // Load workflows
        if let data = UserDefaults.standard.data(forKey: workflowsKey),
           let decoded = try? JSONDecoder().decode([Workflow].self, from: data) {
            workflows = decoded
        }
    }

    func saveData() {
        // Save scripts
        if let encoded = try? JSONEncoder().encode(scripts) {
            UserDefaults.standard.set(encoded, forKey: scriptsKey)
        }

        // Save groups
        if let encoded = try? JSONEncoder().encode(scriptGroups) {
            UserDefaults.standard.set(encoded, forKey: groupsKey)
        }

        // Save workflows
        if let encoded = try? JSONEncoder().encode(workflows) {
            UserDefaults.standard.set(encoded, forKey: workflowsKey)
        }
    }

    private func createDefaultGroups() -> [ScriptGroup] {
        return [
            ScriptGroup(name: "图片处理", icon: "photo.fill", color: "blue"),
            ScriptGroup(name: "文件管理", icon: "folder.fill", color: "green"),
            ScriptGroup(name: "实用工具", icon: "wrench.fill", color: "orange"),
            ScriptGroup(name: "未分类", icon: "tray.fill", color: "gray")
        ]
    }

    // MARK: - Script Management

    func addScript(_ script: Script) {
        scripts.append(script)
        saveData()
    }

    func updateScript(_ script: Script) {
        if let index = scripts.firstIndex(where: { $0.id == script.id }) {
            scripts[index] = script
            saveData()
        }
    }

    func deleteScript(_ script: Script) {
        scripts.removeAll { $0.id == script.id }

        // Remove from groups
        for i in scriptGroups.indices {
            scriptGroups[i].scriptIds.removeAll { $0 == script.id }
        }

        saveData()
    }

    func importScripts(from paths: [String]) -> [Script] {
        var imported: [Script] = []

        for path in paths {
            if let script = ScriptScanner.analyzeScript(at: path) {
                // Check if already exists
                if !scripts.contains(where: { $0.scriptPath == script.scriptPath }) {
                    scripts.append(script)
                    imported.append(script)
                }
            }
        }

        if !imported.isEmpty {
            saveData()
        }

        return imported
    }

    func scanDirectory(_ path: String, recursive: Bool = true) -> [Script] {
        let scanned = ScriptScanner.scanDirectory(at: path, recursive: recursive)
        var imported: [Script] = []

        for script in scanned {
            if !scripts.contains(where: { $0.scriptPath == script.scriptPath }) {
                scripts.append(script)
                imported.append(script)
            }
        }

        if !imported.isEmpty {
            saveData()
        }

        return imported
    }

    // MARK: - Group Management

    func addGroup(_ group: ScriptGroup) {
        scriptGroups.append(group)
        saveData()
    }

    func updateGroup(_ group: ScriptGroup) {
        if let index = scriptGroups.firstIndex(where: { $0.id == group.id }) {
            scriptGroups[index] = group
            saveData()
        }
    }

    func deleteGroup(_ group: ScriptGroup) {
        scriptGroups.removeAll { $0.id == group.id }
        saveData()
    }

    func addScriptToGroup(scriptId: String, groupId: String) {
        if let index = scriptGroups.firstIndex(where: { $0.id == groupId }) {
            if !scriptGroups[index].scriptIds.contains(scriptId) {
                scriptGroups[index].scriptIds.append(scriptId)
                saveData()
            }
        }
    }

    func removeScriptFromGroup(scriptId: String, groupId: String) {
        if let index = scriptGroups.firstIndex(where: { $0.id == groupId }) {
            scriptGroups[index].scriptIds.removeAll { $0 == scriptId }
            saveData()
        }
    }

    func getScriptsInGroup(_ groupId: String) -> [Script] {
        guard let group = scriptGroups.first(where: { $0.id == groupId }) else {
            return []
        }
        return scripts.filter { group.scriptIds.contains($0.id) }
    }

    func getUngroupedScripts() -> [Script] {
        let groupedIds = Set(scriptGroups.flatMap { $0.scriptIds })
        return scripts.filter { !groupedIds.contains($0.id) }
    }

    // MARK: - Workflow Management

    func addWorkflow(_ workflow: Workflow) {
        workflows.append(workflow)
        saveData()
    }

    func updateWorkflow(_ workflow: Workflow) {
        if let index = workflows.firstIndex(where: { $0.id == workflow.id }) {
            var updated = workflow
            updated.modifiedAt = Date()
            workflows[index] = updated
            saveData()
        }
    }

    func deleteWorkflow(_ workflow: Workflow) {
        workflows.removeAll { $0.id == workflow.id }
        saveData()
    }

    func duplicateWorkflow(_ workflow: Workflow) -> Workflow {
        var duplicate = workflow
        duplicate.id = UUID().uuidString
        duplicate.name = workflow.name + " (副本)"
        duplicate.createdAt = Date()
        duplicate.modifiedAt = Date()
        workflows.append(duplicate)
        saveData()
        return duplicate
    }

    // MARK: - Export/Import

    func exportToJSON() -> String? {
        let exportData = ExportData(
            scripts: scripts,
            groups: scriptGroups,
            workflows: workflows
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(exportData),
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }

        return json
    }

    func importFromJSON(_ json: String) -> Bool {
        guard let data = json.data(using: .utf8),
              let importData = try? JSONDecoder().decode(ExportData.self, from: data) else {
            return false
        }

        // Merge imported data
        for script in importData.scripts {
            if !scripts.contains(where: { $0.id == script.id }) {
                scripts.append(script)
            }
        }

        for group in importData.groups {
            if !scriptGroups.contains(where: { $0.id == group.id }) {
                scriptGroups.append(group)
            }
        }

        for workflow in importData.workflows {
            if !workflows.contains(where: { $0.id == workflow.id }) {
                workflows.append(workflow)
            }
        }

        saveData()
        return true
    }

    struct ExportData: Codable {
        let scripts: [Script]
        let groups: [ScriptGroup]
        let workflows: [Workflow]
    }
}
