//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

#if DEBUG
  public func address(of object: AnyObject) -> String {
    "\(Unmanaged.passUnretained(object).toOpaque())"
  }
#endif
