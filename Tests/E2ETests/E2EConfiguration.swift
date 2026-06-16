// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Configurator
import Foundation
import IO
import SW40
import Testing

extension Tag {
   @Tag
   static var e2eAll: Self
}



extension String {
   var trimmedEscapeCodes: String { replacing(/\u{001B}/, with: "") }
}



protocol E2EConfigurable { init() async throws }


extension E2EConfigurable {
   init() async throws {
      try await e2eSetup(Self.testDir, createRepos: true)
      _ = try await gittyRun("l -A \(Self.l1Dir.path())", Self.testDir)
      try await self.init()
   }


   static var testDir: String {
      String(describing: Self.self)
         .replacing("`", with: "")
         .replacing(/\s/, with: "_")
   }


   func gitty(_ args: String) async throws -> String {
      try await gitty(args, input: "")
   }


   func gitty(
      _ args: String,
      input: String = "",
   ) async throws -> String {
      try await gittyRun(args, Self.testDir, input: input)
   }


   func addTags(toAll: Bool = false) async throws {
      let path = toAll ? "" : "-i repoL1"
      _ = try await gitty("l --add-tags cat " + path)
   }


   func removeAllRepos() async throws {
      _ = try await gitty("l -r \(l1.path())", input: "y")
   }


   var l1: URL { Self.l1Dir }
   var l2: URL {
      debugConfigBase.appending(components: Self.testDir, "L1", "L2")
   }

   private static var l1Dir: URL {
      debugConfigBase.appending(components: Self.testDir, "L1")
   }
}


private func gittyRun(
   _ args: String,
   _ testDir: String,
   input: String = ""
) async throws -> String {
   let gittyBin =
      processName == "xctest"
      ? try binFromDerivedData() ?? binFromPackage
      : binFromPackage

   return
      try await Shell.run(
         [gittyBin + " " + args],
         environment: [debugConfigName: testDir],
         input: input,
      )
      |> { String($0.output.dropLast() + $0.error.dropLast()) }
}


private func e2eSetup(_ name: String, createRepos: Bool = false) async throws {
   try? removeDebugConfigDir(name)
   try await createDebugConfigDir(name, createRepos: createRepos)

   guard
      processName == "xctest",
      try binFromDerivedData() == nil
   else { return }

   _ = try await Shell.run(["swift build -c debug"], at: gittyPackage)
}


private let processName = ProcessInfo.processInfo.processName

private func createDebugConfigDir(
   _ name: String,
   createRepos: Bool,
) async throws {
   let configDir = debugConfigBase.appending(component: name)
   let l1 = configDir.appending(component: "L1")
   let l2 = l1.appending(component: "L2")
   let l3 = l2.appending(component: "L3")
   let l4 = l3.appending(component: "OtherL4")
   let l5 = l4.appending(component: " with spaces  ")

   try FileManager.default
      .createDirectory(at: l4, withIntermediateDirectories: true)

   if createRepos {
      try await createGitRepos(at: [l1, l2, l4, l5])
   }
}


private func removeDebugConfigDir(_ name: String) throws {
   try FileManager.default.removeItem(
      at: debugConfigBase.appending(component: name)
   )
}


private func createGitRepos(at urls: [URL]) async throws {
   for url in urls {
      let repo = url.lastPathComponent.contains(" ") ? "  repo" : "repo"
      let repoDir = url.appending(component: repo + url.lastPathComponent)
      try FileManager.default.createDirectory(
         at: repoDir,
         withIntermediateDirectories: true
      )

      ["file", "otherFile"]
         .map { $0 + url.lastPathComponent }
         .forEach {
            _ = FileManager.default
               .createFile(
                  atPath: repoDir.appending(component: $0).path(),
                  contents: Data()
               )
         }

      _ = try await Shell.runGit(["init", ".", "-b", "main"], at: repoDir)

      switch url.lastPathComponent {
      case "L1": _ = try await Shell.runGit(["add", "fileL1"], at: repoDir)
      case _: break
      }
   }
}


private let gittyPackage = URL(filePath: #filePath)
   .deletingLastPathComponent()
   .deletingLastPathComponent()
   .deletingLastPathComponent()


private let binFromPackage =
   gittyPackage
   .appending(path: ".build/debug/gitty")
   .path()


@MainActor
private let binFromDerivedData = {
   try FileManager.default
      .contentsOfDirectory(
         at: URL(filePath: "~/Library/Developer/Xcode/DerivedData"),
         includingPropertiesForKeys: [.contentModificationDateKey]
      )
      .lazy
      .compactMap(getModifiedDate)
      .filter { (Date.now - 120) ... Date.now ~= $0.date }
      .sorted { $0.date > $1.date }
      .map(\.url)
      .filter { $0.lastPathComponent.hasPrefix("gitty") }
      .first?
      .appending(path: "Build/Products/Debug/gitty")
      .path()
}



private func getModifiedDate(for url: URL) -> (url: URL, date: Date)? {
   guard
      let date =
         try? url
         .resourceValues(forKeys: [.contentModificationDateKey])
         .contentModificationDate
   else { return nil }
   return (url: url, date: date)
}
