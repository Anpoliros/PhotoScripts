//
//  ContentView.swift
//  ScriptHub
//
//  Main view showing list of available scripts
//

import SwiftUI

struct ContentView: View {
    @State private var scripts: [Script] = []
    @State private var selectedScript: Script?
    @State private var searchText = ""

    var filteredScripts: [Script] {
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
            // Sidebar - Script List
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "terminal.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Script Hub")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("搜索脚本...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Script list
                if scripts.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("未找到脚本配置")
                            .font(.headline)
                        Text("请确保 scripts_config.json 存在")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("重新加载") {
                            loadScripts()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                } else {
                    List(filteredScripts, selection: $selectedScript) { script in
                        ScriptListItem(script: script)
                            .tag(script)
                    }
                    .listStyle(.sidebar)
                }

                // Footer
                HStack {
                    Text("\(scripts.count) 个脚本")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: loadScripts) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("重新加载脚本")
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
            }
            .frame(minWidth: 280)
        } detail: {
            // Detail view
            if let script = selectedScript {
                ScriptDetailView(script: script)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "arrow.left.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("请从左侧选择一个脚本")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            loadScripts()
        }
    }

    private func loadScripts() {
        scripts = ConfigLoader.loadScripts()
        if !scripts.isEmpty && selectedScript == nil {
            selectedScript = scripts[0]
        }
    }
}

struct ScriptListItem: View {
    let script: Script

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: script.icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(script.name)
                    .font(.headline)
                Text(script.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Script type badge
            Text(script.type.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
