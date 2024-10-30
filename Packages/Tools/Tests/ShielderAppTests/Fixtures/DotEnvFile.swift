//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

enum DotEnvFile {
  static let basic = """
  # staging

  # Comment 1
  my_serverurl=https://example.com
  my_api_key=Alzafoobar
  """

  static let basicTyped = """
  # staging

  # Comment 1
  my_server_url=https://example.com
  my_api_key=Alzafoobar
  """

  static let firstEmptyLine = """

  # staging

  # Comment 1
  """

  static let noHeader = """
  #

  # Comment 1
  """

  static let noValueForKeys = """
  my_server_url=
  my_api_key=
  """

  static let worstCaseFormatting = """

  #  staging#bad=name

    my_server#hash    =  https://example.com/a=b#123
  """
}
