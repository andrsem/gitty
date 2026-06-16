// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import Testing

@testable import gitty

@Suite
struct `Pratt Parser tests` {
   @Test(arguments: ["a", "   a   ", "a    ", "    a", "(a)", "((a))"])
   func `simple identifier parsing`(input: String) throws {
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.value("a")
      #expect(e == r)
   }


   @Test(arguments: ["a&b", "a& b", "a &b", " a & b "])
   func `AND operator parsing`(input: String) throws {
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.and([.value("a"), .value("b")])
      #expect(e == r)
   }


   @Test(arguments: ["a|b", "a| b", "a |b", " a | b ", "(a|b)"])
   func `OR operator parsing`(input: String) throws {
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.or([.value("a"), .value("b")])
      #expect(e == r)
   }


   @Test(arguments: ["a & b | c", "(a & b) | c"])
   func `AND has higher precedence than OR`(input: String) throws {
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.or([
         .and([.value("a"), .value("b")]),
         .value("c"),
      ])
      #expect(e == r)
   }


   @Test
   func `parentheses changing precedence for OR`() throws {
      let input = "(a | b) & c"
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.and([
         .or([.value("a"), .value("b")]),
         .value("c"),
      ])
      #expect(e == r)
   }


   @Test(arguments: ["!a", "! a"])
   func `NOT operator parsing`(input: String) throws {
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.not(.value("a"))
      #expect(e == r)
   }


   @Test(arguments: ["!a & b", "(!a) & b", "((!a) & b)"])
   func `NOT has higher precedence than AND`(input: String) throws {
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.and([.not(.value("a")), .value("b")])
      #expect(e == r)
   }



   @Test
   func `complex expression with all operators`() throws {
      let input = "!(a & b | c)"
      let r = try parseExpression(input, parseValue: \.self)
      let e =
         Expression
         .not(
            .or([
               .and([.value("a"), .value("b")]),
               .value("c"),
            ])
         )
      #expect(e == r)
   }


   @Test(arguments: ["a & b & c", "((a & b) & c)", "(a & b) & c"])
   func `multiple AND operations left associative`(input: String) throws {
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.and([.value("a"), .value("b"), .value("c")])
      #expect(e == r)
   }

   @Test(arguments: ["a | b | c", "((a | b) | c)", "(a | b) | c"])
   func `multiple OR operations left associative`(input: String) throws {
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.or([.value("a"), .value("b"), .value("c")])
      #expect(e == r)
   }

   @Test(arguments: ["", " ", "  ", "\n", "\t"])
   func `empty expression throws error`(input: String) throws {
      #expect(throws: ParseError.emptyExpression) {
         try parseExpression(input, parseValue: \.self)
      }
   }


   @Test(arguments: ["!!a", "! ! a"])
   func `nested NOT operators`(input: String) throws {
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.not(.not(.value("a")))
      #expect(e == r)
   }


   @Test
   func `mixed precedence with parentheses`() throws {
      let input = "a | b & (c | d)"
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.or([
         .value("a"),
         .and([
            .value("b"),
            .or([.value("c"), .value("d")]),
         ]),
      ])
      #expect(e == r)
   }


   @Test
   func `not closed parentheses`() throws {
      #expect(throws: ParseError.expectedClosingParen) {
         try parseExpression("(a", parseValue: \.self)
      }
   }


   @Test
   func `not opened parentheses`() throws {
      #expect(throws: ParseError.unexpectedToken(")")) {
         try parseExpression("a)", parseValue: \.self)
      }
   }


   @Test(arguments: ["|", "&"])
   func `prefix operators are rejected`(op: String) throws {
      #expect(throws: ParseError.unexpectedToken(op)) {
         try parseExpression("\(op)a", parseValue: \.self)
      }
   }


   @Test(arguments: ["|", "&"])
   func
      `suffix operators consume the symbol, then fail when parsing the missing right operand`(
         op: String
      ) throws
   {
      #expect(throws: ParseError.emptyExpression) {
         try parseExpression("a\(op)", parseValue: \.self)
      }
   }


   @Test(arguments: ["||", "&&"])
   func `consecutive operators`(input: String) throws {
      let token = String(input.dropFirst())
      #expect(throws: ParseError.unexpectedToken(token)) {
         try parseExpression(input, parseValue: \.self)
      }
   }


   @Test(arguments: ["a bc", "b  cd"])
   func `consecutive values are not supported`(input: String) throws {
      let token = String(
         input.dropFirst().trimmingPrefix(while: \.isWhitespace)
      )
      #expect(throws: ParseError.unexpectedToken(token)) {
         try parseExpression(input, parseValue: \.self)
      }
   }


   @Test
   func `multiple grouped terms with OR`() throws {
      let input = "a & b | c & d"
      let r = try parseExpression(input, parseValue: \.self)
      let e = Expression.or([
         .and([.value("a"), .value("b")]),
         .and([.value("c"), .value("d")]),
      ])
      #expect(e == r)
   }


   @Test
   func `empty parentheses throw error`() throws {
      #expect(throws: ParseError.unexpectedToken(")")) {
         try parseExpression("()", parseValue: \.self)
      }
   }


   @Test(arguments: ["a & (b| c", "(a & b", "((a)) & (b"])
   func `missing closing parenthesis throws error`(input: String) throws {
      #expect(throws: ParseError.expectedClosingParen) {
         try parseExpression(input, parseValue: \.self)
      }
   }


   @Test(arguments: ["a & )", "a | )", "a & (b|)", "a & (b&)"])
   func `operators missing right grouped operand throw unexpected token`(
      input: String
   ) throws {
      #expect(throws: ParseError.unexpectedToken(")")) {
         try parseExpression(input, parseValue: \.self)
      }
   }


   @Test
   func `NOT binds tighter than OR`() throws {
      let r = try parseExpression("!a | b", parseValue: \.self)
      let e = Expression.or([.not(.value("a")), .value("b")])
      #expect(e == r)
   }


   @Test
   func `bare identifiers may contain non operator punctuation`() throws {
      let r = try parseExpression("feature/foo-1.2", parseValue: \.self)
      let e = Expression.value("feature/foo-1.2")
      #expect(e == r)
   }


   @Test
   func `parseValue errors are propagated`() throws {
      #expect(throws: ParseError.unexpectedToken("bad")) {
         try parseExpression("good & bad") { raw in
            if raw == "bad" {
               throw ParseError.unexpectedToken(raw)
            }
            return raw
         }
      }
   }


   @Test
   func `evaluate returns value predicate result`() {
      #expect(evaluate(Expression.value("a"), contains: { $0 == "a" }))
      #expect(!evaluate(Expression.value("a"), contains: { $0 == "b" }))
   }


   @Test
   func `evaluate handles NOT expressions`() {
      #expect(!evaluate(Expression.not(.value("a")), contains: { $0 == "a" }))
      #expect(evaluate(Expression.not(.value("a")), contains: { $0 == "b" }))
   }


   @Test
   func `evaluate requires all AND expressions`() {
      let expr = Expression.and([.value("a"), .value("b"), .not(.value("c"))])
      #expect(evaluate(expr, contains: { ["a", "b"].contains($0) }))
      #expect(!evaluate(expr, contains: { ["a", "c"].contains($0) }))
   }


   @Test
   func `evaluate requires any OR expression`() {
      let expr = Expression.or([.value("a"), .and([.value("b"), .value("c")])])
      #expect(evaluate(expr, contains: { ["b", "c"].contains($0) }))
      #expect(!evaluate(expr, contains: { $0 == "b" }))
   }


   @Test
   func `evaluate short circuits AND`() {
      var checked: [String] = []
      let expr = Expression.and([.value("a"), .value("b")])

      let result = evaluate(expr) { value in
         checked.append(value)
         return false
      }

      #expect(!result)
      #expect(checked == ["a"])
   }


   @Test
   func `evaluate short circuits OR`() {
      var checked: [String] = []
      let expr = Expression.or([.value("a"), .value("b")])

      let result = evaluate(expr) { value in
         checked.append(value)
         return true
      }

      #expect(result)
      #expect(checked == ["a"])
   }
}
