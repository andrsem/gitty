// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import Algorithms
package import Aliases
package import Foundation
import IO
package import Layout
package import List
package import Status

package enum Configurator {
   package static func findGitRepoURLs(
      at path: String,
      depth: Int,
   ) async -> [URL] {
      await IO.findDirectories(
         ".git",
         startingAt: URL(filePath: path),
         upThrough: depth,
      )
      .map { $0.deletingLastPathComponent() }
   }


   package static func initializeConfigs() throws {
      let layouts =
         IO.fileExists(at: layoutsDir.path())
         ? [(Layout.initialBase, baseLayout)]
         : [
            (Layout.initialBase, baseLayout), (Layout.initialMini, miniLayout),
         ]

      let configs = [
         (List.initial, listConfig), (Aliases.initial, aliasesConfig),
      ]

      try IO.initializeFilesIfNotExist(layouts, at: layoutsDir)
      try IO.initializeFilesIfNotExist(configs, at: configDir)
   }


   package static func allLayouts() -> [String] {
      let layouts =
         try? IO.filesWithExtension("json", at: layoutsDir)
         .compactMap { url in
            do {
               let name = url.deletingPathExtension().lastPathComponent
               _ = try Layout.read(name: name) { try IO.readFile(at: url) }
               return name
            } catch { return nil }
         }

      return layouts ?? []
   }


   package static func validatePaths(
      _ paths: [String?]
   ) -> (invalid: [String], notGit: [String]) {
      paths.reduce(into: ([], [])) {
         guard let path = $1 else { return }
         guard IO.fileExists(at: path) else {
            $0.0.append(path)
            return
         }
         guard isGitRepo(at: path) else {
            $0.1.append(path)
            return
         }
      }
   }


   private static func isGitRepo(at path: String) -> Bool {
      IO.directoryContains(".git", at: path)
   }


   package static let configDir = {
      if let debugConfig { return debugConfig }

      let baseDirectory = { (value: String) in
         guard
            let configDir = ProcessInfo.processInfo.environment[value],
            !configDir.trimming(while: \.isWhitespace).isEmpty
         else {
            return
               URL.homeDirectory.appending(
                  component: ".config",
                  directoryHint: .isDirectory,
               )
         }
         return URL(filePath: configDir, directoryHint: .isDirectory)
      }

      let appName = "gitty"
      return baseDirectory("XDG_CONFIG_HOME")
         .appending(component: appName, directoryHint: .isDirectory)
   }()
}


package let debugConfigBase = URL.temporaryDirectory
   .appending(
      component: "00_gitty_debug_config_dir",
      directoryHint: .isDirectory,
   )


/*
To use debug config dir use following env vars in terminal:

export GITTY_DEBUG_CONFIG_NAME=my_config
export PRINT_GITTY_DEBUG_CONFIG_PATH=true
gitty status

*/
package let debugConfigName = "GITTY_DEBUG_CONFIG_NAME"
private let printDebugConfigPath = "PRINT_GITTY_DEBUG_CONFIG_PATH"

private let debugConfig: URL? =
   ProcessInfo.processInfo.environment[debugConfigName]
   .flatMap {
      let config = debugConfigBase.appending(component: $0)
      if ProcessInfo.processInfo.environment[printDebugConfigPath] != nil {
         print(
            "Debug config path:",
            config.path(percentEncoded: false),
            separator: "\n",
         )
      }

      return config
   }



// MARK: - Run

extension Configurator {
   package static func run(
      _ command: [String],
      at url: URL,
      input: String = "",
   ) async throws -> (output: String, error: String) {
      try await Shell.run(command, at: url, input: input)
   }
}



// MARK: - Aliases

extension Configurator {
   package static func readAliases() throws(AliasesError) -> Aliases {
      try Aliases.read { try IO.readFile(at: aliasesConfig) }
   }


   private static let aliasesConfig =
      configDir.appending(component: "aliases.json")
}



// MARK: - Layout

extension Configurator {
   package static func readLayout(
      _ name: String
   ) throws(LayoutError) -> Layout {
      try Layout.read(name: name) {
         try IO.readFile(at: layoutsDir.appending(component: name + ".json"))
      }
   }


   private static let layoutsDir = configDir.appending(component: "layouts")
   private static let baseLayout = layoutsDir.appending(component: "base.json")
   private static let miniLayout = layoutsDir.appending(component: "mini.json")
}



// MARK: - List

extension Configurator {
   package static func readList() throws(ListError) -> List {
      try List.read(
         from: { try IO.readFile(at: listConfig) },
         isRepoValid: isGitRepo,
      )
   }


   package static func writeList(_ list: List) throws(ListError) {
      try List.write(list) { try IO.writeFile($0, at: listConfig) }
   }


   private static let listConfig = configDir.appending(component: "list.json")
}



// MARK: - Status

extension Configurator {
   package static func getStatus(
      for repoDir: URL,
      ignored: Bool,
   ) async throws(StatusError) -> (status: Status, error: String, raw: String) {
      try await Status.parse(
         at: repoDir,
         ignored: ignored,
         lockFileExists: IO.fileExists,
      ) {
         do {
            return try await Shell.runGit($0, at: $1)
         } catch {
            return ("", String(describing: error))
         }
      }
   }
}
