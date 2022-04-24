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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


fileprivate func withPointer<T>(_ instance: inout T, kind: MetadataKind, _ body: (UnsafeMutableRawPointer) throws -> Any?) throws -> Any? {
    switch kind {
    case .struct:
        return try withUnsafePointer(to: &instance) {
            let pointer = UnsafeMutableRawPointer(mutating: $0)
            return try body(pointer)
        }
        
    case .class:
        return try withUnsafePointer(to: &instance) {
            try $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                try body($0.pointee)
            }
        }
        
    default:
        return nil
    }
}

@discardableResult
fileprivate func withProperty<T>(_ instance: inout T, key: String, _ body: (Accessor.Type, UnsafeMutableRawPointer) -> Any?) -> Any? {
    let type = type(of: instance)
    let kind = swift_metadataKind(of: type)
    guard kind == .class || kind == .struct else {
        return nil
    }
    
    guard let property = (swift_properties(of: type).first { $0.name == key }) else {
        return nil
    }
    
    return try? withPointer(&instance, kind: kind) { pointer in
        let accessor = AccessorCache.shared.accessor(of: property.type)
        let valuePointer = pointer.advanced(by: property.offset)
        return body(accessor, valuePointer)
    }
}

// MARK: -

/// Returns the metadata kind of the type.
///
/// - Parameters:
///     - type: Type of a metatype instance.
/// - Returns: Metadata kind of the type.
public func swift_metadataKind(of type: Any.Type) -> MetadataKind {
    MetadataKind.kind(of: type)
}

/// Returns the metadata kind of the instance.
///
/// - Parameters:
///     - instance: Instance of any type.
/// - Returns: Metadata kind of the type.
public func swift_metadataKind(of instance: Any) -> MetadataKind {
    let type = type(of: instance)
    return swift_metadataKind(of: type)
}

/// Returns the array of the receiver's properties.
///
/// - Parameters:
///     - type: Type of a metatype instance.
/// - Returns: Array of the receiver's properties.
public func swift_properties(of type: Any.Type) -> [PropertyMetadata] {
    PropertyCache.shared.properties(of: type)
}

/// Returns the array of the receiver's properties.
///
/// - Parameters:
///     - instance: Instance of any type.
/// - Returns: Array of the receiver's properties.
public func swift_properties(of instance: Any) -> [PropertyMetadata] {
    let type = type(of: instance)
    return swift_properties(of: type)
}

/// Returns the value for the instance's property identified by a given key.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - key: The name of one of the receiver's properties.
/// - Returns: The value for the property identified by key.
public func swift_value<T>(of instance: inout T, key: String) -> Any? {
    withProperty(&instance, key: key) { accessor, valuePointer in
        accessor.get(from: valuePointer)
    }
}

/// Sets a property of an instance specified by a given key to a given value.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - value: The value for the property identified by key.
///     - key: The name of one of the receiver's properties.
public func swift_setValue<T>(_ value: Any?, instance: inout T, key: String) {
    withProperty(&instance, key: key) { accessor, valuePointer in
        accessor.set(value: value as Any, pointer: valuePointer)
    }
}

// MARK: - KeyValueCoding

/// Protocol to access to the properties of an instance indirectly by name or key.
public protocol KeyValueCoding {
}

extension KeyValueCoding {
    
    /// Returns the metadata kind of the receiver.
    public var metadataKind: MetadataKind {
        swift_metadataKind(of: self)
    }
    
    /// Returns the array of the receiver's properties.
    public var properties: [PropertyMetadata] {
        swift_properties(of: self)
    }
    
    /// Returns a value for a property identified by a given key.
    ///
    /// - Parameters:
    ///     - key: The name of one of the receiver's properties.
    /// - Returns: The value for the property identified by key.
    public mutating func value(key: String) -> Any? {
        swift_value(of: &self, key: key)
    }
    
    /// Sets a property specified by a given key to a given value.
    ///
    /// - Parameters:
    ///     - value: The value for the property identified by key.
    ///     - key: The name of one of the receiver's properties.
    public mutating func setValue(_ value: Any?, key: String) {
        swift_setValue(value, instance: &self, key: key)
    }
    
    /// Gets and sets a value for a property identified by a given key.
    public subscript(key: String) -> Any? {
        mutating get {
            value(key:key)
        }
        set {
            setValue(newValue as Any, key: key)
        }
    }
}
