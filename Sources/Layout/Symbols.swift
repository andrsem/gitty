// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package struct Symbols: Decodable, Equatable, Sendable {
   package init(
      added: String,
      clean: String,
      copied: String,
      deleted: String,
      detached: String,
      dirty: String,
      ignored: String,
      initialCommit: String,
      locked: String,
      modified: String,
      noUpstream: String,
      pull: String,
      push: String,
      renamed: String,
      separator: String,
      stashes: String,
      submodule: Submodule,
      typeChange: String,
      truncator: String,
      unmerged: String,
      untracked: String
   ) {
      self.added = added
      self.clean = clean
      self.copied = copied
      self.deleted = deleted
      self.detached = detached
      self.dirty = dirty
      self.ignored = ignored
      self.initialCommit = initialCommit
      self.locked = locked
      self.modified = modified
      self.noUpstream = noUpstream
      self.pull = pull
      self.push = push
      self.renamed = renamed
      self.separator = separator
      self.stashes = stashes
      self.submodule = submodule
      self.typeChange = typeChange
      self.truncator = truncator
      self.unmerged = unmerged
      self.untracked = untracked
   }


   package let added: String
   package let clean: String
   package let copied: String
   package let deleted: String
   package let detached: String
   package let dirty: String
   package let ignored: String
   package let initialCommit: String
   package let locked: String
   package let modified: String
   package let noUpstream: String
   package let pull: String
   package let push: String
   package let renamed: String
   package let separator: String
   package let stashes: String
   package let submodule: Submodule
   package let typeChange: String
   package let truncator: String
   package let unmerged: String
   package let untracked: String


   package struct Submodule: Decodable, Equatable, Sendable {
      package init(
         prefix: String,
         commit: String,
         modified: String,
         untracked: String,
         suffix: String
      ) {
         self.prefix = prefix
         self.commit = commit
         self.modified = modified
         self.untracked = untracked
         self.suffix = suffix
      }

      package let prefix: String
      package let commit: String
      package let modified: String
      package let untracked: String
      package let suffix: String
   }
}
