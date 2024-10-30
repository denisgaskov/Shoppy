//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

// MARK: - Request

extension ShoppyNetwork {
  /// Type, which represents Network Request.
  /// For simpicity, it supports HTTP(S) protocol only.
  public struct Request {
    /// The HTTP Method, used for request, e. g. 'GET'.
    public let method: HTTPMethod
    /// The host name, used for request, **without** path components and trailing slash.
    /// ## Example
    /// ### Valid formats
    /// - example.com
    /// - sub.example.com
    /// - www.example.com
    ///
    /// ### Invalid formats
    /// - example.com/
    /// - https://example.com
    public let host: String
    /// The path components, used for request.
    /// All component will be joined using `/`.
    public let path: [String]
    /// Query items, appended after path.
    public let queryItems: [String: String]

    public init(method: HTTPMethod, host: String, path: [String], queryItems: [String: String]) {
      self.method = method
      self.host = host
      self.path = path
      self.queryItems = queryItems
    }
  }
}

// MARK: - HTTPMethod

extension ShoppyNetwork.Request {
  public enum HTTPMethod: String {
    case get = "GET"
  }
}

// MARK: - Request + URL

extension ShoppyNetwork.Request {
  var url: URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = host

    if !path.isEmpty {
      components.path = "/" + path.joined(separator: "/")
    }

    if !queryItems.isEmpty {
      components.queryItems = queryItems.map {
        URLQueryItem(name: $0.key, value: $0.value)
      }
    }

    // It's ok to force-unwrap, cause it's guaranteed that URL is properly constructed as it contains scheme and host.
    // swiftlint:disable:next force_unwrapping
    return components.url!
  }

  var urlRequest: URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    return request
  }
}
