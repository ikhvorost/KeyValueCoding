//
//  Metadata.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 2022/05/08.
//  Copyright © 2022 Iurii Khvorost. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


import Foundation


/// Metadata for a type.
public struct Metadata {
  
  /// The metadata kind for a type.
  public enum Kind: UInt {
    // With "flags":
    // runtimePrivate = 0x100
    // nonHeap = 0x200
    // nonType = 0x400
    
    /// Class metadata kind.
    case `class` = 0
    /// Struct metadata kind.
    case `struct` = 0x200     // 0 | nonHeap
    /// Enum metadata kind.
    case `enum` = 0x201       // 1 | nonHeap
    /// Optional metadata kind.
    case optional = 0x202     // 2 | nonHeap
    /// Foreign class metadata kind.
    case foreignClass = 0x203 // 3 | nonHeap
    /// Opaque metadata kind.
    case opaque = 0x300       // 0 | runtimePrivate | nonHeap
    /// Tuple metadata kind.
    case tuple = 0x301        // 1 | runtimePrivate | nonHeap
    /// Function metadata kind.
    case function = 0x302     // 2 | runtimePrivate | nonHeap
    /// Existential metadata kind.
    case existential = 0x303  // 3 | runtimePrivate | nonHeap
    /// Metatype metadata kind.
    case metatype = 0x304     // 4 | runtimePrivate | nonHeap
    /// Objc class wrapper metadata kind.
    case objcClassWrapper = 0x305     // 5 | runtimePrivate | nonHeap
    /// Existential metatype metadata kind.
    case existentialMetatype = 0x306  // 6 | runtimePrivate | nonHeap
    /// Heap local variable metadata kind.
    case heapLocalVariable = 0x400    // 0 | nonType
    /// Heap generic local variable metadata kind.
    case heapGenericLocalVariable = 0x500 // 0 | nonType | runtimePrivate
    /// Error object metadata kind.
    case errorObject = 0x501  // 1 | nonType | runtimePrivate
    /// Unknown metadata kind.
    case unknown = 0xffff
    
    static func kind(of type: Any.Type) -> Self {
      let kind = swift_getMetadataKind(type)
      return Self(rawValue: kind) ?? .unknown
    }
  }
  
  /// Property details.
  public struct Property {
    /// Name of the property.
    public let name: String
    
    /// Is strong referenced property.
    public let isStrong: Bool
    
    /// Is variable property.
    public let isVar: Bool
    
    public let isLazy: Bool
    
    /// Offset of the property.
    public let offset: Int
    
    /// Metadata of the property.
    public let metadata: Metadata
  }
  
  private let container: ProtocolTypeContainer
  
  /// Type.
  public let type: Any.Type
  
  /// Kind of the type.
  public let kind: Kind
  
  /// Size of the type.
  public var size: Int { container.accessor.size }
  
  /// Accessible properties of the type.
  public let properties: [Property]
  
  private static func enumProperties(type: Any.Type, kind: Kind) -> [Property] {
    let count = swift_reflectionMirror_recursiveCount(type)
    var fieldMetadata = _FieldReflectionMetadata()
    return (0..<count).map {
      let propType = swift_reflectionMirror_recursiveChildMetadata(type, index: $0, fieldMetadata: &fieldMetadata)
      defer { fieldMetadata.freeFunc?(fieldMetadata.name) }
      
      assert(fieldMetadata.name != nil)
      var name = String(cString: fieldMetadata.name!)
      
      var isLazy = false
      let lazyPrefix = "$__lazy_storage_$_"
      if name.hasPrefix(lazyPrefix) {
        name = name.replacingOccurrences(of: lazyPrefix, with: "")
        isLazy = true
      }
      
      let offset = swift_reflectionMirror_recursiveChildOffset(type, index: $0)
      let metadata = Metadata(of: propType)
      
      return Property(name: name, isStrong: fieldMetadata.isStrong, isVar: fieldMetadata.isVar, isLazy: isLazy, offset: offset, metadata: metadata)
    }
  }
  
  init(of type: Any.Type) {
    self.type = type
    self.kind = Kind.kind(of: type)
    self.container = ProtocolTypeContainer(type: type)
    self.properties = kind == .class || kind == .struct
      ? Self.enumProperties(type: type, kind: self.kind)
      : []
  }
  
  init(of value: Any) {
    let type = Swift.type(of: value)
    self.init(of: type)
  }
  
  func get(from pointer: UnsafeRawPointer) -> Any? {
    let value = container.accessor.get(from: pointer)
    
    // Optional
    if kind == .optional {
      let mirror = Mirror(reflecting: value)
      return mirror.children.first?.value
    }
    
    return value
  }
  
  func set(value: Any, pointer: UnsafeMutableRawPointer) {
    container.accessor.set(value: value as Any, pointer: pointer)
  }
}

extension Metadata.Property: CustomStringConvertible {
  /// A textual representation the `Metadata.Property`.
  public var description: String {
    return "Property(name: '\(name)', isStrong: \(isStrong), isVar: \(isVar), offset: \(offset))"
  }
}

extension Metadata: CustomStringConvertible {
  /// A textual representation the `Metadata`.
  public var description: String {
    return "Metadata(type: \(type), kind: .\(kind), size: \(size), properties: \(properties))"
  }
}
