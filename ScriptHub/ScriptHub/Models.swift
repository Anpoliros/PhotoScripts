//
//  Models.swift
//  ScriptHub
//
//  Data models for script configuration and parameters
//

import Foundation
import CoreGraphics

// MARK: - CGPoint Codable Extension

extension CGPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }
}

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

// MARK: - Script Groups

struct ScriptGroup: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    var icon: String
    var color: String
    var scriptIds: [String]

    init(id: String = UUID().uuidString, name: String, icon: String = "folder.fill", color: String = "blue", scriptIds: [String] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.scriptIds = scriptIds
    }
}

// MARK: - Workflow Models

struct Workflow: Codable, Identifiable {
    let id: String
    var name: String
    var description: String
    var icon: String
    var nodes: [WorkflowNode]
    var connections: [WorkflowConnection]
    var createdAt: Date
    var modifiedAt: Date

    init(id: String = UUID().uuidString, name: String, description: String = "", icon: String = "flowchart.fill", nodes: [WorkflowNode] = [], connections: [WorkflowConnection] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.nodes = nodes
        self.connections = connections
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

struct WorkflowNode: Codable, Identifiable {
    let id: String
    let scriptId: String
    var position: CGPoint
    var parameterMappings: [String: ParameterMapping]  // parameter name -> mapping

    init(id: String = UUID().uuidString, scriptId: String, position: CGPoint = .zero, parameterMappings: [String: ParameterMapping] = [:]) {
        self.id = id
        self.scriptId = scriptId
        self.position = position
        self.parameterMappings = parameterMappings
    }
}

enum ParameterMapping: Codable, Hashable {
    case constant(String)  // Fixed value
    case output(nodeId: String, outputType: OutputType)  // From another node's output
    case userInput  // Ask user at runtime

    enum OutputType: String, Codable {
        case stdout
        case stderr
        case exitCode
        case workingDirectory
    }
}

struct WorkflowConnection: Codable, Identifiable {
    let id: String
    let fromNodeId: String
    let toNodeId: String
    let outputType: ParameterMapping.OutputType

    init(id: String = UUID().uuidString, fromNodeId: String, toNodeId: String, outputType: ParameterMapping.OutputType = .stdout) {
        self.id = id
        self.fromNodeId = fromNodeId
        self.toNodeId = toNodeId
        self.outputType = outputType
    }
}

// MARK: - Workflow Execution

class WorkflowRunner: ObservableObject {
    @Published var isRunning = false
    @Published var currentNodeId: String?
    @Published var nodeOutputs: [String: NodeOutput] = [:]
    @Published var overallOutput = ""
    @Published var error = ""

    struct NodeOutput {
        var stdout: String = ""
        var stderr: String = ""
        var exitCode: Int32 = 0
        var workingDirectory: String = ""
    }

    func reset() {
        currentNodeId = nil
        nodeOutputs = [:]
        overallOutput = ""
        error = ""
    }
}
