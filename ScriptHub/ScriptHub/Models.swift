//
//  Models.swift
//  ScriptHub
//
//  Data models for script configuration and parameters
//

import Foundation

// MARK: - Script Configuration Models

struct ScriptsConfig: Codable {
    let scripts: [Script]
}

struct Script: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let type: String
    let scriptPath: String
    let className: String
    let icon: String
    let parameters: [Parameter]
    let warnings: [String]?

    enum CodingKeys: String, CodingKey {
        case id, name, description, type, scriptPath, className, icon, parameters, warnings
    }
}

struct Parameter: Codable, Identifiable {
    var id: String { name }
    let name: String
    let label: String
    let type: String
    let required: Bool
    let defaultValue: String?
    let description: String
    let options: [String]?

    enum CodingKeys: String, CodingKey {
        case name, label, type, required, defaultValue, description, options
    }
}

// MARK: - Runtime Models

class ScriptRunner: ObservableObject {
    @Published var isRunning = false
    @Published var output = ""
    @Published var error = ""
    @Published var exitCode: Int32 = 0

    func reset() {
        output = ""
        error = ""
        exitCode = 0
    }
}

struct ParameterValue: Identifiable {
    let id = UUID()
    let parameter: Parameter
    var value: String

    init(parameter: Parameter) {
        self.parameter = parameter
        self.value = parameter.defaultValue ?? ""
    }
}
