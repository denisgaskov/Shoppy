//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

public enum RunOnce {
  public static func run() {
    AppIcon.Generator.generate()
    print("AppIcons generated")
  }
}
