// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import List

extension Tags {
   var tagAgreementUC: String { self.count == 1 ? "Tag" : "Tags" }
   var tagAgreementLC: String { tagAgreementUC.lowercased() }
}
