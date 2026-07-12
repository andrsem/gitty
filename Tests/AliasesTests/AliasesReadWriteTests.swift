// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import Foundation
import Testing

@testable import Aliases

@Suite
struct AliasesTests {
   @Test(arguments: [
      Data(PackageResources.validAliases_json5),
      Data(PackageResources.validAliasesWithDupsUnsorted_json5),
   ])
   func `read valid aliases json clean and unsorted with dups`(
      data: Data
   ) throws {
      let validAliases = try Aliases.read { data }
      let expectedAliases: [Alias] = [
         try! Alias(
            "fetch",
            args: ["git fetch"],
            details: "Fetch git changes",
            flags: [.parallel, .quiet],
            status: [],
            delay: .zero,
            sort: .az,
         ),
         try! Alias(
            "pull",
            args: ["git pull"],
            details: "Pull git changes",
            flags: [.parallel, .quiet],
            status: [.needsPull],
            delay: .zero,
            sort: .az,
         ),
      ]

      #expect(expectedAliases == validAliases)
   }


   @Test
   func `read aliases with invalid alias name`() {
      #expect(
         throws: AliasesError.invalidFormat(AliasError.invalidName.description)
      ) {
         try Aliases.read { Data(PackageResources.invalidAliasesName_json5) }
      }
   }


   @Test
   func `read aliases with invalid alias command`() {
      #expect(
         throws:
            AliasesError
            .invalidFormat(AliasError.invalidCommand.description)
      ) {
         try Aliases.read { Data(PackageResources.invalidAliasesCommand_json5) }
      }
   }


   @Test
   func `read aliases with invalid formatting`() {
      #expect(throws: (any Error).self) {
         try Aliases.read { Data(PackageResources.invalidAliasesJSON_json5) }
      }
   }
}
