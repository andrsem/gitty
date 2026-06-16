// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import TTS

extension String {
   fileprivate var bold: Self { styles(.bold) }
   fileprivate var match: Self { fg(16).bg(136) }  // gold
}


let regexReferenceGuide =
   #"""
   Example usage of regex path matching for filtering the following list of paths:

   /Users/tony/2023/Nov/proj1/color
   /Users/tony/2024/November/proj2
   /Users/annna/2025/projCafé
   /Users/anna/2026/proj2/colour
   /Users/aa/2027/proj/new repo


   \#("Literal matching exact string".bold)
   Regex: proj1
   Match: /Users/tony/2023/Nov/\#("proj1".match)/color

   \#("(?i) - case insensitive".bold)
   Regex: (?i)nov
   Match: /Users/tony/2023/\#("Nov".match)/proj1/color
          /Users/tony/2024/\#("Nov".match)ember/proj2

   \#("| - boolean OR".bold)
   Regex: colour|November
   Match: /Users/tony/2024/\#("November".match)/proj2
          /Users/anna/2026/proj2/\#("colour".match)

   \#("^ - start of the line".bold)
   Regex: ^/Users/tony
   Match: \#("/Users/tony".match)/2023/Nov/proj1/color
          \#("/Users/tony".match)/2024/November/proj2

   \#("$ - end of the line".bold)
   Regex: 2$
   Match: /Users/tony/2024/November/proj\#("2".match)

   \#(#"\b - word boundary"#.bold)
   Regex: \bproj\b
   Match: /Users/aa/2027/\#("proj".match)/new repo

   \#(#"\d - digit (0-9)"#.bold)
   Regex: proj\d
   Match: /Users/tony/2023/Nov/\#("proj1".match)/color
          /Users/tony/2024/November/\#("proj2".match)
          /Users/anna/2026/\#("proj2".match)/colour

   \#(#"\s - whitespace"#.bold)
   Regex: \s
   Match: /Users/aa/2027/proj/new\#(" ".match)repo

   \#(". - any character except a line break".bold)
   Regex: Caf.
   Match: /Users/annna/2025/proj\#("Café".match)

   \#("* - zero or more preceding token".bold)
   Regex: an*a
   Match: /Users/\#("annna".match)/2025/projCafé
          /Users/\#("anna".match)/2026/proj2/colour
          /Users/\#("aa".match)/2027/proj/new repo

   \#("+ - one or more preceding token".bold)
   Regex: an+a
   Match: /Users/\#("annna".match)/2025/projCafé
          /Users/\#("anna".match)/2026/proj2/colour

   \#("? - zero or one preceding token (optional)".bold)
   Regex: colou?r
   Match: /Users/tony/2023/Nov/proj1/\#("color".match)
          /Users/anna/2026/proj2/\#("colour".match)

   Regex: Nov(ember)?
   Match: /Users/tony/2023/\#("Nov".match)/proj1/color
          /Users/tony/2024/\#("November".match)/proj2

   \#("{3} - exactly three preceding tokens".bold)
   Regex: n{3}
   Match: /Users/a\#("nnn".match)a/2025/projCafé

   \#("{2,4} - two to four preceding tokens".bold)
   Regex: n{2,4}
   Match: /Users/a\#("nnn".match)a/2025/projCafé
          /Users/a\#("nn".match)a/2026/proj2/colour

   \#("{3,} - three or more preceding tokens".bold)
   Regex: n{3,}
   Match: /Users/a\#("nnn".match)a/2025/projCafé

   \#("[abc] - any of a, b, or c".bold)
   Regex: 202[235]
   Match: /Users/tony/\#("2023".match)/Nov/proj1/color
          /Users/annna/\#("2025".match)/projCafé

   \#("[^abc] - none of a, b, or c".bold)
   Regex: 202[^23467]
   Match: /Users/annna/\#("2025".match)/projCafé

   \#("[a-z] - in range a through z".bold)
   Regex: 202[0-3]
   Match: /Users/tony/\#("2023".match)/Nov/proj1/color

   \#("[^a-z] - not in range a through z".bold)
   Regex: 202[^4-9]
   Match: /Users/tony/\#("2023".match)/Nov/proj1/color
   """#
