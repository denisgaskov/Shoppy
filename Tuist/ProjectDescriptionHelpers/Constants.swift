//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import ProjectDescription

// MARK: - Constants

public struct Constants: Sendable {
  public let iOSVersion = "17.0"
  public let macOSVersion = "14.0"
  public let appName = "Minimal"
  public let appMarketingVersion = "1.0.0"

  public let testPlan: Path = "App/Support/AppTestPlan.xctestplan"
}

public let consts = Constants()
