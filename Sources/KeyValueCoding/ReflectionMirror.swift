//
//  ReflectionMirror.swift
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


typealias NameFreeFunc = @convention(c) (UnsafePointer<CChar>?) -> Void

struct _FieldReflectionMetadata {
    let name: UnsafePointer<CChar>? = nil
    let freeFunc: NameFreeFunc? = nil
    let isStrong: Bool = false
    let isVar: Bool = false
}

@_silgen_name("swift_reflectionMirror_recursiveCount")
func swift_reflectionMirror_recursiveCount(_: Any.Type) -> Int

@_silgen_name("swift_reflectionMirror_recursiveChildMetadata")
func swift_reflectionMirror_recursiveChildMetadata(
    _: Any.Type
    , index: Int
    , fieldMetadata: UnsafeMutablePointer<_FieldReflectionMetadata>
) -> Any.Type

@_silgen_name("swift_reflectionMirror_recursiveChildOffset")
func swift_reflectionMirror_recursiveChildOffset(_: Any.Type, index: Int) -> Int

@_silgen_name("swift_getMetadataKind")
func swift_getMetadataKind(_: Any.Type) -> UInt


public enum MetadataKind: UInt {
    // With "flags":
    // runtimePrivate = 0x100
    // nonHeap = 0x200
    // nonType = 0x400
    
    case `class` = 0
    case `struct` = 0x200     // 0 | nonHeap
    case `enum` = 0x201       // 1 | nonHeap
    case optional = 0x202     // 2 | nonHeap
    case foreignClass = 0x203 // 3 | nonHeap
    case opaque = 0x300       // 0 | runtimePrivate | nonHeap
    case tuple = 0x301        // 1 | runtimePrivate | nonHeap
    case function = 0x302     // 2 | runtimePrivate | nonHeap
    case existential = 0x303  // 3 | runtimePrivate | nonHeap
    case metatype = 0x304     // 4 | runtimePrivate | nonHeap
    case objcClassWrapper = 0x305     // 5 | runtimePrivate | nonHeap
    case existentialMetatype = 0x306  // 6 | runtimePrivate | nonHeap
    case heapLocalVariable = 0x400    // 0 | nonType
    case heapGenericLocalVariable = 0x500 // 0 | nonType | runtimePrivate
    case errorObject = 0x501  // 1 | nonType | runtimePrivate
    case unknown = 0xffff
    
    static func kind(of type: Any.Type) -> MetadataKind {
        let kind = swift_getMetadataKind(type)
        return MetadataKind(rawValue: kind) ?? .unknown
    }
}
