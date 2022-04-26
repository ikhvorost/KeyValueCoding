# KeyValueCoding

[![Swift: 5.x](https://img.shields.io/badge/Swift-5.x-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platforms: iOS, macOS, tvOS, watchOS](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20-blue.svg?style=flat)
[![Swift Package Manager: compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Build](https://github.com/ikhvorost/KeyValueCoding/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/ikhvorost/KeyValueCoding/actions/workflows/swift.yml)
[![Codecov](https://codecov.io/gh/ikhvorost/KeyValueCoding/branch/main/graph/badge.svg?token=26NymxLQyB)](https://codecov.io/gh/ikhvorost/KeyValueCoding)
[![Swift Doc Coverage](https://img.shields.io/badge/Swift%20Doc%20Coverage-100%25-f39f37)](https://github.com/SwiftDocOrg/swift-doc)

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate/?hosted_button_id=TSPDD3ZAAH24C)

KeyValueCoding protocol provides a mechanism by which you can access the properties of pure Swift struct or class instances indirectly by name or key.

- [Overview](#Overview)
- [KeyValueCoding Protocol](#keyvaluecoding-protocol)
  - [metadataKind](#metadatakind)
  - [properties](#properties)
  - [value(key:)](#valuekey)
  - [setValue(_:, key:)](#setvalue_-key)
  - [[key]](#key)
- [Functions](#functions)
  - [swift_metadataKind(of:)](swift_metadatakindof)
  - [swift_properties(of:)](swift_propertiesof)
  - [swift_value(of:, key:)](swift_valueof-key)
  - [swift_setValue<T>(_:, to:, key:)](swift_setvalue_-to-key)
- [Installation](#installation)
- [License](#license)

## Overview

The basic methods of `KeyValueCoding` protocol for accessing an instance’s values are `setValue(_ value: Any?, key: String)`, which sets the value for the property identified by the specified key, and `value(key: String) -> Any?`, which returns the value for the property identified by the specified key. Thus, all of an instance’s properties including properties with `enum` and `Optional` types can be accessed in a consistent manner.

In order to make your own instances key-value coding compliant just adopt them from the `KeyValueCoding` protocol:

```swift
enum UserType {
    case none
    case guest
    case user
    case admin
}

class User: KeyValueCoding {
    let id: Int = 0
    let type: UserType = .none
    let name: String = ""
    let SSN: Int? = nil
}

var user = User()

user.setValue(123, key: "id")
user.setValue(UserType.guest, key: "type")
user.setValue("Bob", key: "name")
user.setValue(123456789, key: "SSN")

guard let id = user.value(key: "id") as? Int,
      let type = user.value(key: "type") as? UserType,
      let name = user.value(key: "name") as? String,
      let ssn = user.value(key: "SSN") as? Int
else {
    return
}

print(id, type, name, ssn) // 123 guest Bob 123456789
```

You can also use subscripts to set and retrieve values by key without needing separate methods for setting and retrieval:

```swift
var user = User()

user["id"] = 123
user["type"] = UserType.guest
user["name"] = "Bob"
user["SSN"] = 123456789

guard let id = user["id"] as? Int,
      let type = user["type"] as? UserType,
      let name = user["name"] as? String,
      let ssn = user["SSN"] as? Int
else {
    return
}

print(id, type, name, ssn) // 123 guest Bob 123456789
```

`KeyValueCoding` doesn't conflict with key-value conding of `NSObject` class and they can work together:

``` swift
class Resolution: NSObject, KeyValueCoding {
    @objc var width = 0
    @objc var height = 0
}

var resolution = Resolution()

// NSObject: setValue(_ value: Any?, forKey key: String)
resolution.setValue(1024, forKey: "width")

// KeyValueCoding: setValue(_ value: Any?, key: String)
resolution.setValue(760, key: "height")

print(resolution.width, resolution.height) // 1024 760
```

The same works with structs as well:

```swift
struct Book: KeyValueCoding {
    let title: String = ""
    let ISBN: Int = 0
}

var book = Book()

book["title"] = "The Swift Programming Language"
book["ISBN"] = 1234567890

print(book) // Book(title: "The Swift Programming Language", ISBN: 1234567890)
```

In additional there are also global functions to set and get values of properties without adopting `KeyValueCoding` protocol:

``` swift
struct Song {
    let name: String = ""
    let artist: String = ""
}

var song = Song()

swift_setValue("Blue Suede Shoes", to: &song, key: "name")
swift_setValue("Elvis Presley", to: &song, key: "artist")

guard let name = swift_value(of: &song, key: "name"),
      let artist = swift_value(of: &song, key: "artist")
else {
    return
}

print(name, "-", artist) // Blue Suede Shoes - Elvis Presley
```

## KeyValueCoding Protocol

Swift instances of `struct` or `class` that adopt `KeyValueCoding` protocol are key-value coding compliant for their properties and they are addressable via essential methods `value(key:)` and `setValue(_: key:)`.

### metadataKind

Returns the metadata kind of the instance.

```swift
let user = User()
print(user.metadataKind) // MetadataKind.class

let book = Book()
print(book.metadataKind) // MetadataKind.struct
```

### properties

Returns the array of the instance properties.

```swift
let user = User()
user.properties.forEach {
    print($0)
}
```

Outputs:

```
PropertyMetadata(name: "id", type: Swift.Int, isStrong: true, isVar: false, offset: 16)
PropertyMetadata(name: "type", type: KeyValueCodingTests.UserType, isStrong: true, isVar: false, offset: 24)
PropertyMetadata(name: "name", type: Swift.String, isStrong: true, isVar: false, offset: 32)
PropertyMetadata(name: "SSN", type: Swift.Optional<Swift.Int>, isStrong: true, isVar: false, offset: 48)
```

### value(key:)

Returns a value for a property identified by a given key.

```swift
var user = User()
if let type = user.value(key: "type") as? UserType {
    print(type) // none
}
```

### setValue(_:, key:)

Sets a property specified by a given key to a given value.

```swift
var user = User()

user.setValue(UserType.admin, key: "type")

if let type = user.value(key: "type") as? UserType {
    print(type) // admin
}
```

### [key]

Gets and sets a value for a property identified by a given key.

```swift
var user = User()

user["type"] = UserType.guest

if let type = user["type"] as? UserType {
    print(type) // guest
}
```

## Functions

Global functions to set, get and retrieve metadata information from any instance or type without adopting `KeyValueCoding` protocol.

### swift_metadataKind(of:)

Returns the metadata kind of the instance or type.

```swift
var song = Song()

print(swift_metadataKind(of: song)) // MetadataKind.struct
// OR
print(swift_metadataKind(of: type(of: song))) // MetadataKind.struct
// OR
print(swift_metadataKind(of: Song.self)) // MetadataKind.struct
```

### swift_properties(of:)

Returns the array of the instance or type properties.

```swift
var song = Song()

let properties = swift_properties(of: song)
// OR
swift_properties(of: type(of:song))
// OR
swift_properties(of: Song.self)

properties.forEach {
    print($0)
}
```

Outputs:

```
PropertyMetadata(name: "name", type: Swift.String, isStrong: true, isVar: false, offset: 0)
PropertyMetadata(name: "artist", type: Swift.String, isStrong: true, isVar: false, offset: 16)
```

### swift_value(of:, key:)

### swift_setValue(_:, to:, key:)


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

<p align="center">

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate/?hosted_button_id=TSPDD3ZAAH24C)

</p>
