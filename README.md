# KeyValueCoding

[![Swift 5.10, 5.9, 5.8, 5.7](https://img.shields.io/badge/Swift-5.10%20|%205.9%20|%205.8%20|%205.7-f48041.svg?style=flat&logo=swift)](https://developer.apple.com/swift)
![Platforms: iOS, macOS, tvOS, visionOS, watchOS](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20visionOS%20|%20watchOS%20-blue.svg?style=flat&logo=apple)
[![Swift Package Manager: compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg?style=flat&logo=apple)](https://swift.org/package-manager/)
[![Build](https://github.com/ikhvorost/KeyValueCoding/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/ikhvorost/KeyValueCoding/actions/workflows/swift.yml)
[![Codecov](https://codecov.io/gh/ikhvorost/KeyValueCoding/branch/main/graph/badge.svg?token=26NymxLQyB)](https://codecov.io/gh/ikhvorost/KeyValueCoding)
[![Swift Doc Coverage](https://img.shields.io/badge/Swift%20Doc%20Coverage-100%25-f39f37?logo=google-docs&logoColor=white)](https://github.com/ikhvorost/swift-doc-coverage)

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate/?hosted_button_id=TSPDD3ZAAH24C)

`KeyValueCoding` provides a mechanism by which you can access the properties of pure Swift `struct` or `class` instances indirectly by a string key or a key path.

- [Getting Started](#getting-started)
  - [Basics](#basics)
  - [Relationship](#relationship)
  - [Class Inheritance](#class-inheritance)
  - [Protocols](#protocols)
  - [Advanced functions](#advanced-functions)
- [Methods](#methods)
  - [metadata](#metadata)
  - [[key]](#key)
  - [[keyPath]](#keypath)
- [API](#api)
  - [swift_metadata](#swift_metadata)
  - [swift_value](#swift_value)
  - [swift_setValue](#swift_setvalue)
- [Installation](#installation)
- [License](#license)

## Getting Started

## Basics

The basic approach of `KeyValueCoding` protocol for accessing an instance’s properties values is subscripting by string key or a key path. In order to make your types key-value coding compliant just adopt them from this protocol, for instance:

``` swift
import KeyValueCoding

struct Resolution: KeyValueCoding {
  let width: Int
  let height: Int
}

var resolution = Resolution(width: 640, height: 480)

resolution["width"] = 1920
resolution["height"] = 1080

print(resolution) // Prints: Resolution(width: 1920, height: 1080)
```

> NOTE: An instance variable must be declared as `var`, otherwise you'll have the following error: `Cannot use mutating getter on immutable value`.

The same works with the key paths as well:

``` swift
resolution[\Resolution.width] = 2560
resolution[\Resolution.height] = 1440

print(resolution) // Prints: Resolution(width: 2560, height: 1440)
```

You can also read properties values in the same way:

``` swift
if let width: Int = resolution[\Resolution.width], let height: Int = resolution[\Resolution.height] {
  print("\(width)x\(height)") // Prints: 2560x1440
}
```

The following properties can be accessible for classes and structs in a consistent manner including:

- Constant `let` and variable `var` properties.
- `lazy`, `@objc` and optional properties.
- Properties with any access level: `public`, `internal`, `private` etc.
- Properties of any type: `enum`, `struct`, `class`, tuple etc.
- Relationship properties by a string key or a key path.

But there are some **limitations**:

- Computed properties are not addressable.
- The `willSet` and `didSet` observers aren’t being called on changing values.
- `weak`, `unowned` and the property wrappers are not supported.

### Relationship

`KeyValueCoding` can access to relationship properties by a string key ("relationship.property") or a key path, for example:

``` swift
import KeyValueCoding

struct Resolution {
  let width: Int
  let height: Int
}

class VideoMode: KeyValueCoding {
  let name: String
  let resolution: Resolution
  
  init(name: String, resolution: Resolution) {
    self.name = name
    self.resolution = resolution
  }
}

var videoMode = VideoMode(name: "HD", resolution: Resolution(width: 1920, height: 1080))
print("\(videoMode.name) - \(videoMode.resolution.width)x\(videoMode.resolution.height)")
// Prints: HD - 1920x1080

videoMode[\VideoMode.name] = "4K"
videoMode[\VideoMode.resolution.width] = 3840
videoMode[\VideoMode.resolution.height] = 2160
print("\(videoMode.name) - \(videoMode.resolution.width)x\(videoMode.resolution.height)")
// Prints: 4K - 3840x2160
```

> NOTE: Your parent instance can access to its children's properties without conforming the children to `KeyValueCoding` protocol.

### Class Inheritance

Properties from inherited classes are also accessible by `KeyValueCoding` protocol:

```swift
import KeyValueCoding

class Mode {
  let name: String
  
  init(name: String) {
    self.name = name
  }
}

class VideoMode: Mode, KeyValueCoding {
  let frameRate: Int
  
  init(name: String, frameRate: Int) {
    self.frameRate = frameRate
    super.init(name: name)
  }
}

var videoMode = VideoMode(name: "HD", frameRate: 30)
print("\(videoMode.name) - \(videoMode.frameRate)fps")
// Prints: HD - 30fps

videoMode[\VideoMode.name] = "4K"
videoMode[\VideoMode.frameRate] = 25
print("\(videoMode.name) - \(videoMode.frameRate)fps")
// Prints: 4K - 25fps
```

### Protocols

You can inherit any protocol from `KeyValueCoding` and then all instances of this protocol will be to accessible to read and write their properties:

``` swift
import KeyValueCoding

protocol Size: KeyValueCoding {
  var width: Int { get }
  var height: Int { get }
}

struct Resolution: Size {
  let width: Int
  let height: Int
}

var resolution: Size = Resolution(width: 1920, height: 1080)
print(resolution)
// Prints: Resolution(width: 1920, height: 1080)

resolution[\Resolution.width] = 3840
resolution[\Resolution.height] = 2160

if let width: Int = resolution[\Resolution.width], let height: Int = resolution[\Resolution.height] {
  print("\(width)x\(height)")
  // Prints: 3840x2160
}
```

### Advanced functions

In additional you can use pure API functions for getting and setting values of an instance's properties **without adopting** `KeyValueCoding` protocol at all:

``` swift
import KeyValueCoding

struct Resolution {
  let width: Int
  let height: Int
}

var resolution = Resolution(width: 1920, height: 1080)
print(resolution)
// Prints: Resolution(width: 1920, height: 1080)

swift_setValue(3840, to: &resolution, keyPath: \Resolution.width)
swift_setValue(2160, to: &resolution, keyPath: \Resolution.height)

if let width = swift_value(of: &resolution, keyPath: \Resolution.width) as? Int,
    let height = swift_value(of: &resolution, keyPath: \Resolution.height) as? Int
{
  print("\(width)x\(height)")
  // Prints: 3840x2160
}
```

## Methods

Swift instances of `struct` or `class` that adopt `KeyValueCoding` protocol are key-value coding compliant for their properties and they are addressable via essential subscriptions `[key]` and `[keyPath]`.


### metadata

Returns the metadata of the instance which includes its type, kind, size and a list of accessible properties:

```swift
import KeyValueCoding 

struct Resolution: KeyValueCoding {
  let width: Int
  let height: Int
}

let resolution = Resolution(width: 1920, height: 1080)
print(resolution.metadata)
```

Prints:

```
Metadata(type: Resolution, kind: .struct, size: 16, properties: [
  Property(name: 'width', isStrong: true, isLazy: false, isVar: false, offset: 0), 
  Property(name: 'height', isStrong: true, isLazy: false, isVar: false, offset: 8)
])
```

### [key]

Gets and sets a value for a property identified by a string key.

```swift
import KeyValueCoding

struct Resolution: KeyValueCoding {
  let width: Int
  let height: Int
}

var resolution = Resolution(width: 1920, height: 1080)

resolution["width"] = 2048

if let width: Int = resolution["width"] {
  print(width) // Prints: 2048
}
```

### [keyPath]

Gets and sets a value for a property identified by a key path.

``` swift
import KeyValueCoding

struct Resolution: KeyValueCoding {
  let width: Int
  let height: Int
}

var resolution = Resolution(width: 1920, height: 1080)

resolution[\Resolution.width] = 2048

if let width: Int = resolution[\Resolution.width] {
  print(width) // Prints: 2048
}
```

## API

Global API functions to set, get and retrieve metadata information from any instance or type **even without adopting** `KeyValueCoding` protocol.

### swift_metadata

Returns the metadata of an instance or a type which includes its `type`, `kind`, `size` and a list of accessible `properties`:

```swift
import KeyValueCoding

struct Resolution {
  let width: Int
  let height: Int
}

let resolution = Resolution(width: 1920, height: 1080)
    
var metadata = swift_metadata(of: resolution)
// OR
metadata = swift_metadata(of: type(of: resolution))
// OR
metadata = swift_metadata(of: Resolution.self)

print(metadata)
```

Prints:

```
Metadata(type: Resolution, kind: .struct, size: 16, properties: [
 Property(name: 'width', isStrong: true, isLazy: false, isVar: false, offset: 0), 
 Property(name: 'height', isStrong: true, isLazy: false, isVar: false, offset: 8)
])
```

### swift_value

Returns the value for the instance's property identified by a given string key or a key path.

```swift
import KeyValueCoding

struct Resolution {
  let width: Int
  let height: Int
}

var resolution = Resolution(width: 1920, height: 1080)
    
if let width = swift_value(of: &resolution, key: "width") as? Int {
  print(width) // Prints: 1920
}
// OR   
if let width = swift_value(of: &resolution, keyPath: \Resolution.width) as? Int {
  print(width) // Prints: 1920
}
```

### swift_setValue

Sets a property of an instance specified by a given string key or a key path to a given value.

``` swift
import KeyValueCoding

struct Resolution {
  let width: Int
  let height: Int
}

var resolution = Resolution(width: 1920, height: 1080)
    
swift_setValue(2048, to: &resolution, key: "width")
// OR
swift_setValue(2048, to: &resolution, keyPath: \Resolution.width)
    
print(resolution) // Prints: Resolution(width: 2048, height: 1080)
```

## Installation

### XCode

1. Select `Xcode > File > Add Packages...`
2. Add package repository: `https://github.com/ikhvorost/KeyValueCoding.git`
3. Import the package in your source files: `import KeyValueCoding`

### Swift Package

Add `KeyValueCoding` package dependency to your `Package.swift` file:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/ikhvorost/KeyValueCoding.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "YourPackage",
            dependencies: [
                .product(name: "KeyValueCoding", package: "KeyValueCoding")
            ]
        ),
        ...
    ...
)
```

## License

KeyValueCoding is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate/?hosted_button_id=TSPDD3ZAAH24C)
