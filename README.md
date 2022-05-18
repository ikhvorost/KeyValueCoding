# KeyValueCoding

[![Swift 5](https://img.shields.io/badge/Swift-5-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platforms: iOS, macOS, tvOS, watchOS](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20-blue.svg?style=flat)
[![Swift Package Manager: compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Build](https://github.com/ikhvorost/KeyValueCoding/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/ikhvorost/KeyValueCoding/actions/workflows/swift.yml)
[![Codecov](https://codecov.io/gh/ikhvorost/KeyValueCoding/branch/main/graph/badge.svg?token=26NymxLQyB)](https://codecov.io/gh/ikhvorost/KeyValueCoding)
[![Swift Doc Coverage](https://img.shields.io/badge/Swift%20Doc%20Coverage-100%25-f39f37)](https://github.com/SwiftDocOrg/swift-doc)

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate/?hosted_button_id=TSPDD3ZAAH24C)

`KeyValueCoding` provides a mechanism by which you can access the properties of pure Swift struct or class instances indirectly by a property name or a key path.

- [Getting Started](#gettingstarted)
  - [Basics](#basics)
  - [Subscript](#subscript)
  - [Class Inheritance](#class-inheritance)
  - [NSObject](#nsobject)
  - [Struct](#struct)
  - [Protocols](#protocols)
  - [Functions](#functions)
- [KeyValueCoding Protocol](#keyvaluecoding-protocol)
  - [metadata](#metadata)
  - [value(key:)](#valuekey)
  - [setValue(_:, key:)](#setvalue_-key)
  - [[key]](#key)
- [API](#api)
  - [swift_metadata()](#swift_metadata)
  - [swift_value(of:, key:)](#swift_valueof-key)
  - [swift_setValue<T>(_:, to:, key:)](#swift_setvalue_-to-key)
- [Installation](#installation)
- [License](#license)

## Getting Started

## Basics

The basic methods of `KeyValueCoding` protocol for accessing an instance’s values are `setValue(_ value: Any?, key: String)`, which sets the value for the property identified by the specified name or key path, and `value(key: String) -> Any?`, which returns the value for the property identified by the specified name or key path.

Thus, **all of the properties** can be accessible in a consistent manner including:

- Constant `let` and variable `var` properties.
- Properties with any access level: `public`, `internal`, `private`.
- Properties of any type: `enum`, `optional`, `struct`, `class` etc.
- Relationship properties by the key path form "relationship.property" (with one or more relationships), for example "contactInfo.email" etc.

There are **next limitations**:

- Computed properties are not addressable.
- The `willSet` and `didSet` observers aren’t called while you set values.

In order to make your types key-value coding compliant just adopt them from the `KeyValueCoding` protocol, for instance:

```swift
import KeyValueCoding

enum UserType {
    case none
    case guest
    case user
    case admin
}

class ContactInfo {
    let phone: String = ""
    let email: String = ""
}

class User: KeyValueCoding {
    private let id: Int = 0
    let type: UserType = .none
    let name: String = ""
    let SSN: Int? = nil
    let contactInfo = ContactInfo()
}

var user = User()

user.setValue(123, key: "id")
user.setValue(UserType.guest, key: "type")
user.setValue("Bob", key: "name")
user.setValue(123456789, key: "SSN")
user.setValue("bob@mail.com", key: "contactInfo.email")

guard let id = user.value(key: "id"),
      let type = user.value(key: "type"),
      let name = user.value(key: "name"),
      let ssn = user.value(key: "SSN"),
      let email = user.value(key: "contactInfo.email")
else {
    return
}

print(id, type, name, ssn, email) // 123 guest Bob 123456789 bob@mail.com
```

### Subscript

You can also use subscripts to set and retrieve values by a name or a key path without needing separate methods for setting and retrieval:

```swift
var user = User()

user["id"] = 123
user["type"] = UserType.guest
user["name"] = "Bob"
user["SSN"] = 123456789
user["contactInfo.email"] = "bob@mail.com"

guard let id = user["id"],
      let type = user["type"],
      let name = user["name"],
      let ssn = user["SSN"],
      let email = user["contactInfo.email"]
else {
    return
}

print(id, type, name, ssn, email) // 123 guest Bob 123456789 bob@mail.com
```

### Class Inheritance

Properties from inherited classes are also accessible by `KeyValueCoding` protocol:

```swift
class A: KeyValueCoding {
    let a = 0
}

class B: A {
    let b = 0
}

var b = B()

b["a"] = 100
b["b"] = 200

guard let a = b["a"], let b = b["b"] else {
    return
}
print(a, b) // 100 200
```

### NSObject

`KeyValueCoding` doesn't conflict with key-value conding of `NSObject` class and they can work together:

``` swift
class Resolution: NSObject, KeyValueCoding {
    @objc var width = 0
    @objc var height = 0
}

var resolution = Resolution()

// NSObject protocol
resolution.setValue(1024, forKey: "width")

// KeyValueCoding protocol
resolution.setValue(760, key: "height")
// OR
resolution["height"] = 760

print(resolution.width, resolution.height) // 1024 760
```

### Struct

`KeyValueCoding` works with structs as well:

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

### Protocols

You can inherit any protocol from `KeyValueCoding` one and then use instances with the protocol type to access to declared properties:

```swift
protocol BookProtocol: KeyValueCoding {
    var title: String { get }
    var ISBN: Int { get }
}

struct Book: BookProtocol {
    let title: String = ""
    let ISBN: Int = 0
}

var book: BookProtocol = Book()

book["title"] = "The Swift Programming Language"
book["ISBN"] = 1234567890

print(book) // Book(title: "The Swift Programming Language", ISBN: 1234567890)
```

### Functions

In additional you can use API functions to set and get values of any properties **without adopting** `KeyValueCoding` protocol at all:

``` swift
struct Song {
    let name: String
    let artist: String
}

var song = Song(name: "", artist: "")

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


### metadata

Returns the metadata of the instance which includes its `type`, `kind`, `size` and a list of accessible `properties`:

```swift
let user = User()

print(user.metadata)
```

Outputs:

```
Metadata(type: User, kind: .class, size: 8, properties: [
  Property(name: 'id', isStrong: true, isVar: false, offset: 16),
  Property(name: 'type', isStrong: true, isVar: false, offset: 24),
  Property(name: 'name', isStrong: true, isVar: false, offset: 32),
  Property(name: 'SSN', isStrong: true, isVar: false, offset: 48)])
```

### value(key:)

Returns a value for a property identified by a given name or key path.

```swift
var user = User()
if let type = user.value(key: "type") {
    print(type) // none
}
```

### setValue(_:, key:)

Sets a property specified by a given name or key path to a given value.

```swift
var user = User()

user.setValue(UserType.admin, key: "type")

if let type = user.value(key: "type") {
    print(type) // admin
}
```

### [key]

Gets and sets a value for a property identified by a name or a key path.

```swift
var user = User()

user["type"] = UserType.guest

if let type = user["type"] {
    print(type) // guest
}
```

## API

Global API functions to set, get and retrieve metadata information from any instance or type **even without adopting** `KeyValueCoding` protocol.

### swift_metadata()

Returns the metadata of an instance or a type which includes its `type`, `kind`, `size` and a list of accessible `properties`:

```swift
var song = Song(name: "Blue Suede Shoes", artist: "Elvis Presley")

let metadata = swift_metadata(of: song)
// OR
swift_metadata(of: type(of: song))
// OR
swift_metadata(of: Song.self)

print(metadata)
```

Outputs:

```
Metadata(type: Song, kind: .struct, size: 32, properties: [
  Property(name: 'name', isStrong: true, isVar: false, offset: 0),
  Property(name: 'artist', isStrong: true, isVar: false, offset: 16)])
```

### swift_value(of:, key:)

Returns the value for the instance's property identified by a given name or key path.

```swift
var song = Song(name: "Blue Suede Shoes", artist: "Elvis Presley")

guard let name = swift_value(of: &song, key: "name"),
      let aritst = swift_value(of: &song, key: "artist")
else {
    return
}

print(name, "-", aritst) // Blue Suede Shoes - Elvis Presley
```

### swift_setValue(_:, to:, key:)

Sets a property of an instance specified by a given name or key path to a given value.

```swift
var song = Song(name: "", artist: "")

swift_setValue("Blue Suede Shoes", to: &song, key: "name")
swift_setValue("Elvis Presley", to: &song, key: "artist")

print(song.name, "-", song.artist) // Blue Suede Shoes - Elvis Presley
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
