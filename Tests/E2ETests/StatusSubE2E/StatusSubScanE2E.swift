// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Configurator
import Diffy
import Foundation
import Testing

@Suite(.serialized, .tags(.e2eAll, .e2eStatusSub))
struct `Status Sub Scan E2E`: E2EConfigurable {
   @Test
   func `scan for repos`() async throws {
      expectMatch(
         """
           [38;5;214mA[39m  [31m?[39m repoL1                   [35m⇞[39m[1mmain      [22m    
              [31m?[39m repoL2                   [35m⇞[39m[1mmain      [22m    
         """,
         try await gitty("s -s \(l1.path())").trimmedEscapeCodes
      )
   }


   @Test
   func `scan for repos mini layout`() async throws {
      expectMatch(
         """
         [31m*[39m repoL1 [35m⇞[39m 
         [31m*[39m repoL2 [35m⇞[39m 
         """,
         try await gitty("s -l mini -s \(l1.path())").trimmedEscapeCodes,
      )
   }


   @Test
   func `scan for repos at multiple paths`() async throws {
      let depth = 2
      expectMatch(
         """
         [31m*[39m repoL1 [35m⇞[39m 
         """,
         try await gitty("s -l mini -d \(depth) -s \(l1.path())")
            .trimmedEscapeCodes,
      )
      expectMatch(
         """
         [31m*[39m repoL2 [35m⇞[39m 
         """,
         try await gitty("s -l mini -d \(depth) -s \(l2.path())")
            .trimmedEscapeCodes,
      )
      expectMatch(
         """
         [31m*[39m repoL1 [35m⇞[39m 
         [31m*[39m repoL2 [35m⇞[39m 
         """,
         try await gitty("s -l mini -d \(depth) -s \(l1.path()) \(l2.path())")
            .trimmedEscapeCodes,
      )
   }


   @Test
   func `scan for repos at depth 1 where are no repos`() async throws {
      let path = debugConfigBase.appending(path: Self.testDir).path()
      expectMatch(
         """
         No repos found at depth: 1 starting at path:
         \(path)
         """,
         try await gitty("s -d 1 -s \(path)").trimmedEscapeCodes
      )
   }


   @Test
   func `scan for repos at depth 5`() async throws {
      expectMatch(
         """
         [31m*[39m repoL1 [35m⇞[39m 
         [31m*[39m repoL2 [35m⇞[39m 
         [31m*[39m repoOtherL4 [35m⇞[39m 
         """,
         try await gitty("s -l mini -d 5 -s \(l1.path())").trimmedEscapeCodes
      )
   }
}
