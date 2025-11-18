//
//  WorkflowEditorView.swift
//  ScriptHub
//
//  Visual workflow editor - drag and drop scripts to create workflows
//

import SwiftUI

struct WorkflowEditorView: View {
    @EnvironmentObject var dataStore: DataStore
    @StateObject private var workflowRunner = WorkflowRunner()

    @State private var workflows: [Workflow] = []
    @State private var selectedWorkflow: Workflow?
    @State private var showingNewWorkflowSheet = false
    @State private var showingCanvasEditor = false

    var body: some View {
        NavigationSplitView {
            // Sidebar - Workflow List
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "flowchart.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                    Text("工作流")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: { showingNewWorkflowSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    .help("新建工作流")
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                Divider()

                // Workflow list
                if dataStore.workflows.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "flowchart")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("还没有工作流")
                            .font(.headline)
                        Text("点击 + 创建第一个工作流")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List(dataStore.workflows, selection: $selectedWorkflow) { workflow in
                        WorkflowListItem(workflow: workflow)
                            .tag(workflow)
                            .contextMenu {
                                Button(action: { duplicateWorkflow(workflow) }) {
                                    Label("复制", systemImage: "doc.on.doc")
                                }
                                Button(role: .destructive, action: { deleteWorkflow(workflow) }) {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                    }
                    .listStyle(.sidebar)
                }

                // Footer
                HStack {
                    Text("\(dataStore.workflows.count) 个工作流")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
            }
            .frame(minWidth: 250)
        } detail: {
            // Detail view
            if let workflow = selectedWorkflow {
                WorkflowDetailView(workflow: binding(for: workflow))
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "flowchart")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("请从左侧选择或创建工作流")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingNewWorkflowSheet) {
            NewWorkflowSheet()
        }
    }

    private func binding(for workflow: Workflow) -> Binding<Workflow> {
        Binding(
            get: { workflow },
            set: { dataStore.updateWorkflow($0) }
        )
    }

    private func duplicateWorkflow(_ workflow: Workflow) {
        let duplicate = dataStore.duplicateWorkflow(workflow)
        selectedWorkflow = duplicate
    }

    private func deleteWorkflow(_ workflow: Workflow) {
        dataStore.deleteWorkflow(workflow)
        if selectedWorkflow?.id == workflow.id {
            selectedWorkflow = nil
        }
    }
}

// MARK: - Workflow List Item

struct WorkflowListItem: View {
    let workflow: Workflow

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: workflow.icon)
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(workflow.name)
                    .font(.headline)
                if !workflow.description.isEmpty {
                    Text(workflow.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                HStack(spacing: 8) {
                    Label("\(workflow.nodes.count)", systemImage: "circle.hexagongrid.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Label("\(workflow.connections.count)", systemImage: "arrow.right")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Workflow Detail View

struct WorkflowDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var workflow: Workflow
    @StateObject private var runner = WorkflowRunner()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            WorkflowHeader(workflow: workflow)

            Divider()

            HSplitView {
                // Canvas area
                WorkflowCanvas(workflow: $workflow)
                    .frame(minWidth: 400)

                // Output panel
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "terminal")
                        Text("执行输出")
                            .font(.headline)
                        Spacer()

                        if runner.isRunning {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Button(action: runWorkflow) {
                                Label("运行工作流", systemImage: "play.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(workflow.nodes.isEmpty)
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))

                    Divider()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if !runner.overallOutput.isEmpty {
                                Text(runner.overallOutput)
                                    .font(.system(.body, design: .monospaced))
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else if !runner.isRunning {
                                VStack(spacing: 12) {
                                    Image(systemName: "play.circle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("点击运行查看输出")
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .padding()
                    }
                }
                .frame(minWidth: 350)
            }
        }
    }

    private func runWorkflow() {
        WorkflowExecutor.executeWorkflow(
            workflow,
            scripts: dataStore.scripts,
            projectRoot: ConfigLoader.getProjectRoot(),
            runner: runner
        )
    }
}

// MARK: - Workflow Header

struct WorkflowHeader: View {
    let workflow: Workflow

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: workflow.icon)
                .font(.system(size: 40))
                .foregroundColor(.purple)
                .frame(width: 60, height: 60)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(workflow.name)
                    .font(.title)
                    .fontWeight(.bold)
                if !workflow.description.isEmpty {
                    Text(workflow.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 12) {
                    Label("\(workflow.nodes.count) 个节点", systemImage: "circle.hexagongrid.fill")
                        .font(.caption)
                        .foregroundColor(.blue)

                    Label("\(workflow.connections.count) 个连接", systemImage: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding(.top, 4)
            }

            Spacer()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Workflow Canvas

struct WorkflowCanvas: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var workflow: Workflow

    @State private var showingScriptPicker = false
    @State private var draggedNodeId: String?
    @State private var canvasOffset: CGPoint = .zero

    var body: some View {
        ZStack {
            Color(NSColor.textBackgroundColor)

            // Canvas content
            ZStack {
                // Connections
                ForEach(workflow.connections) { connection in
                    if let fromNode = workflow.nodes.first(where: { $0.id == connection.fromNodeId }),
                       let toNode = workflow.nodes.first(where: { $0.id == connection.toNodeId }) {
                        ConnectionLine(from: fromNode.position, to: toNode.position)
                    }
                }

                // Nodes
                ForEach(workflow.nodes) { node in
                    if let script = dataStore.scripts.first(where: { $0.id == node.scriptId }) {
                        WorkflowNodeView(script: script, node: node)
                            .position(node.position)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        updateNodePosition(nodeId: node.id, position: value.location)
                                    }
                            )
                    }
                }
            }
            .offset(x: canvasOffset.x, y: canvasOffset.y)

            // Empty state
            if workflow.nodes.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "plus.circle.dashed")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("添加脚本节点开始构建工作流")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Button(action: { showingScriptPicker = true }) {
                        Label("添加节点", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            // Floating add button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingScriptPicker = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                            .background(
                                Circle()
                                    .fill(Color(NSColor.controlBackgroundColor))
                                    .frame(width: 50, height: 50)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .help("添加节点")
                }
            }
        }
        .sheet(isPresented: $showingScriptPicker) {
            ScriptPickerSheet(workflow: $workflow)
        }
    }

    private func updateNodePosition(nodeId: String, position: CGPoint) {
        if let index = workflow.nodes.firstIndex(where: { $0.id == nodeId }) {
            workflow.nodes[index].position = position
        }
    }
}

// MARK: - Connection Line

struct ConnectionLine: View {
    let from: CGPoint
    let to: CGPoint

    var body: some View {
        Path { path in
            path.move(to: from)

            let midX = (from.x + to.x) / 2
            let control1 = CGPoint(x: midX, y: from.y)
            let control2 = CGPoint(x: midX, y: to.y)

            path.addCurve(to: to, control1: control1, control2: control2)
        }
        .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }
}

// MARK: - Workflow Node View

struct WorkflowNodeView: View {
    let script: Script
    let node: WorkflowNode

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: script.icon)
                    .foregroundColor(.blue)
                Text(script.name)
                    .font(.headline)
                    .lineLimit(1)
            }
            .padding(12)
            .frame(width: 200)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Script Picker Sheet

struct ScriptPickerSheet: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    @Binding var workflow: Workflow

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("选择脚本")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("取消") {
                    dismiss()
                }
            }

            List(dataStore.scripts) { script in
                Button(action: { addNode(script: script) }) {
                    HStack {
                        Image(systemName: script.icon)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(script.name)
                                .font(.headline)
                            Text(script.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "plus.circle")
                            .foregroundColor(.green)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(width: 450, height: 500)
    }

    private func addNode(script: Script) {
        let centerX = 400.0
        let centerY = 300.0 + Double(workflow.nodes.count * 100)
        let position = CGPoint(x: centerX, y: centerY)

        let node = WorkflowNode(scriptId: script.id, position: position)
        workflow.nodes.append(node)
        dismiss()
    }
}

// MARK: - New Workflow Sheet

struct NewWorkflowSheet: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var description = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("新建工作流")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("取消") {
                    dismiss()
                }
            }

            Form {
                TextField("工作流名称", text: $name)
                TextField("描述（可选）", text: $description)
            }

            HStack {
                Spacer()
                Button("创建") {
                    let workflow = Workflow(name: name, description: description)
                    dataStore.addWorkflow(workflow)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}

#Preview {
    WorkflowEditorView()
        .environmentObject(DataStore.shared)
}
