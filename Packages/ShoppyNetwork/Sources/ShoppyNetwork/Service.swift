//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import MinimalFoundation

extension Container {
  public var networkService: Factory<ShoppyNetwork.Service> {
    self { ShoppyNetwork.URLSessionService() }
      .cached
  }
}

// MARK: - Service

extension ShoppyNetwork {
  public protocol Service: Sendable {
    func execute<ResponseType: Decodable>(request: Request) async throws -> ResponseType
  }
}

// MARK: - URLSessionService

extension ShoppyNetwork {
  public struct URLSessionService: Service {
    private let urlSession = URLSession.shared
    private let logger = Container.shared.logger.network()

    public func execute<ResponseType: Decodable>(request: Request) async throws -> ResponseType {
      do {
        logger.debug("Starting request [\(request.path)]")
        let (data, urlResponse) = try await urlSession.data(for: request.urlRequest)
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
          throw ShoppyNetwork.Error.invalidResponseType
        }

        guard 200 ..< 300 ~= httpResponse.statusCode else {
          logger.error("Invalid statusCode: [\(request.path)] - \(httpResponse.statusCode)")
          throw Error.invalidStatusCode(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(ResponseType.self, from: data)
      } catch {
        logger.error("Network error: [\(request.path)] - \(error)")
        throw ShoppyNetwork.Error.unknown
      }
    }
  }
}
