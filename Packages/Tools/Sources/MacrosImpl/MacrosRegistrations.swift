//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosRegistrations: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    Stringify.self
  ]
}
