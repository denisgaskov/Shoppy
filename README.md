# Shoppy

<img src="App/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon_MacOS_512@2x.png" style="height: 100px"/>

## Overview
This is a repository for **Shoppy** iOS project.
Each choice has strong reasoning about, and is described below.

## SPM modularization
### [Swift Package Manager](https://www.swift.org/documentation/package-manager/)
SPM is utilised to split app into submodules & targets. Why not Tuist?
Because I'm still not 100% sure about necessary of Tuist for each app, and if I decide to remove it later,
it will be much simpler to keep ready-to-use SPM targets instead of refactoring Tuist projects to SPM or Xcode projects.

## Dependency Injection
No doubt that testability is quite important, especially in large apps.
A simple & minimalistic approach is to use [Factory](https://github.com/hmlongco/Factory).
It's a well-maintained, compile-time safe solution, which fits >90% needs for _small-to-medimum+_-size apps.
Another alternatives considered:
1. `EnvironmentObject` - not runtime safe; can be used only with SwiftUI.
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

`Swift` is always set to latest stable version (`6.0` at the moment)

## MVVM Architecture
Disclaimer: in my opinion, it's another topic for a large debate, which can be discussed later.
In this project I followed modern MV/MVVM approach without explicit subscriptions and without Combine.
It's a well-known and popular approach, based on this [thread](https://forums.developer.apple.com/forums/thread/699003).

## Extended Documentation
- [Adding new module](Docs/adding_new_module.md)
- [Maintenance](Docs/maintenance.md)

## Modules
- [Base](Packages/Base/README.md)
- [Features](Packages/Features/README.md)
