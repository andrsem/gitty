// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

package import Foundation

package enum IO {
   package static func fileExists(at path: String) -> Bool {
      fm.fileExists(atPath: URL(filePath: path).path(percentEncoded: false))
   }


   package static func filesWithExtension(
      _ pathExtension: String,
      at url: URL,
   ) throws -> [URL] {
      try fm
         .contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [
               .skipsPackageDescendants,
               .skipsSubdirectoryDescendants,
            ],
         )
         .filter { $0.pathExtension == pathExtension }
   }


   package static func directoryContains(
      _ file: String,
      at path: String,
   ) -> Bool {
      let path = URL(filePath: path).path(percentEncoded: false)
      return
         (try? fm
         .contentsOfDirectory(atPath: path)
         .contains(file))
         ?? false
   }


   package static func readFile(at url: URL) throws -> Data {
      try Data(contentsOf: url)
   }


   package static func writeFile(_ data: Data, at url: URL) throws {
      try data.write(to: url, options: .atomic)
   }


   package static func initializeFilesIfNotExist(
      _ files: [(data: Data, url: URL)],
      at directory: URL,
   ) throws {
      try fm.createDirectory(
         at: directory.resolvingSymlinksInPath(),
         withIntermediateDirectories: true,
      )

      try files.forEach {
         guard !fm.fileExists(atPath: $0.url.path()) else { return }
         try writeFile($0.data, at: $0.url)
      }
   }


   /// Returns an array of URLs, matching the directory name, starting at the URL and going up through the depth.
   ///
   /// Depth:
   ///  - `0` - all hierarchies
   ///  - `1` - current directory
   ///  - `2` - current directory and its immediate subdirectories
   package static func findDirectories(
      _ directoryName: String,
      startingAt url: URL,
      upThrough depth: Int,
   ) async -> [URL] {
      await _findDirectories(
         directoryName,
         startingAt: url.resolvingSymlinksInPath(),
         upThrough: depth,
         visited: VisitedDirectories(),
      )
   }


   private actor VisitedDirectories {
      private var paths: Set<URL> = []

      func canVisit(_ key: URL) -> Bool {
         guard !paths.contains(key) else { return false }
         paths.insert(key)
         return true
      }
   }


   private static func _findDirectories(
      _ directoryName: String,
      startingAt url: URL,
      upThrough depth: Int,
      visited: VisitedDirectories,
   ) async -> [URL] {
      let url = url.resolvingSymlinksInPath()
      guard await visited.canVisit(url) else { return [] }

      let resourceKeys: Set<URLResourceKey> = [
         .nameKey,
         .isDirectoryKey,
         .isSymbolicLinkKey,
      ]

      guard
         let urls = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: Array(resourceKeys),
         )
      else { return [] }

      let (matched, subdirectories) =
         urls
         .reduce(into: ([URL](), [(URL, isSymLink: Bool)]())) {
            guard
               let res = try? $1.resourceValues(forKeys: resourceKeys),
               let isDir = res.isDirectory,
               let isSym = res.isSymbolicLink,
               let name = res.name
            else { return }

            if isDir || isSym { $0.1.append(($1, isSym)) }
            if isDir, name == directoryName { $0.0.append($1) }
         }

      let recursionDepth = depth == 0 ? 0 : depth - 1

      return depth == 1
         ? matched
         : await withTaskGroup(of: [URL].self) { group in
            subdirectories.forEach { (sub, isSym) in
               group.addTask {
                  await _findDirectories(
                     directoryName,
                     startingAt: isSym ? sub.resolvingSymlinksInPath() : sub,
                     upThrough: recursionDepth,
                     visited: visited,
                  )
               }
            }
            return
               await group
               .reduce(into: matched) { $0.append(contentsOf: $1) }
         }
   }



   private static var fm: FileManager { FileManager.default }
}
