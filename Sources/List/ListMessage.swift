// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

package enum ListMessage: Equatable {
   case added([Repo])
   case tagsAdded(Tags, excluded: Tags, repos: [Repo])
   case tagsUpdated(old: String, new: String, repos: [Repo])
   case tagsNotUpdated(old: String, new: String)
   case tagsRemoved(Tags, excluded: Tags, repos: [Repo])
   case noReposWithPath
   case noOldNewForUpdate
   case removed([Repo])
}
