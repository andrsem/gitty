// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import Testing

@testable import Shared

extension Tag {
   @Tag
   static var shared: Self
}

@Suite(.tags(.shared))
struct `Removed All Tests` {
   enum SomeError: Error { case boom }


   @Test
   func removedAll() {
      let emptyArr: [Int] = []
      let emptyStr = ""
      let arr = [1, 2, 3]
      let str = "abc"

      #expect(emptyArr.removedAll { $0 == 2 } == (carriedOn: [], removed: []))
      #expect(arr.removedAll { $0 == 2 } == (carriedOn: [1, 3], removed: [2]))

      let v1 = arr.removedAll { $0 == 5 }
      let exp1 = (carriedOn: [1, 2, 3], removed: [Int]())
      #expect(v1 == exp1)

      let v2 = arr.removedAll { $0 == 2 || $0 == 3 }
      let exp2 = (carriedOn: [1], removed: [2, 3])
      #expect(v2 == exp2)

      #expect(
         emptyStr.removedAll { $0 == "b" } == (carriedOn: "", removed: "")
      )
      #expect(str.removedAll { $0 == "b" } == (carriedOn: "ac", removed: "b"))
      #expect(str.removedAll { $0 == "g" } == (carriedOn: "abc", removed: ""))

      #expect(throws: SomeError.boom) {
         try str.removedAll { _ in throw SomeError.boom }
      }
   }
}
