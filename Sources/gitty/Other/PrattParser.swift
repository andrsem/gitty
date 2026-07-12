// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT


func parseExpression<Value>(
   _ input: String,
   parseValue: @escaping (String) throws -> Value,
) throws -> Expression<Value> {
   var parser = PrattParser(input, parseValue: parseValue)
   return try parser.parse()
}



func evaluate<Value>(
   _ expression: Expression<Value>,
   contains: (Value) throws -> Bool,
) rethrows -> Bool {
   switch expression {
   case let .value(v): try contains(v)
   case let .not(inner): try !evaluate(inner, contains: contains)
   case let .and(exp):
      try exp.allSatisfy { try evaluate($0, contains: contains) }
   case let .or(exp): try exp.contains { try evaluate($0, contains: contains) }
   }
}



indirect enum Expression<Value: Equatable>: Equatable {
   case value(Value)
   case not(Self)
   case and([Self])
   case or([Self])


   /// Flattens nested operators (e.g., `.or([A, B], C)` → `.or([A, B, C])`)
   fileprivate static func combine(
      _ lhs: Self,
      with op: Token,
      _ rhs: Self,
   ) -> Self {
      switch op {
      case .or: .or(lhs.flattenedAsOr + rhs.flattenedAsOr)
      case .and: .and(lhs.flattenedAsAnd + rhs.flattenedAsAnd)
      default: lhs
      }
   }


   private var flattenedAsOr: [Self] {
      guard case let .or(values) = self else { return [self] }
      return values
   }


   private var flattenedAsAnd: [Self] {
      guard case let .and(values) = self else { return [self] }
      return values
   }
}



enum ParseError: Error, Equatable, CustomStringConvertible {
   case emptyExpression
   case unexpectedToken(String)
   case expectedClosingParen

   var description: String {
      switch self {
      case .emptyExpression: "Expression is empty."
      case let .unexpectedToken(token): "Unexpected token: '\(token)'"
      case .expectedClosingParen: "Expected '\(Character.closeParen)'."
      }
   }
}



extension Character {
   static var or: Self { "|" }
   static var and: Self { "&" }
   static var not: Self { "!" }
   static var openParen: Self { "(" }
   static var closeParen: Self { ")" }
}



private enum Precedence {
   static let or = 10
   static let and = 20
   static let not = 30
}



private enum Token: Equatable, CustomStringConvertible {
   case identifier(String)
   case or, and, not, openParen, closeParen, eof


   var description: String {
      switch self {
      case let .identifier(string): string
      case .or: String(.or)
      case .and: String(.and)
      case .not: String(.not)
      case .openParen: String(.openParen)
      case .closeParen: String(.closeParen)
      case .eof: "eof"
      }
   }


   var bindingPower: (left: Int, right: Int)? {
      switch self {
      case .or: (Precedence.or, Precedence.or + 1)
      case .and: (Precedence.and, Precedence.and + 1)
      default: nil
      }
   }
}



private struct PrattParser<Value: Equatable> {
   private let tokens: [Token]
   private let parseValue: (String) throws -> Value
   private var index: Int = 0


   private var current: Token {
      guard index < tokens.count else { return .eof }
      return tokens[index]
   }


   init(
      _ input: String,
      parseValue: @escaping (String) throws -> Value,
   ) {
      self.tokens = tokenize(input)
      self.parseValue = parseValue
   }


   mutating func parse() throws -> Expression<Value> {
      guard current != .eof else { throw ParseError.emptyExpression }
      let expression = try parseExpression(minBindingPower: 0)
      guard current == .eof else {
         throw ParseError.unexpectedToken(current.description)
      }

      return expression
   }


   private mutating func advance() { index += 1 }


   private mutating func parseExpression(
      minBindingPower: Int
   ) throws -> Expression<Value> {
      var left = try parsePrefix()

      while let binding = current.bindingPower, binding.left >= minBindingPower
      {
         let op = current
         advance()
         let right = try parseExpression(minBindingPower: binding.right)
         left = Expression.combine(left, with: op, right)
      }

      return left
   }


   private mutating func parsePrefix() throws -> Expression<Value> {
      switch current {
      case .not:
         advance()
         return .not(try parseExpression(minBindingPower: Precedence.not))

      case .openParen:
         advance()
         let inner = try parseExpression(minBindingPower: 0)
         guard current == .closeParen else {
            throw ParseError.expectedClosingParen
         }
         advance()
         return inner

      case .identifier(let raw):
         advance()
         return .value(try parseValue(raw))

      case .eof:
         throw ParseError.emptyExpression

      case .or, .and, .closeParen:
         throw ParseError.unexpectedToken(current.description)
      }
   }
}



private func tokenize(_ input: String) -> [Token] {
   var tokens: [Token] = []
   var identifier = ""

   func flush() {
      guard !identifier.isEmpty else { return }
      tokens.append(.identifier(identifier))
      identifier.removeAll()
   }

   for char in input {
      switch char {
      case _ where char.isWhitespace:
         flush()
         break

      case .or, .and, .not, .openParen, .closeParen:
         flush()
         switch char {
         case .or: tokens.append(.or)
         case .and: tokens.append(.and)
         case .not: tokens.append(.not)
         case .openParen: tokens.append(.openParen)
         case .closeParen: tokens.append(.closeParen)
         default: break
         }

      default: identifier.append(char)
      }
   }

   flush()
   return tokens + [.eof]
}
