//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import MinimalFoundation
import Security

// MARK: - KeychainQueryExecutor

struct KeychainQueryExecutor: Sendable {
  private let logger = Container.shared.logger.keychain()

  func executeAdd(query: KeychainQuery.Add) async throws(AddError) {
    logger.debug("SecItemAdd with \(query.query)")
    let status = await Task { SecItemAdd(query.query, nil) }.value

    try handleStatus(status, action: "SecItemAdd") { status -> AddError in
      switch status {
        case errSecDuplicateItem: .itemAlreadyExists
        default: .unknown
      }
    }
  }

  func executeRead(query: KeychainQuery.Read) async throws(ReadError) -> Data {
    logger.debug("SecItemCopyMatching with \(query.query)")

    let (status, data) = await Task {
      var dataTypeRef: CFTypeRef?
      let status = SecItemCopyMatching(query.query, &dataTypeRef)
      return (status, dataTypeRef as? Data)
    }.value

    try handleStatus(status, action: "SecItemCopyMatching") { status -> ReadError in
      switch status {
        case errSecItemNotFound: .notFound
        default: .unknown
      }
    }

    if let data {
      return data
    }

    logger.error("SecItemCopyMatching returned non-Data type, or nil")
    throw .unexpectedReturnType
  }

  func executeUpdate(query: KeychainQuery.Update) async throws(UpdateError) {
    logger.debug("SecItemUpdate with \(query.query), changing \(query.updateQuery)")
    let status = await Task { SecItemUpdate(query.query, query.updateQuery) }.value

    try handleStatus(status, action: "SecItemUpdate") { status -> UpdateError in
      switch status {
        case errSecItemNotFound: .notFound
        default: .unknown
      }
    }
  }

  func executeDelete(query: KeychainQuery.Delete) async throws(DeleteError) {
    logger.debug("SecItemDelete with \(query.query)")
    let status = await Task { SecItemDelete(query.query) }.value

    try handleStatus(status, action: "SecItemDelete") { status -> DeleteError in
      switch status {
        case errSecItemNotFound: .notFound
        default: .unknown
      }
    }
  }

  private func handleStatus<ErrorType>(
    _ status: OSStatus,
    action: String,
    errorHandler: (OSStatus) -> ErrorType
  ) throws(ErrorType) {
    if status != errSecSuccess {
      let message = SecCopyErrorMessageString(status, nil)
      let handledError = errorHandler(status)
      logger.error("\(action, privacy: .public): error (\(status)) \(handledError): \(message)")
      throw handledError
    }

    logger.notice("\(action) request succeeded")
  }
}

// MARK: - Errors

extension KeychainQueryExecutor {
  enum AddError: Error {
    case itemAlreadyExists
    case unknown
  }

  enum ReadError: Error {
    case notFound
    case unexpectedReturnType
    case unknown
  }

  enum UpdateError: Error {
    case notFound
    case unknown
  }

  enum DeleteError: Error {
    case notFound
    case unknown
  }
}
