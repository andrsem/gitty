// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Testing

@testable import Status

@Suite(.tags(.status))
struct `XY tests` {
   @Test(arguments: ["", " ", "  ", "abc", "a b", "GG", "RG"])
   func `invalid XY`(raw: String) {
      #expect(XY(from: raw) == nil)
   }


   typealias XYPair = (raw: String, change: XY.Change)

   static let xyPairs: [XYPair] = [
      ("A", .added),
      ("D", .deleted),
      ("R", .renamed),
      ("M", .modified),
      ("U", .unmerged),
      ("T", .typeChange),
      ("C", .copied),
      (".", .unmodified),
   ]

   @Test(arguments: xyPairs, xyPairs)
   func `valid XY`(x: XYPair, y: XYPair) {
      let xyRaw = x.raw + y.raw
      let expectedXY = XY(index: x.change, workingTree: y.change)

      #expect(XY(from: xyRaw) == expectedXY)
   }


   @Test(arguments: xyPairs, xyPairs)
   func `xY contains change`(x: XYPair, y: XYPair) {
      let xyRaw = x.raw + y.raw
      let actual = XY(from: xyRaw)
      let expectedIndex = x.change
      let expectedWorkingTree = y.change

      #expect(actual?.contains(expectedIndex) == true)
      #expect(actual?.contains(expectedWorkingTree) == true)
   }
}
