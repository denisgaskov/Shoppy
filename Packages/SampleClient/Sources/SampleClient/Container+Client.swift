//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import MinimalFoundation
import OpenAPIURLSession

extension Container {
  public var apiClient: Factory<APIProtocol> {
    self { Client() }
  }
}

extension Client {
  fileprivate init() {
    let secrets = Container.shared.secrets()
    self.init(
      serverURL: secrets.myServerURL,
      transport: URLSessionTransport(),
      middlewares: [
        AuthMiddleware(),
        LoggingMiddleware()
      ]
    )
  }
}
