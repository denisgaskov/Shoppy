//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import HTTPTypes
import OpenAPIRuntime

// MARK: - AuthMiddleware

struct AuthMiddleware: ClientMiddleware {
  func intercept(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID _: String,
    next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
  ) async throws -> (HTTPResponse, HTTPBody?) {
    var request = request
    // TODO: Pass real token
    let header = HTTPField(name: .authorization, value: "Bearer MyToken")
    request.headerFields.append(header)
    return try await next(request, body, baseURL)
  }
}
