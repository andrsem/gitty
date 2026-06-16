// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import Foundation
import SW40

extension Collection where Element: Sendable {
   package func unorderedCompactPMap<T: Sendable>(
      maxTasks: Int? = nil,
      _ transform: @Sendable @escaping (Element) async throws -> T?
   ) async rethrows -> [T] {
      guard !isEmpty else { return [] }

      return try await withThrowingTaskGroup(of: T?.self) { group in
         var addedTasks = 0
         var isOverLimit: Bool {
            guard let maxTasks else { return false }
            return addedTasks >= Swift.max(1, maxTasks)
         }
         var results: ContiguousArray<T> = []
         results.reserveCapacity(count)

         for element in self {
            if isOverLimit, let result = try await group.next() {
               if let result { results.append(result) }
            }
            addedTasks += 1
            group.addTask { try await transform(element) }
         }

         while let result = try await group.next() {
            if let result { results.append(result) }
         }

         return Array(results)
      }
   }
}



/// Maximum amount of concurrent tasks
func tasksLimit() -> Int {
   if let env = ProcessInfo.processInfo.environment["GITTY_MAX_TASKS_LIMIT"],
      let tasksLimit = Int(env)
   {
      return max(1, tasksLimit)
   }

   let reserve = 176
   let fdsPerTask = 4
   let availableFDs = max(0, currentResourceLimit() - reserve)
   return max(1, availableFDs / fdsPerTask)
}



private func currentResourceLimit() -> Int {
   var limit = rlimit()
   let rlimitNofile = {
      #if canImport(Glibc)
         Int32(RLIMIT_NOFILE.rawValue)
      #else
         RLIMIT_NOFILE
      #endif
   }()
   guard unsafe getrlimit(rlimitNofile, &limit) != -1 else {
      return .zero
   }
   return Int(limit.rlim_cur)
}
