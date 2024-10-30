//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
struct Stringify: ExpressionMacro {
  static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in _: some MacroExpansionContext
  ) -> ExprSyntax {
    guard let argument = node.arguments.first?.expression else {
      fatalError("compiler bug: the macro does not have any arguments")
    }

    return "(\(argument), \(literal: argument.description))"
  }
}
