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


fileprivate func withPointer<T>(_ instance: inout T, _ body: (UnsafeMutableRawPointer, Metadata) -> Any?) -> Any? {
    withUnsafePointer(to: &instance) {
        let metadata = swift_metadata(of: T.self)
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
                let metadata = swift_metadata(of: type)
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
fileprivate func withProperty<T>(_ instance: inout T, keys: inout [String], _ body: (Accessor.Type, UnsafeMutableRawPointer) -> Any?) -> Any? {
    withPointer(&instance) { pointer, metadata in
        guard let key = keys.popLast(), let property = (metadata.properties.first { $0.name == key }) else {
            return nil
        }

        let pointer = pointer.advanced(by: property.offset)

        if keys.isEmpty {
            return body(property.metadata.accessor, pointer)
        }
        else if var value = property.metadata.accessor.get(from: pointer) {
            defer {
                if property.metadata.kind == .struct {
                    property.metadata.accessor.set(value: value, pointer: pointer)
                }
            }
            return withProperty(&value, keys: &keys, body)
        }
        return nil
    }
}

// MARK: -

/// Returns the metadata of the type.
///
/// - Parameters:
///     - type: Type of a metatype instance.
/// - Returns: Metadata of the type.
public func swift_metadata(of type: Any.Type) -> Metadata {
    MetadataCache.shared.metadata(of: type)
}

/// Returns the metadata of the instance.
///
/// - Parameters:
///     - instance: Instance of any type.
/// - Returns: Metadata of the type.
public func swift_metadata(of instance: Any) -> Metadata {
    let type = type(of: instance)
    return swift_metadata(of: type)
}

/// Returns the value for the instance's property identified by a given key.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - key: The name of one of the instance's properties.
/// - Returns: The value for the property identified by key.
public func swift_value<T>(of instance: inout T, key: String) -> Any? {
    var keys = Array(key.components(separatedBy: ".").reversed())
    return withProperty(&instance, keys: &keys) { accessor, pointer in
        accessor.get(from: pointer)
    }
}

/// Sets a property of an instance specified by a given key to a given value.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - value: The value for the property identified by key.
///     - key: The name of one of the instance's properties.
public func swift_setValue<T>(_ value: Any?, to: inout T, key: String) {
    var keys = Array(key.components(separatedBy: ".").reversed())
    withProperty(&to, keys: &keys) { accessor, pointer in
        accessor.set(value: value as Any, pointer: pointer)
    }
}

// MARK: - KeyValueCoding

/// Protocol to access to the properties of an instance indirectly by name or key.
public protocol KeyValueCoding {}

extension KeyValueCoding {
    
    /// Returns the metadata of the instance.
    public var metadata: Metadata {
        swift_metadata(of: self)
    }
    
    /// Returns a value for a property identified by a given key.
    ///
    /// - Parameters:
    ///     - key: The name of one of the instance's properties.
    /// - Returns: The value for the property identified by key.
    public mutating func value(key: String) -> Any? {
        swift_value(of: &self, key: key)
    }
    
    /// Sets a property specified by a given key to a given value.
    ///
    /// - Parameters:
    ///     - value: The value for the property identified by key.
    ///     - key: The name of one of the instance's properties.
    public mutating func setValue(_ value: Any?, key: String) {
        swift_setValue(value, to: &self, key: key)
    }
    
    /// Gets and sets a value for a property identified by a given key.
    public subscript(key: String) -> Any? {
        mutating get {
            value(key:key)
        }
        set {
            setValue(newValue, key: key)
        }
    }
}
