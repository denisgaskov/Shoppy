# Tools
This package consists of common tools and plugins, like `Linter`, `Formatter` and `Shielder`.

Under the hood, both `Linter` and `Formatter` use **both** 
[SwiftLint](https://github.com/realm/SwiftLint) and [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)

### Linter and Formatter Motivation

#### Why not to use official plugins from SwiftLint and SwiftFormat?
Because it implies that you need to clone whole `SwiftLint` and `SwiftFormat` repos, which are ~500mb each.
In case of `SwiftFormat` we even need to build it from source code.

#### Why not to use binaries from HomeBrew/MacPorts/Mint/etc installation?
Because it's just one more dependency, which needs to be installed on every Developer PC, and on CI as well.
At the same time, Swift Package Manager fits our needs of dependency resolution.

## Linter
Supports both Swift Package Plugin and Xcode Build Tool Plugin.
It should be applied to only one (Root) SPM target or Xcode target, because it lints everything in this repo.
It's implemented as a build tool plugin, and is executed automatically at each build of an SPM/Xcode target.

## Formatter
Supports only Xcode Command Tool Plugin.

It's intentionally implemented as a *command* SPM plugin, because otherwise you can lose undo/redo history.
That means, it should be executed manually on Xcode project.

## Shielder
Inspired by https://nshipster.com/secrets/ and https://github.com/vdka/SecretsManager

Key differences:
  - Env integrity compile time check
  - Env selection (e. g. Staging/Production) compile time check
  - Compile time type validation (currently only URL)
  - Security improvements:
    - More secure algorithm (ChaChaPoly instead of XOR)
    - Encoded secrets & key are stored via [UInt8] array as well.
      - TLDR: strings can be extracted from IPA, see NSHipster article for more details

How to use:
1. Create `.env` file in project root directory with your secret keys, putting env name in header for compile-time validation, e. g.:
```sh
# Staging

FIREBASE_KEY=AAAAAAAAAABBBBBBBBBBCCCCCCCCCC
# comments are supported too
STRIPE_KEY=AAAAAAAAAABBBBBBBBBBCCCCCCCCCC
```
2. Create a file `.env.lock` near `.env`, which contains SHA256 values of each `.env` file. You may define an access modifier for generated code too (it's internal by default):
```sh
shielder_access_modifier=public
Staging=xxxxxxxxxxxx
Production=yyyyyyyyyy
```
Tip: you may run a plugin once, and copy-paste given SHA from error message into `.env.lock`.

3. Add a build tool plugin `Shielder` to the list of plugins for Xcode target or SPM target.
4. Add more environments, labeling each with comment in header:
```sh
# Production

FIREBASE_KEY=XXXXXXXXXXYYYYYYYYYYZZZZZZZZZZ
# comments are supported too
STRIPE_KEY=XXXXXXXXXXYYYYYYYYYYZZZZZZZZZZ
```
5. For compile-time env selection validation, add this script to "Build Scripts" in Xcode (modifying your values):
```sh
set -e

# Sandbox | Staging | Production
BUILD_ENVIRONMENT="$(cut -d ' ' -f 2 <<< "${CONFIGURATION}")"

# Skip validation for Sandbox environment (e. g. if you frequently switch from Sandbox to Staging)
if [ "$BUILD_ENVIRONMENT" == "Sandbox" ]; then
  exit
fi

HEADER="$(head -n 1 .env)"
FILE_ENVIRONMENT="$(echo "$HEADER" | cut -d ' ' -f 2)"

if [ "$BUILD_ENVIRONMENT" != "$FILE_ENVIRONMENT" ]; then
  echo ".env:1: error: Activated environment is ${FILE_ENVIRONMENT}, while building for ${BUILD_ENVIRONMENT}"
  exit -1
fi
```
This ensures that you don't accidently build a `Production` scheme with `Staging` keys.