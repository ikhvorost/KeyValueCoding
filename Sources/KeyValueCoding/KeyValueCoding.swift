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


fileprivate func withPointer<T, U>(_ object: inout T, kind: _MetadataKind, _ body: (UnsafeMutableRawPointer) throws -> U?) throws -> U? {
    switch kind {
    case .struct:
        return try withUnsafePointer(to: &object) {
            let pointer = UnsafeMutableRawPointer(mutating: $0)
            return try body(pointer)
        }
        
    case .class:
        return try withUnsafePointer(to: &object) {
            try $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                try body($0.pointee)
            }
        }
        
    default:
        fatalError("Unsupported type")
    }
}

@discardableResult
fileprivate func withProperty<T, U>(_ object: inout T, key: String, _ body: (Accessor.Type, UnsafeMutableRawPointer) -> U?) -> U? {
    let type = type(of: object)
    let kind = _MetadataKind.kind(of: type)
    guard kind == .class || kind == .struct else {
        return nil
    }
    
    guard let property = (swift_properties(of: type).first { $0.name == key }) else {
        return nil
    }
    
    return try? withPointer(&object, kind: kind) { pointer in
        let accessor = AccessorCache.shared.accessor(of: property.type)
        let valuePointer = pointer.advanced(by: property.offset)
        return body(accessor, valuePointer)
    }
}

// MARK: -

public func swift_properties(of type: Any.Type) -> [Property] {
    PropertyCache.shared.properties(of: type)
}

public func swift_properties(of object: Any) -> [Property] {
    let type = type(of: object)
    return swift_properties(of: type)
}

public func swift_value<T, U>(of object: inout T, key: String) -> U? {
    withProperty(&object, key: key) { accessor, valuePointer in
        accessor.get(from: valuePointer)
    }
}

public func swift_setValue<T>(_ value: Any, key: String, object: inout T) {
    withProperty(&object, key: key) { accessor, valuePointer in
        accessor.set(value: value, pointer: valuePointer)
    }
}

// MARK: - KeyValueCoding

public protocol KeyValueCoding {
}

public typealias KVC = KeyValueCoding

extension KeyValueCoding {
    
    public var properties: [Property] {
        swift_properties(of: self)
    }
    
    public mutating func value<T>(key: String) -> T? {
        value(key: key) as? T
    }
    
    public mutating func value(key: String) -> Any? {
        withProperty(&self, key: key) { accessor, valuePointer in
            return accessor.get(from: valuePointer)
        }
    }
    
    public mutating func setValue<T>(_ value: T, key: String) {
        withProperty(&self, key: key) { accessor, valuePointer in
            accessor.set(value: value, pointer: valuePointer)
        }
    }
}
