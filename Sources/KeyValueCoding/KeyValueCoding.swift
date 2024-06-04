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


/// Protocol to access to properties of an instance indirectly by a string key or a key path.
public protocol KeyValueCoding {}

extension KeyValueCoding {
  
  /// Returns the metadata of the instance type.
  public var metadata: Metadata {
    swift_metadata(of: self)
  }
  
  /// Gets and sets a value for a property identified by a given string key.
  public subscript(key: String) -> Any? {
    mutating get {
      swift_value(of: &self, key: key)
    }
    set {
      swift_setValue(newValue, to: &self, key: key)
    }
  }
  
  /// Gets a typed value for a property identified by a given string key.
  public subscript<T>(key: String) -> T? {
    mutating get {
      swift_value(of: &self, key: key) as? T
    }
  }
  
  /// Gets and sets a value for a property identified by a given key path.
  public subscript(keyPath: AnyKeyPath) -> Any? {
    mutating get {
      swift_value(of: &self, keyPath: keyPath)
    }
    set {
      swift_setValue(newValue, to: &self, keyPath: keyPath)
    }
  }
  
  /// Gets a typed value for a property identified by a key path.
  public subscript<T>(keyPath: AnyKeyPath) -> T? {
    mutating get {
      swift_value(of: &self, keyPath: keyPath) as? T
    }
  }
}
