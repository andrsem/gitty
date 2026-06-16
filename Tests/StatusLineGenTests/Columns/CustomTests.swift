// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import SW40
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Custom Tests` {
   @Test(arguments: OutputStyle.allCases)
   func `custom with no output`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [.custom(command: "pwd", sortID: "pwdSort")]
         ),
         status: status(),
         custom: [("pwd", "")]
      )

      let expected = ("", "")

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `custom no width specified`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [.custom(command: "pwd", sortID: "pwdSort")]
         ),
         status: status(),
         custom: [("pwd", "~/Developer")]
      )

      let expected = ("~/Developer", "~cust:~/Developer")

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `custom truncated to width truncationMode: nil - global`(
      outputStyle: OutputStyle
   ) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [.custom(command: "pwd", sortID: "pwdSort", width: 5)]
         ),
         status: status(),
         custom: [("pwd", "~/Developer")]
      )

      let expected = ("~/De…", "~cust:~/Developer")

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `custom truncated to width truncationMode: head`(
      outputStyle: OutputStyle
   ) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [
               .custom(
                  command: "pwd",
                  sortID: "pwdSort",
                  width: 5,
                  truncationMode: .middle
               )
            ]
         ),
         status: status(),
         custom: [("pwd", "~/Developer")]
      )

      let expected = ("~/…er", "~cust:~/Developer")

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `custom truncated to width truncationMode: middle`(
      outputStyle: OutputStyle
   ) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [
               .custom(
                  command: "pwd",
                  sortID: "pwdSort",
                  width: 5,
                  truncationMode: .head
               )
            ]
         ),
         status: status(),
         custom: [("pwd", "~/Developer")]
      )

      let expected = ("…oper", "~cust:~/Developer")

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `custom expanded to width`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [.custom(command: "pwd", sortID: "pwdSort", width: 20)]
         ),
         status: status(),
         custom: [("pwd", "~/Developer")]
      )

      let sortID = "~cust:~/Developer"
      let expected =
         switch outputStyle {
         case .linear: ("~/Developer", sortID)
         case .columnar: ("~/Developer         ", sortID)
         }

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `custom width zero`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [.custom(command: "pwd", sortID: "pwdSort", width: 0)]
         ),
         status: status(),
         custom: [("pwd", "~/Developer")]
      )

      let expected = ("…", "~cust:~/Developer")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `custom with other components`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [.head(), .custom(command: "pwd", sortID: "pwdSort")]
         ),
         status: status(),
         custom: [("pwd", "~/Developer")]
      )

      let sortID = "~head:main~cust:~/Developer"
      let expected = ("main~/Developer", sortID)

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `custom sorted before other components`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [.custom("pwdSort")],
            components: [.head(), .custom(command: "pwd", sortID: "pwdSort")]
         ),
         status: status(),
         custom: [("pwd", "~/Developer")]
      )

      let sortID = "0Acust:~/Developer~head:main"
      let expected = ("main~/Developer", sortID)

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `custom sorted before other components ZA`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [.custom("pwdSort")],
            components: [.head(), .custom(command: "pwd", sortID: "pwdSort")]
         ),
         status: status(),
         custom: [("pwd", "~/Developer")]
      )

      let expected = ("main~/Developer", "0Acust:~/Developer~head:main")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `invert global AZ sort`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            aZSort: false,
            sortOrder: [.head, .custom("pwdSort")],
            components: [.head(), .custom(command: "pwd", sortID: "pwdSort")]
         ),
         status: status(),
         custom: [("pwd", "~/Developer")]
      )

      let expected = ("main~/Developer", "0Zhead:main1Zcust:~/Developer")
      expectMatch(expected, statusLine)
   }
}
