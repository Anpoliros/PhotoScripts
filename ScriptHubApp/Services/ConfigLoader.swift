//
//  ConfigLoader.swift
//  ScriptHub
//
//  Loads script configuration from JSON file
//

import Foundation

class ConfigLoader {
    static func loadScripts(from configPath: String? = nil) -> [Script] {
        // Try to find config file
        let possiblePaths = [
            configPath,
            Bundle.main.path(forResource: "scripts_config", ofType: "json"),
            FileManager.default.currentDirectoryPath + "/scripts_config.json",
            FileManager.default.currentDirectoryPath + "/../scripts_config.json"
        ].compactMap { $0 }

        for path in possiblePaths {
            if let scripts = loadScriptsFromPath(path) {
                return scripts
            }
        }

        print("⚠️ Could not find scripts_config.json in any standard location")
        return []
    }

    private static func loadScriptsFromPath(_ path: String) -> [Script]? {
        guard FileManager.default.fileExists(atPath: path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let config = try JSONDecoder().decode(ScriptsConfig.self, from: data)
            print("✅ Loaded \(config.scripts.count) scripts from: \(path)")
            return config.scripts
        } catch {
            print("❌ Error loading config from \(path): \(error)")
            return nil
        }
    }

    static func getProjectRoot() -> String {
        // Try to find the project root by looking for Scripts directory
        var currentPath = FileManager.default.currentDirectoryPath

        for _ in 0..<5 { // Check up to 5 levels up
            // Check for new Scripts directory structure
            let scriptsPath = currentPath + "/Scripts"
            if FileManager.default.fileExists(atPath: scriptsPath) {
                return currentPath
            }
            // Fallback: check for legacy src directory
            let srcPath = currentPath + "/src"
            if FileManager.default.fileExists(atPath: srcPath) {
                return currentPath
            }
            currentPath = (currentPath as NSString).deletingLastPathComponent
        }

        return FileManager.default.currentDirectoryPath
    }

    static func getScriptsDirectory() -> String {
        let root = getProjectRoot()

        // Try new Scripts directory first
        let scriptsPath = root + "/Scripts"
        if FileManager.default.fileExists(atPath: scriptsPath) {
            return scriptsPath
        }

        // Fallback to legacy src directory
        let srcPath = root + "/src"
        if FileManager.default.fileExists(atPath: srcPath) {
            return srcPath
        }

        return scriptsPath // Return Scripts path as default
    }

    static func getCompiledClassesDirectory() -> String {
        let root = getProjectRoot()

        // New location
        let newPath = root + "/Build/Classes"
        if FileManager.default.fileExists(atPath: newPath) {
            return newPath
        }

        // Legacy location
        let legacyPath = root + "/out/production/Scripts"
        if FileManager.default.fileExists(atPath: legacyPath) {
            return legacyPath
        }

        return newPath // Return new path as default
    }
}
