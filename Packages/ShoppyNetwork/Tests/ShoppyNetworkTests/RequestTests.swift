//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import Testing
@testable import ShoppyNetwork

struct RequestTests {
  @Test
  func example() throws {
    let request = ShoppyNetwork.Request(
      method: .get,
      host: "example.com",
      path: ["path", "to", "resource"],
      queryItems: [
        "key1": "foo",
        "key2": "bar"
      ]
    )

    let url = request.url

    // Since query is non-ordered, we test both cases
    let candidates: Set<URL?> = [
      URL(string: "https://example.com/path/to/resource?key1=foo&key2=bar"),
      URL(string: "https://example.com/path/to/resource?key2=bar&key1=foo")
    ]
    #expect(candidates.contains(url))
  }
}
