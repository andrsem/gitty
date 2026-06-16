// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import SW40
import Testing

@testable import Layout

extension Tag {
   @Tag
   static var layout: Self
}

@Suite(.tags(.layout))
struct `Read Layout Tests` {
   static var nonExistingURL: URL {
      URL.temporaryDirectory.appending(component: "nonExisting")
   }


   @Test
   func `not layout url`() throws {
      let message =
         {
            #if os(macOS)
               "The given data was not valid JSON. Unexpected character '#' around line 1, column 1."
            #else
               "The given data was not valid JSON. "
            #endif
         }()
      #expect(throws: LayoutError.failedToDecode(message)) {
         try Layout.read(name: "base") {
            Data(PackageResources.notLayoutFile_txt)
         }
      }
   }


   @Test
   func `incorrectly formatted layout url`() throws {
      #expect(
         throws:
            LayoutError
            .failedToDecode(
               #"No value associated with key CodingKeys(stringValue: "outputStyle", intValue: nil) ("outputStyle"). "#
            )
      ) {
         try Layout.read(name: "base") {
            Data(PackageResources.incorrectlyFormattedLayout_json)
         }
      }
   }


   @Test
   func `non existing layout`() throws {
      #expect(throws: LayoutError.doesNotExist("nonExisting")) {
         try Layout.read(name: "nonExisting") {
            try Data(contentsOf: Self.nonExistingURL)
         }
      }
   }


   @Test
   func `read valid layout`() throws {
      let layout = try Layout.read(name: "validLayout") {
         Data(PackageResources.validLayout_json)
      }

      let expected = Layout(
         outputStyle: .columnar,
         countMode: .trailing,
         maxCount: 99,
         maxCountStyle: .init(fg: .magenta, styles: [.underline, .bold]),
         aZSort: true,
         executionMode: .parallel,
         sortOrder: [.clean, .repo],
         truncationMode: .tail,
         symbols: Symbols(
            added: "A",
            clean: "✓",
            copied: "C",
            deleted: "D",
            detached: "⍜",
            dirty: "*",
            ignored: "!",
            initialCommit: "I",
            locked: "L",
            modified: "M",
            noUpstream: "⇞",
            pull: "↓",
            push: "↑",
            renamed: "R",
            separator: " ",
            stashes: "#",
            submodule: .init(
               prefix: "<",
               commit: "C",
               modified: "M",
               untracked: "?",
               suffix: ">",
            ),
            typeChange: "T",
            truncator: "…",
            unmerged: "U",
            untracked: "?",
         ),
         components: [
            .cleanOrDirty(cleanFg: .green, cleanStyles: [.bold]),
            .modified(fg: .red),
            .added(fg: .ext(214)),
            .deleted(fg: .red),
            .renamed(fg: .red),
            .untracked(fg: .red),
            .separator(),
            .repo(width: 18),
            .separator(),
            .pull(fg: .blue),
            .push(fg: .yellow),
            .noUpstream(fg: .magenta),
            .head(width: 10, styles: [.bold]),
            .separator(),
            .stashes(styles: [.bold]),
         ]
      )

      expectMatch(expected, layout)
   }
}
