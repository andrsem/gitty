// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import Foundation
import Testing

@testable import IO

extension Tag {
   @Tag
   static var io: Self
}

@Suite(.tags(.io))
struct `IO tests` {
   let tempDir = URL.temporaryDirectory
   let fm = FileManager.default

   @Test
   func `is Git repo`() throws {
      let gitDir =
         tempDir.appending(component: "00_isGitRepo_test")

      let regularDir =
         tempDir.appending(component: "00_isNotGitRepo_test")
      let nonExistingDir = "notExisting_pAth"

      let dirWithSpaces = tempDir.appending(
         component: "dir with spaces",
         directoryHint: .isDirectory,
      )

      try [gitDir, dirWithSpaces]
         .forEach {
            try fm.createDirectory(
               at: $0.appending(component: ".git"),
               withIntermediateDirectories: true,
            )
         }


      #expect(IO.directoryContains(".git", at: gitDir.path()) == true)
      #expect(
         IO
            .directoryContains(
               ".git",
               at: dirWithSpaces.path(percentEncoded: false),
            )
            == true
      )
      #expect(IO.directoryContains(".git", at: regularDir.path()) == false)
      #expect(IO.directoryContains(".git", at: nonExistingDir) == false)


      let fileDotGit = tempDir.appending(component: "fileDotGit")
      fm.createFile(
         atPath: fileDotGit.appending(component: ".git").path(),
         contents: Data(),
      )

      #expect(
         IO.directoryContains(".git", at: fileDotGit.path()) == false,
         ".git file is not a directory",
      )
   }


   @Test
   func `initializing config files`() throws {
      let testDir =
         tempDir.appending(components: "gitty_initialization", "gitty")

      let listSource = Bundle.module
         .url(forResource: "list", withExtension: "json")!
      let someFileSource = Bundle.module
         .url(forResource: "someFile", withExtension: "txt")!

      let listTarget = testDir.appending(component: "copiedList.json")
      let someFileTarget = testDir.appending(component: "copiedFile.txt")

      try IO.initializeFilesIfNotExist(
         [
            (Data(contentsOf: listSource), listTarget),
            (Data(contentsOf: someFileSource), someFileTarget),
         ],
         at: testDir,
      )
      let testDirContent =
         try fm.contentsOfDirectory(atPath: testDir.path())


      #expect(testDirContent.count == 2)
      #expect(testDirContent.contains("copiedList.json"))
      #expect(testDirContent.contains("copiedFile.txt"))


      try fm.removeItem(at: testDir)
   }
}


@Suite(.serialized, .tags(.io))
struct `Find Directories` {
   private let fm = FileManager.default

   private static let testDir =
      URL
      .temporaryDirectory
      .appending(component: "00_findDirectories_test")

   private static let dirHierarchy =
      testDir
      .appending(
         components: "level1",
         "level2",
         ".level3hidden",
         "level4InsideHidden",
         "level5InsideHidden",
      )

   private static let someFile =
      dirHierarchy
      .appending(component: "someFile.txt")


   private init() throws {
      try? fm.removeItem(at: Self.testDir)

      try fm.createDirectory(
         at: Self.dirHierarchy,
         withIntermediateDirectories: true,
      )

      fm.createFile(
         atPath: Self.someFile.path(),
         contents: Data(),
      )
   }


   @Test
   func `find directories`() async throws {
      let level1 = await IO.findDirectories(
         "level1",
         startingAt: Self.testDir,
         upThrough: 4,
      )

      #expect(level1.count == 1)
      #expect(level1.first?.lastPathComponent == "level1")
   }


   @Test
   func `find directories inside hidden`() async throws {
      let level4 = await IO.findDirectories(
         "level4InsideHidden",
         startingAt: Self.testDir,
         upThrough: 4,
      )

      #expect(level4.count == 1)
      #expect(level4.first?.lastPathComponent == "level4InsideHidden")
   }



   @Test
   func `find directories up to 3 levels`() async throws {
      let level4 = await IO.findDirectories(
         "level4InsideHidden",
         startingAt: Self.testDir,
         upThrough: 3,
      )

      #expect(level4.isEmpty == true)
   }


   @Test
   func `find directories ignoring files`() async throws {
      let level5 = await IO.findDirectories(
         "someFile.txt",
         startingAt: Self.testDir,
         upThrough: 8,
      )

      #expect(level5.isEmpty == true)
   }


   @Test
   func `find directories infinite`() async throws {
      let level5 = await IO.findDirectories(
         "level5InsideHidden",
         startingAt: Self.testDir,
         upThrough: 0,
      )

      #expect(level5.count == 1)
      #expect(level5.first?.lastPathComponent == "level5InsideHidden")
   }


   @Test
   func `find directories via symlink`() async throws {
      let target = "target"
      let symlinkPath = Self.testDir.appending(component: "myDir")
      let symLocation = URL.temporaryDirectory.appending(
         component: "00_gitty_symLocation"
      )
      try? fm.removeItem(at: symLocation)

      try fm.createDirectory(
         at: symLocation.appending(component: target),
         withIntermediateDirectories: true,
      )
      try fm.createSymbolicLink(
         at: symlinkPath,
         withDestinationURL: symLocation,
      )

      let found = await IO.findDirectories(
         target,
         startingAt: Self.testDir,
         upThrough: 5,
      )

      #expect(found.contains { $0.lastPathComponent == target })
   }


   @Test(.timeLimit(.minutes(1)))
   func `find directories with cyclic symlink`() async throws {
      let cycleDir = Self.testDir.appending(component: "cycle_parent")
      let cycleLink = cycleDir.appending(component: "cycle_child")

      try? fm.removeItem(at: cycleLink)
      try fm.createDirectory(
         at: cycleDir,
         withIntermediateDirectories: true,
      )
      try fm.createSymbolicLink(at: cycleLink, withDestinationURL: cycleDir)

      let found = await IO.findDirectories(
         "cycle_parent",
         startingAt: Self.testDir,
         upThrough: 0,
      )

      #expect(!found.isEmpty)
      #expect(
         found.filter { $0.lastPathComponent == "cycle_parent" }.count == 1
      )
   }


   @Test(.timeLimit(.minutes(1)))
   func `find directories with cyclic symlink via symlink`() async throws {
      let cycleParent = Self.testDir.appending(component: "cycle_link_parent")
      let cycleChild = Self.testDir.appending(component: "cycle_child_dir")

      try? fm.removeItem(at: cycleChild)
      try fm.createDirectory(
         at: cycleChild,
         withIntermediateDirectories: true,
      )
      try fm.createSymbolicLink(
         at: cycleParent,
         withDestinationURL: cycleChild,
      )

      try fm.createSymbolicLink(
         at: cycleChild.appending(component: "back_to_parent"),
         withDestinationURL: cycleParent,
      )

      let found = await IO.findDirectories(
         "cycle_child_dir",
         startingAt: Self.testDir,
         upThrough: 0,
      )

      #expect(!found.isEmpty)
      #expect(
         found.filter { $0.lastPathComponent == "cycle_child_dir" }.count == 1
      )
   }


   @Test(.timeLimit(.minutes(1)))
   func `find directories with cyclic symlinks in target and other dirs`()
      async throws
   {
      let targetDirA = Self.testDir.appending(component: "targetDir")
      let targetDirB = Self.testDir.appending(component: "other")
         .appending(component: "targetDir")
      let targetDirC = Self.testDir.appending(component: "other")
         .appending(component: "nested").appending(component: "targetDir")

      let otherDir = Self.testDir.appending(component: "other")
      let nestedDir = otherDir.appending(component: "nested")

      try? fm.removeItem(at: Self.testDir)
      try fm.createDirectory(at: targetDirA, withIntermediateDirectories: true)
      try fm.createDirectory(at: otherDir, withIntermediateDirectories: true)
      try fm.createDirectory(at: nestedDir, withIntermediateDirectories: true)
      try fm.createDirectory(at: targetDirB, withIntermediateDirectories: true)
      try fm.createDirectory(at: targetDirC, withIntermediateDirectories: true)

      let cycleTargetA = Self.testDir.appending(component: "cycleTarget")
      let cycleTargetB = otherDir.appending(component: "cycleTarget")
      let cycleOther = Self.testDir.appending(component: "cycleOther")

      try fm.createDirectory(
         at: cycleTargetA,
         withIntermediateDirectories: true,
      )
      try fm.createDirectory(
         at: cycleTargetB,
         withIntermediateDirectories: true,
      )
      try fm.createDirectory(at: cycleOther, withIntermediateDirectories: true)

      try fm.createSymbolicLink(
         at: cycleTargetA.appending(component: "back_to_targetA"),
         withDestinationURL: cycleTargetA,
      )
      try fm.createSymbolicLink(
         at: cycleTargetB.appending(component: "back_to_targetB"),
         withDestinationURL: cycleTargetB,
      )
      try fm.createSymbolicLink(
         at: cycleOther.appending(component: "to_cycleTarget"),
         withDestinationURL: cycleTargetA,
      )
      try fm.createSymbolicLink(
         at: cycleTargetA.appending(component: "to_cycleOther"),
         withDestinationURL: cycleOther,
      )

      let found =
         await IO.findDirectories(
            "targetDir",
            startingAt: Self.testDir,
            upThrough: 0,
         )
         .map(\.standardizedFileURL)
         .map {
            #if os(macOS)
               $0
            #else
               String($0.path().dropLast())
            #endif
         }

      let expectedPaths =
         [targetDirA, targetDirB, targetDirC]
         .map(\.standardizedFileURL)
         .map {
            #if os(macOS)
               $0
            #else
               $0.path()
            #endif
         }

      #expect(found.count == expectedPaths.count)
      #expect(expectedPaths == found)
   }
}
