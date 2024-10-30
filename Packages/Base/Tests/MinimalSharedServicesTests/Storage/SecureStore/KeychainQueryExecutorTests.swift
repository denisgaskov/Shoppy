//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import MinimalFoundation
import Testing
@testable import MinimalSharedServices

// MARK: - KeychainQueryExecutorTests

@Suite(.tags(.keychain), .serialized)
struct KeychainQueryExecutorTests {
  let executor = KeychainQueryExecutor()
  let username = "foo@bar.com"
  let dataAdd = Data("secretpassword".utf8)
  let dataUpdate = Data("newsecretpassword".utf8)

  let queryAdd: KeychainQuery.Add
  let queryRead: KeychainQuery.Read
  let queryUpdate: KeychainQuery.Update
  let queryDelete: KeychainQuery.Delete

  init() async throws {
    queryAdd = KeychainQuery.Credential.Add(account: username, kind: .password, data: dataAdd)
    queryRead = KeychainQuery.Credential.Read(account: username, kind: .password)
    queryUpdate = KeychainQuery.Credential.Update(account: username, kind: .password, data: dataUpdate)
    queryDelete = KeychainQuery.Credential.Delete(account: username, kind: .password)

    do {
      try await executor.executeDelete(query: queryDelete)
    } catch {
      if error != .notFound {
        throw error
      }
    }
  }

  @Test
  func addRead() async throws {
    try await executor.executeAdd(query: queryAdd)
    let data = try await executor.executeRead(query: queryRead)
    #expect(data == dataAdd)
  }

  @Test
  func addUpdateRead() async throws {
    try await executor.executeAdd(query: queryAdd)
    try await executor.executeUpdate(query: queryUpdate)
    let data = try await executor.executeRead(query: queryRead)
    #expect(data == dataUpdate)
  }

  @Test
  func addDelete() async throws {
    try await executor.executeAdd(query: queryAdd)
    try await executor.executeDelete(query: queryDelete)
    await #expect(throws: KeychainQueryExecutor.ReadError.notFound) {
      try await executor.executeRead(query: queryRead)
    }
  }

  // MARK: Throwable

  @Test
  func read() async {
    await #expect(throws: KeychainQueryExecutor.ReadError.notFound) {
      try await executor.executeRead(query: queryRead)
    }
  }

  @Test
  func update() async {
    await #expect(throws: KeychainQueryExecutor.UpdateError.notFound) {
      try await executor.executeUpdate(query: queryUpdate)
    }
  }

  @Test
  func delete() async {
    await #expect(throws: KeychainQueryExecutor.DeleteError.notFound) {
      try await executor.executeDelete(query: queryDelete)
    }
  }

  @Test
  func addAdd() async throws {
    try await executor.executeAdd(query: queryAdd)
    await #expect(throws: KeychainQueryExecutor.AddError.itemAlreadyExists) {
      try await executor.executeAdd(query: queryAdd)
    }
  }

  @Test
  func addUpgrade() async throws {
    try await executor.executeAdd(query: queryAdd)
    let queryTrue = try #require(KeychainQuery.Credential.UpdateWithUserPresence(
      account: username,
      kind: .password,
      requireUserPresence: true
    ))
    try await executor.executeUpdate(query: queryTrue)

    let queryFalse = try #require(KeychainQuery.Credential.UpdateWithUserPresence(
      account: username,
      kind: .password,
      requireUserPresence: false
    ))
    try await executor.executeUpdate(query: queryFalse)
  }

  @Test(arguments: [kSecReturnRef, kSecReturnAttributes] as [String])
  func readNonData(type: String) async throws {
    try await executor.executeAdd(query: queryAdd)
    await #expect(throws: KeychainQueryExecutor.ReadError.unexpectedReturnType) {
      let query = InvalidReadQuery(
        username: username,
        returnType: type,
        matchLimit: kSecMatchLimitOne as String
      )
      _ = try await executor.executeRead(query: query)
    }
  }

  @Test
  func readMatchLimitAll() async throws {
    try await executor.executeAdd(query: queryAdd)
    await #expect(throws: KeychainQueryExecutor.ReadError.unknown) {
      let query = InvalidReadQuery(
        username: username,
        returnType: kSecReturnData as String,
        matchLimit: kSecMatchLimitAll as String
      )
      _ = try await executor.executeRead(query: query)
    }
  }
}

// MARK: KeychainQueryExecutorTests.InvalidReadQuery

extension KeychainQueryExecutorTests {
  struct InvalidReadQuery: KeychainQuery.Read {
    let username: String
    let returnType: String
    let matchLimit: String

    var query: CFDictionary {
      [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: username,
        kSecAttrService: "com.apple.dt.xctest.tool.Password",
        returnType: kCFBooleanTrue as Any,
        kSecMatchLimit: matchLimit
      ] as CFDictionary
    }
  }
}
