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

fileprivate func withPointer<T>(_ instance: inout T, metadata: Metadata, _ body: (UnsafeMutableRawPointer, Metadata) -> Any?) -> Any? {
    withUnsafePointer(to: &instance) {
        switch metadata.kind {
        case .struct:
            return body(UnsafeMutableRawPointer(mutating: $0), metadata)
            
        case .class:
            return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                body($0.pointee, metadata)
            }
            
        case .existential:
            return $0.withMemoryRebound(to: ExistentialContainer.self, capacity: 1) {
                let type = $0.pointee.type
                let metadata = MetadataCache.shared.metadata(of: type)
                if metadata.kind == .class {
                    return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                        body($0.pointee, metadata)
                    }
                }
                else { // struct
                    if metadata.size > MemoryLayout<ExistentialContainerBuffer>.size {
                        return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                            body($0.pointee.advanced(by: 16), metadata)
                        }
                    }
                    else {
                        return body(UnsafeMutableRawPointer(mutating: $0), metadata)
                    }
                }
            }
            
        default:
            return nil
        }
    }
}

@discardableResult
fileprivate func withProperty<T>(_ instance: inout T, key: String, _ body: (Accessor.Type, UnsafeMutableRawPointer) -> Any?) -> Any? {
    let type = T.self
    let metadata = MetadataCache.shared.metadata(of: type)
    
    return withPointer(&instance, metadata: metadata) { pointer, metadata in
        guard let property = (metadata.properties.first { $0.name == key }) else {
            return nil
        }
        
        let pointer = pointer.advanced(by: property.offset)
        return body(property.accessor, pointer)
    }
}

// MARK: -

/// Returns the metadata kind of the type.
///
/// - Parameters:
///     - type: Type of a metatype instance.
/// - Returns: Metadata kind of the type.
public func swift_metadataKind(of type: Any.Type) -> Metadata.Kind {
    Metadata.Kind.kind(of: type)
}

/// Returns the metadata kind of the instance.
///
/// - Parameters:
///     - instance: Instance of any type.
/// - Returns: Metadata kind of the type.
public func swift_metadataKind(of instance: Any) -> Metadata.Kind {
    let type = type(of: instance)
    return swift_metadataKind(of: type)
}

/// Returns the array of the type's properties.
///
/// - Parameters:
///     - type: Type of a metatype instance.
/// - Returns: Array of the type's properties.
public func swift_properties(of type: Any.Type) -> [Metadata.Property] {
    MetadataCache.shared.metadata(of: type).properties
}

/// Returns the array of the instance's properties.
///
/// - Parameters:
///     - instance: Instance of any type.
/// - Returns: Array of the instance's properties.
public func swift_properties(of instance: Any) -> [Metadata.Property] {
    let type = type(of: instance)
    return swift_properties(of: type)
}

/// Returns the value for the instance's property identified by a given key.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - key: The name of one of the instance's properties.
/// - Returns: The value for the property identified by key.
public func swift_value<T>(of instance: inout T, key: String) -> Any? {
    withProperty(&instance, key: key) { accessor, pointer in
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
    withProperty(&to, key: key) { accessor, pointer in
        accessor.set(value: value as Any, pointer: pointer)
    }
}

// MARK: - KeyValueCoding

/// Protocol to access to the properties of an instance indirectly by name or key.
public protocol KeyValueCoding {}

extension KeyValueCoding {
    
    /// Returns the metadata kind of the instance.
    public var metadataKind: Metadata.Kind {
        swift_metadataKind(of: self)
    }
    
    /// Returns the array of the instance's properties.
    public var properties: [Metadata.Property] {
        swift_properties(of: self)
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
            setValue(newValue as Any?, key: key)
        }
    }
}
