// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Configurator
import Foundation
import Shared
import Testing

@Suite(.serialized, .tags(.e2eAll))
struct `Gitty E2E`: E2EConfigurable {
   @Test
   func `gitty prints config path`() async throws {
      let out = try await gitty("--config-path")
      #expect(out.hasPrefix(debugConfigBase.path()) == true)
   }


   @Test
   func `gitty print regex reference`() async throws {
      let result = try await gitty("--regex-reference").trimmedWN
      #expect(result.isEmpty == false)
   }
}
