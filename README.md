# Minimal

<img src="App/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon_MacOS_512@2x.png" style="height: 100px"/>

## Overview
This is a template repository & project, which contains most of commonly-used components.
Each choice has strong reasoning about, and is described below.

## Tuist & SPM
### [tuist.io](https://tuist.io)
Tuist is an Xcode Project generation tool.

Initially, it was created to simply managing of multiple targets/projects, and it stays it's main purpose.

However, it's still very handy even in case of 1 target/project: it allows you to create human-readable Xcode project
& target configuration.
You can write easy-to-ready Swift code, attach comments with description "why this setting is needed", and you can
remove Tuist (replace with Xcode) at any time.

So, even if it's 'another 3rd-party dependency', it's a necessary evil.

### [Swift Package Manager](https://www.swift.org/documentation/package-manager/)
SPM is utilised to split app into submodules & targets. Why not Tuist?
Because I'm still not 100% sure about necessary of Tuist in each app, and if I decide to remove it at any time,
it will be much simpler to keep ready-to-use SPM targets instead of moving Tuist targets to SPM or managing Xcode targets.

## SwiftLint, SwiftFormat
There's no secret that code style is pretty important in any app, even if there's a single Engineer who develops it.
To not spend a lot of time for it, 2 tools - linter & formatter - were developed for this project.
Both are based on well-known [SwiftLint](https://github.com/realm/SwiftLint) and
[SwiftFormat](https://github.com/nicklockwood/SwiftFormat).

You can find more details in [README.md](Packages/Tools/README.md)

_TODO_
Since we can't reuse plugin in it's current form in multiple repos, it's ideal to rewrite it as a command line tool,
e. g. `mise` or `asdf` plugin.

## Dependency Injection
No doubt that testability is quite important, especially in large apps.
A simple & minimalistic approach is to use [Factory](https://github.com/hmlongco/Factory).
It's a well-maintained, compile-time safe solution, which fits >90% needs for _small-to-medimum+_-size apps.
Another alternatives considered:
1. `EnvironmentObject` - not runtime safe; can be used only inside Views.
2. `Lyft` [approach with closures](https://noahgilmore.com/blog/swift-dependency-injection/) - OK, but lacks built-in features.
3. `Swinject` and others - not runtime safe.
4. `Needle`
   - requires installation of generator binary
   - not-so-well-maintained
   - repo contains huge binary which takes an eternity to be downloaded
5. Manual constructor/function injection - a lot of unreadable boilerplate.

## Logger
There was a hard choice - to use raw Logger/OSLog, or use some wrapper over it.
I even prepared a document describing those two options for one of my previous projects.

The short answer - Logger without wrapper is a more preferred option, so here we are.

## Testability
Since Apple and Swift community introduced [Swift Testing](https://developer.apple.com/xcode/swift-testing/),
there's no need anymore in third-party testing lib (like Quick and Nimble).
That being said, this project uses Swift Testing only.

## Minimum iOS/MacOS Version, Swift version
Since it's a demo app, I've chosen default formula `(CURRENT_RELEASE_IOS_VERSION) - 1`.
So since now it's iOS 18 available, I'm using iOS 17 as minimum.

Also, because this project uses platform-independent components (SwiftUI, CoreLocation, etc) by default,
it's not so hard to support MacOS too.
However, if there's a strict need to e.g. support iOS 15 (so we can't use NavigationStack), we remove support for MacOS
in favour of UIKit-based navigation.

`Swift` is always set to latest stable version (`6.0` at the moment)

## Environments and Shielder
In most of cases, we need to support at least two environments - `Production` and `Staging` (or also called `Dev`).
Each environment has it's own Xcode scheme and configuration, defining AppName, AppIcon, bundleIdentifier.
Also, to quickly preview some functionality, sometimes it's useful to have mocked data & content: e. g. photo library,
user location, and so on. For this, there's a `Sandbox` environment present.

### AppIcon generation
Mostly for the demo purpose (but still), there's a nice way to use a single set of icons (for `Production`),
and generate `Staging` and `Sandbox` icons programmatically using SwiftUI.
Because we're using Tuist for project generation, we can use it as well for AppIcon generation. See [AppIcon+View.swift](Tuist/ProjectDescriptionHelpers/AppIcon/AppIcon+View.swift) 

### Shielder
Not less important, differrent environments usually have differrent API keys, Server endpoints, etc.
Usually this information is put inside `.xcconfig` files, and somehow is transferred to Swift using `Info.plist`.

This is at least not secure approach (as `Info.plist` is a plain-text-like file), and not compile-time-safe as well.
To fix this, I developed a `Shielder` - and SPM plugin, which generates Swift code based on values in `.env` file,
which is gitignored.

You can find more details in [README.md](Packages/Tools/README.md#Shielder)

## Extended Documentation
- [Adding new module](Docs/adding_new_module.md)
- [Maintenance](Docs/maintenance.md)

## Modules
- [Base](Packages/Base/README.md)
- [Features](Packages/Features/README.md)
- [Tools](Packages/Tools/README.md)

## Project-related services
- [Figma](https://www.figma.com/file/RSbywcYh0q7cByztXpK9jh/Minimal)
