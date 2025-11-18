//
//  ScriptHubApp.swift
//  ScriptHub
//
//  A macOS application for managing and running photo processing scripts
//

import SwiftUI

@main
struct ScriptHubApp: App {
    var body: some Scene {
        WindowGroup {
            NewContentView()
                .frame(minWidth: 1000, minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建工作流") {
                    // Trigger new workflow
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
