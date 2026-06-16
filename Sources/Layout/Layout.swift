// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

package import SW40

package struct Layout {
   package init(
      outputStyle: OutputStyle,
      countMode: CountMode,
      maxCount: Int,
      maxCountStyle: CountStyle,
      aZSort: Bool,
      executionMode: ExecutionMode,
      sortOrder: [SortComponent],
      truncationMode: TruncationMode,
      symbols: Symbols,
      components: [StatusComponent]
   ) {
      self.outputStyle = outputStyle
      self.countMode = countMode
      self.maxCount = maxCount
      self.maxCountStyle = maxCountStyle
      self.aZSort = aZSort
      self.executionMode = executionMode
      self.sortOrder = sortOrder
      self.truncationMode = truncationMode
      self.symbols = symbols
      self.components = components
   }


   package let outputStyle: OutputStyle
   package let countMode: CountMode
   package let maxCount: Int
   package let maxCountStyle: CountStyle
   package let aZSort: Bool
   package let executionMode: ExecutionMode
   package let sortOrder: [SortComponent]
   package let truncationMode: TruncationMode
   package let symbols: Symbols
   package let components: [StatusComponent]


   package typealias CustomCommand = (command: String, statusAsInput: Bool)
   package var customCommands: [CustomCommand] {
      components
         .reduce(into: []) {
            if case let .custom(command, _, statusAsIn, _, _, _, _, _) = $1 {
               $0.append((command, statusAsIn ?? false))
            }
         }
   }
}



extension Layout: Sendable {}
extension Layout: Decodable {}
extension Layout: Equatable {}



package enum ExecutionMode: String, Decodable, Sendable, Equatable {
   case parallel
   case statusThenCustom
   case customThenStatus
}



package enum CountMode: String, Decodable, Sendable, Equatable {
   case leading, trailing
}
