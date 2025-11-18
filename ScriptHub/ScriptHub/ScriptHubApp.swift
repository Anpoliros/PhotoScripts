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
            ContentView()
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
