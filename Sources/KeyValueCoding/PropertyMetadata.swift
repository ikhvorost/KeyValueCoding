//
//  PropertyMetadata.swift
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


import Foundation

@discardableResult
func synchronized<T : AnyObject, U>(_ obj: T, closure: () -> U) -> U {
    objc_sync_enter(obj)
    defer {
        objc_sync_exit(obj)
    }
    return closure()
}

/// Property metadata details.
public struct PropertyMetadata {
    /// Name of property.
    public let name: String
    /// Type of property.
    public let type: Any.Type
    /// Is strong referenced property.
    public let isStrong: Bool
    /// Is variable property.
    public let isVar: Bool
    /// Offset of property.
    public let offset: Int
}

class PropertyCache {
    
    static let shared = PropertyCache()
    
    private var cache = [String : [PropertyMetadata]]()
    
    private func enumProperties(of type: Any.Type) -> [PropertyMetadata] {
        let count = swift_reflectionMirror_recursiveCount(type)
        var field = _FieldReflectionMetadata()
        return (0..<count).compactMap {
            let childType = swift_reflectionMirror_recursiveChildMetadata(type, index: $0, fieldMetadata: &field)
            
            defer { field.freeFunc?(field.name) }
            guard let name = field.name.flatMap({ String(validatingUTF8: $0) }) else {
                return nil
            }
            
            let offset = swift_reflectionMirror_recursiveChildOffset(type, index: $0)
            
            return PropertyMetadata(name: name,
                            type: childType,
                            isStrong: field.isStrong,
                            isVar: field.isVar,
                            offset: offset)
        }
    }
    
    func properties(of type: Any.Type) -> [PropertyMetadata] {
        let key = String(describing: type)
        return synchronized(self) {
            guard let properties = cache[key] else {
                let properties = enumProperties(of: type)
                cache[key] = properties
                return properties
            }
            return properties
        }
    }
}
