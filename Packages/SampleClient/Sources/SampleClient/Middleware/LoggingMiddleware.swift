//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import HTTPTypes
import MinimalFoundation
import OpenAPIRuntime

// MARK: - LoggingMiddleware

struct LoggingMiddleware: ClientMiddleware {
  private let logger = Container.shared.logger.network()

  func intercept(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID: String,
    next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
  ) async throws -> (HTTPResponse, HTTPBody?) {
    let uuid = UUID().uuidString
    logger.info("Request \(uuid) \(operationID) - \(request.debugDescription)")
    Task(priority: .utility) {
      let curl = await LoggingHelpers.makeCurl(fromRequest: request, body: body, baseURL: baseURL)
      logger.debug("CURL of \(uuid):\n\(curl)")
    }
    do {
      let (response, body) = try await next(request, body, baseURL)
      logger.info("Response \(uuid) \(operationID) - \(response.debugDescription)")
      Task(priority: .utility) {
        let bodyString = await body?.string
        logger.debug("Body of \(uuid):\n\(bodyString ?? "none")")
      }
      return (response, body)
    } catch {
      logger.warning("Response \(uuid) \(operationID) failed with error: \(error)")
      throw error
    }
  }
}

// MARK: - LoggingHelpers

enum LoggingHelpers {
  static func makeCurl(fromRequest request: HTTPRequest, body: HTTPBody?, baseURL: URL) async -> String {
    var command = "curl -X '\(request.method.rawValue)' '\(baseURL.appending(path: request.path ?? ""))'"

    let headers = request.headerFields
      .map { header in
        "-H '\(header.name): \(header.value)'"
      }
      .joined(separator: " ")

    command += " " + headers

    if let body {
      let bodyString = await body.string
      command += " " + "-d '\(bodyString)'"
    }

    return command
  }
}

// MARK: - HTTPBody + string

extension HTTPBody {
  var string: String {
    get async {
      if let buffer = try? await ArraySlice(collecting: self, upTo: 2 * 1024 * 1024) {
        String(decoding: buffer, as: UTF8.self)
      } else {
        "<body is more then 2MB>"
      }
    }
  }
}
