// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Foundation
import Testing

@testable import List

@Suite(.tags(.list))
struct `List read write tests` {
   static let emptyList = List()
   static let filledList = [Repo("~/Dev", [])]
   static let listWithDups = [Repo("~/Dev", []), Repo("~/Dev/", ["a"])]

   let readFromData = { data, isPathValid in
      try List.read {
         data
      } isRepoValid: { _ in
         isPathValid
      }
   }


   @Test
   func `dirty List from invalid data`() throws {
      let message = {
         #if os(macOS)
            "The given data was not valid JSON. Unexpected end of file"
         #else
            "The given data was not valid JSON. "
         #endif
      }()
      #expect(throws: ListError.unableToRead(message)) {
         try readFromData(Data(), true)
      }
   }


   @Test
   func `dirty List from invalid data2`() throws {
      let message = {
         #if os(macOS)
            "The given data was not valid JSON. Unexpected character 'a' around line 1, column 1."
         #else
            "The given data was not valid JSON. "
         #endif
      }()
      #expect(throws: ListError.unableToRead(message)) {
         try readFromData("abc".data(using: .utf8)!, true)
      }
   }


   @Test
   func `dirty List from valid data`() throws {
      let emptyListData = try JSONEncoder().encode(Self.emptyList)
      let validEmptyList = try readFromData(emptyListData, true)
      #expect(Self.emptyList == validEmptyList)

      let filledListData = try JSONEncoder().encode(Self.filledList)
      let validFilledList = try readFromData(filledListData, true)
      #expect(Self.filledList == validFilledList)

      let listWithTags = [Repo("~/Dev", []), Repo("~/abc", ["abc"])]
      let taggedListData = try JSONEncoder().encode(listWithTags)
      let validTaggedList = try readFromData(taggedListData, true)
      #expect(listWithTags == validTaggedList)

      let listWithDupsData = try JSONEncoder().encode(Self.listWithDups)
      let listFromDupData = try readFromData(listWithDupsData, true)
      #expect(Self.filledList == listFromDupData)
   }


   @Test
   func `list with special characters and unicode`() throws {
      let unicodeList = [Repo("~/🚀-dev", ["⭐", "🔥"])]
      let encoded = try JSONEncoder().encode(unicodeList)
      let decoded = try readFromData(encoded, true)
      #expect(unicodeList == decoded)
   }


   @Test
   func `list with empty path and name`() throws {
      let emptyRepoList = [Repo("", [])]
      let encoded = try JSONEncoder().encode(emptyRepoList)
      let decoded = try readFromData(encoded, true)
      #expect(emptyRepoList == decoded)
   }


   enum SaveError: Error { case failedToSave }
   enum SomeOtherError: Error { case someError }
   enum UnknownUnknownError: Error { case unknown }
   static let errors: [any Error] = [
      SaveError.failedToSave,
      SomeOtherError.someError,
      UnknownUnknownError.unknown,
   ]


   @Test(arguments: errors)
   func `failed saving list`(error: any Error) throws {
      #expect(throws: ListError.unableToSave) {
         try List.write(Self.emptyList) { _ in throw error }
      }
   }


   @Test(arguments: [emptyList, filledList])
   func `successful saving list`(repos: List) throws {
      #expect(throws: Never.self) { try List.write(repos) { _ in } }
   }
}
