//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ProjectDescription

public enum Scripts {
  public enum Target {
    public static let shielder = TargetScript.pre(
      script: """
      set -e

      # Sandbox | Staging | Production
      BUILD_ENVIRONMENT="$(cut -d ' ' -f 2 <<< "${CONFIGURATION}")"

      # Skip validation for Sandbox environment
      if [ "$BUILD_ENVIRONMENT" == "Sandbox" ]; then
        exit
      fi

      HEADER="$(head -n 1 .env)"
      FILE_ENVIRONMENT="$(echo "$HEADER" | cut -d ' ' -f 2)"

      if [ "$BUILD_ENVIRONMENT" != "$FILE_ENVIRONMENT" ]; then
        echo ".env:1: error: Activated environment is ${FILE_ENVIRONMENT}, \
      while building for ${BUILD_ENVIRONMENT}"
        exit -1
      fi
      """,
      name: "🛡️ Validate Shielder",
      basedOnDependencyAnalysis: false
    )
  }
}
