// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Testing

@testable import Status

extension Tag {
   @Tag
   static var status: Self
}


@Suite(.tags(.status))
struct `Parsing raw branch status` {
   let fakeURL = URL(filePath: "")

   func parse(_ raw: String, error: String = "") async throws -> Status {
      try await Status.parse(
         at: fakeURL,
         ignored: true,
         lockFileExists: { _ in false },
         run: { _, _ in (raw, error) }
      )
      .status
   }


   @Test(
      arguments: [
         "",
         " ",
         "abc",
         "# branch.oid (initial)",
         "# branch.head",
         """
         # branch.oid (initial)
         # branch.head
         """,
         """
         # branch.oid 
         # branch.head head
         """,
         """
         # branch.oid
         # branch.head
         """,
         """
         # branch.head 
         # branch.oid fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e
         # branch.upstream origin/main
         # branch.ab +6 -1
         # stash 2
         """,
      ]
   )
   func `invalid raw branch status`(raw: String) async throws {
      await #expect(throws: StatusError.invalidRaw("")) {
         try await parse(raw)
      }
   }


   @Test(
      arguments: [
         (
            """
            # branch.oid fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e
            # branch.head main
            # branch.upstream origin/main
            # branch.ab +6 -1
            # stash 2
            """,
            Status(
               oid: "fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e",
               head: "main",
               upstream: "origin/main",
               pullCount: 1,
               pushCount: 6,
               stashCount: 2,
               isLocked: false,
               changedEntries: []
            )
         ),
         (
            """
            # branch.oid fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e
            # branch.head main
            # branch.upstream origin/main
            # branch.ab +6 -0
            """,
            Status(
               oid: "fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e",
               head: "main",
               upstream: "origin/main",
               pullCount: 0,
               pushCount: 6,
               stashCount: 0,
               isLocked: false,
               changedEntries: []
            )
         ),
         (
            """
            # branch.oid fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e
            # branch.head main
            # branch.upstream origin/main
            """,
            Status(
               oid: "fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e",
               head: "main",
               upstream: "origin/main",
               pullCount: 0,
               pushCount: 0,
               stashCount: 0,
               isLocked: false,
               changedEntries: []
            )
         ),
         (
            """
            # branch.oid fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e
            # branch.head main
            """,
            Status(
               oid: "fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e",
               head: "main",
               upstream: "",
               pullCount: 0,
               pushCount: 0,
               stashCount: 0,
               isLocked: false,
               changedEntries: []
            )
         ),
         (
            """
            # branch.oid fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e
            # branch.head main
            ! /Dev
            ? /abc
            1 A. N... 000000 100644 100644 0000000000000000000000000000000000000000 89b24ecec50c07aef0d6640a2a9f6dc354a33125 file.txt
            u UU N... 100644 100644 100644 100644 89b24ecec50c07aef0d6640a2a9f6dc354a33125 065e9d1c71aa492e9588ac906ff84e1b552aa388 8647c5d0268eabfbfb6bc65b30678570c2df4583 file.txt
            2 R. N... 100644 100644 100644 d95f3ad14dee633a758d2e331151e950dd13e4ed d95f3ad14dee633a758d2e331151e950dd13e4ed R100 renamed.txt\tfile.txt
            """,
            Status(
               oid: "fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e",
               head: "main",
               upstream: "",
               pullCount: 0,
               pushCount: 0,
               stashCount: 0,
               isLocked: false,
               changedEntries: [
                  .ignored,
                  .untracked,
                  .orcuChange(
                     xy: .init(index: .added, workingTree: .unmodified),
                     sub: .notSubmodule,
                  ),
                  .orcuChange(
                     xy: .init(index: .unmerged, workingTree: .unmerged),
                     sub: .notSubmodule,
                  ),
                  .orcuChange(
                     xy: .init(index: .renamed, workingTree: .unmodified),
                     sub: .notSubmodule,
                  ),
               ]
            )
         ),
      ]
   )
   func `valid branch status`(input: (String, Status)) async throws {
      let (raw, status) = input
      let parsed = try await parse(raw)
      expectMatch(parsed, status)
   }


   @Test(
      "Is initial commit",
      arguments: [
         """
         # branch.oid (initial)
         # branch.head main   
         """,
         """
         # branch.head main   
         # branch.oid (initial)
         """,
      ]
   )
   func initialCommit(raw: String) async throws {
      let status = try await parse(raw)
      #expect(status.isInitialCommit == true)
   }


   @Test("Is detached")
   func isDetached() async throws {
      let raw =
         """
         # branch.oid 416c58071d01
         # branch.head (detached)
         """

      let status = try await parse(raw)
      #expect(status.isDetached == true)
   }


   @Test
   func `needs push`() async throws {
      let raw =
         """
         # branch.oid 416c58071d01
         # branch.head main
         # branch.ab +6 -0
         """
      let status = try await parse(raw)
      #expect(status.needsPush == true)
      #expect(status.needsPull == false)
   }


   @Test
   func `needs pull`() async throws {
      let raw =
         """
         # branch.oid 416c58071d01
         # branch.head main
         # branch.ab +0 -1
         """
      let status = try await parse(raw)
      #expect(status.needsPush == false)
      #expect(status.needsPull == true)
   }


   @Test
   func `needs pull and push`() async throws {
      let raw =
         """
         # branch.oid 416c58071d01
         # branch.head main
         # branch.ab +1 -1
         """
      let status = try await parse(raw)
      #expect(status.needsPush == true)
      #expect(status.needsPull == true)
   }


   @Test
   func `does not need pull and push`() async throws {
      let raw =
         """
         # branch.oid 416c58071d01
         # branch.head main
         # branch.ab +0 -0
         """
      let status = try await parse(raw)
      #expect(status.needsPush == false)
      #expect(status.needsPull == false)
   }


   @Test
   func `needs upstream`() async throws {
      let raw =
         """
         # branch.oid 416c58071d01
         # branch.head main
         # branch.upstream
         """
      let status = try await parse(raw)
      #expect(status.needsUpstream == true)
   }


   @Test
   func `does not need upstream`() async throws {
      let raw =
         """
         # branch.oid 416c58071d01
         # branch.head main
         # branch.upstream origin/main
         """
      let status = try await parse(raw)
      #expect(status.needsUpstream == false)
   }


   @Test
   func `status is clean`() async throws {
      let raw =
         """
         # branch.oid 416c58071d01
         # branch.head main
         """
      let status = try await parse(raw)
      #expect(status.isClean == true)
   }
}
