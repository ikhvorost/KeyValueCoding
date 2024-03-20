//
//  KeyValueCoding.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 2022/04/22.
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


/// Protocol to access to the properties of an instance indirectly by a name or a key path.
public protocol KeyValueCoding {}

extension KeyValueCoding {
  
  /// Returns the metadata of the instance type.
  public var metadata: Metadata {
    swift_metadata(of: self)
  }
  
  /// Returns a value for a property identified by a given name or a key path.
  ///
  /// - Parameters:
  ///   - key: The name of one of the instance's properties or a key path of the form
  ///           relationship.property (with one or more relationships):
  ///           for example “department.name” or “department.manager.lastName.”
  /// - Returns: The value for the property identified by a name or a key path.
  public mutating func value(key: String) -> Any? {
    swift_value(of: &self, key: key)
  }
  
  public mutating func value<U>(key: String) -> U? {
    value(key: key) as? U
  }
  
  public mutating func value(keyPath: AnyKeyPath) -> Any? {
    swift_value(of: &self, keyPath: keyPath)
  }
  
  public mutating func value<U>(keyPath: AnyKeyPath) -> U? {
    value(keyPath: keyPath) as? U
  }
  
  /// Sets a property specified by a given name or a key path to a given value.
  ///
  /// - Parameters:
  ///   - value: The value for the property identified by a name or a key path.
  ///   - key: The name of one of the instance's properties or a key path of the form
  ///           relationship.property (with one or more relationships):
  ///           for example “department.name” or “department.manager.lastName.”
  public mutating func setValue(_ value: Any?, key: String) {
    swift_setValue(value, to: &self, key: key)
  }
  
  public mutating func setValue(_ value: Any?, keyPath: AnyKeyPath) {
    swift_setValue(value, to: &self, keyPath: keyPath)
  }
  
  /// Gets and sets a value for a property identified by a given name or a key path.
  public subscript(key: String) -> Any? {
    mutating get {
      value(key: key)
    }
    set {
      setValue(newValue, key: key)
    }
  }
  
  public subscript<T>(key: String) -> T? {
    mutating get {
      value(key: key)
    }
    set {
      setValue(newValue, key: key)
    }
  }
  
  public subscript(keyPath: AnyKeyPath) -> Any? {
    mutating get {
      value(keyPath: keyPath)
    }
    set {
      setValue(newValue, keyPath: keyPath)
    }
  }
  
  public subscript<U>(keyPath: AnyKeyPath) -> U? {
    mutating get {
      value(keyPath: keyPath)
    }
    set {
      setValue(newValue, keyPath: keyPath)
    }
  }
}
