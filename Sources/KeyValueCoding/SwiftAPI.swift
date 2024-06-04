//
//  SwiftAPI.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 2024/03/19.
//  Copyright © 2024 Iurii Khvorost. All rights reserved.
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


fileprivate func withPointer<T>(_ instance: inout T, _ body: (UnsafeMutableRawPointer, Metadata) -> Any?) -> Any? {
  withUnsafePointer(to: &instance) {
    let metadata = Metadata(of: T.self)
    if metadata.kind == .struct {
      return body(UnsafeMutableRawPointer(mutating: $0), metadata)
    }
    else if metadata.kind == .class {
      return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
        body($0.pointee, metadata)
      }
    }
    else if metadata.kind == .existential {
      return $0.withMemoryRebound(to: ExistentialContainer.self, capacity: 1) {
        let type = $0.pointee.type
        let metadata = Metadata(of: type)
        if metadata.kind == .class {
          return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
            body($0.pointee, metadata)
          }
        }
        else if metadata.kind == .struct {
          if metadata.size > MemoryLayout<ExistentialContainerBuffer>.size {
            return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
              body($0.pointee.advanced(by: ExistentialHeaderSize), metadata)
            }
          }
          else {
            return body(UnsafeMutableRawPointer(mutating: $0), metadata)
          }
        }
        return nil
      }
    }
    return nil
  }
}

@discardableResult
fileprivate func withProperty<T>(_ instance: inout T, keyPath: [String], _ body: (Metadata, UnsafeMutableRawPointer) -> Any?) -> Any? {
  withPointer(&instance) { pointer, metadata in
    var keys = keyPath
    guard let key = keys.popLast(), let prop = metadata.properties.first(where: { $0.name == key }) else {
      return nil
    }
    
    let pointer = pointer.advanced(by: prop.offset)
    
    if keys.isEmpty {
      return body(prop.metadata, pointer)
    }
    else if var value = prop.metadata.get(from: pointer) {
      defer {
        let metadata = Metadata(of: value)
        if metadata.kind == .struct {
          prop.metadata.set(value: value, pointer: pointer)
        }
      }
      return withProperty(&value, keyPath: keys, body)
    }
    return nil
  }
}

fileprivate func key(keyPath: AnyKeyPath) -> String {
  var key = "\(keyPath)"
  let index = key.firstIndex(of: ".")!
  key = String(key[key.index(index, offsetBy: 1)..<key.endIndex])
  return key.replacingOccurrences(of: #"[\?\!]"#, with: "", options: [.regularExpression])
}

/// Returns the metadata of the type.
///
/// - Parameters:
///     - type: Type of a metatype instance.
/// - Returns: Metadata of the type.
public func swift_metadata(of type: Any.Type) -> Metadata {
  Metadata(of: type)
}

/// Returns the metadata of the instance.
///
/// - Parameters:
///     - instance: Instance of any type.
/// - Returns: Metadata of the type.
public func swift_metadata(of value: Any) -> Metadata {
  let type = Swift.type(of: value)
  return swift_metadata(of: type)
}

/// Returns the value for the instance's property identified by a given string key.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - key: The string key of one of the instance's properties of the form
///            relationship.property (with one or more relationships):
///            for example “department.name” or “department.manager.lastName.”
/// - Returns: The value of the property.
public func swift_value<T>(of instance: inout T, key: String) -> Any? {
  let keyPath: [String] = key.components(separatedBy: ".").reversed()
  return withProperty(&instance, keyPath: keyPath) { metadata, pointer in
    metadata.get(from: pointer)
  }
}

/// Returns the value for the instance's property identified by a key path.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - keyPath: Key path.
/// - Returns: The value for the property.
public func swift_value<T>(of instance: inout T, keyPath: AnyKeyPath) -> Any? {
  let key = key(keyPath: keyPath)
  return swift_value(of: &instance, key: key)
}

/// Sets a property of an instance specified by a given string key to a given value.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - value: The value for the property.
///     - key: The string key of one of the instance's properties of the form
///            relationship.property (with one or more relationships):
///            for example “department.name” or “department.manager.lastName.”
public func swift_setValue<T>(_ value: Any?, to: inout T, key: String) {
  let keyPath: [String] = key.components(separatedBy: ".").reversed()
  withProperty(&to, keyPath: keyPath) { metadata, pointer in
    metadata.set(value: value as Any, pointer: pointer)
  }
}

/// Sets a property of an instance specified by a given key path to a given value.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - value: The value for the property.
///     - key: The key path of one of the instance's properties.
public func swift_setValue<T>(_ value: Any?, to: inout T, keyPath: AnyKeyPath) {
  let key = key(keyPath: keyPath)
  swift_setValue(value, to: &to, key: key)
}
