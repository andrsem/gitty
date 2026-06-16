// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import TTS

extension Collection where Element == String {
   var componentsDescription: Element {
      map { $0.styles(.bold) }.joined(separator: " ")
   }
}
