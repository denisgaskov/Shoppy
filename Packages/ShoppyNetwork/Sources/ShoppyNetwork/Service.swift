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
    func execute<ResponseType: Decodable>(request: Request) async throws(ShoppyNetwork.Error) -> ResponseType
  }
}

// MARK: - URLSessionService

extension ShoppyNetwork {
  public struct URLSessionService: Service {
    let urlSession = URLSession.shared

    public func execute<ResponseType: Decodable>(request: Request) async throws(ShoppyNetwork.Error) -> ResponseType {
      do {
        let (data, urlResponse) = try await urlSession.data(for: request.urlRequest)
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
          throw Error.invalidResponseType
        }

        guard 200 ..< 300 ~= httpResponse.statusCode else {
          throw Error.invalidStatusCode(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(ResponseType.self, from: data)
      } catch {
        throw .unknown
      }
    }
  }
}
