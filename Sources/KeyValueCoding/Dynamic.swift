//
//  Dynamic.swift
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
internal func _metadataKind(_: Any.Type) -> UInt



/*
typealias MirrorRecursiveCountFunc = @convention(c) (_: Any) -> Int
typealias MirrorRecursiveChildMetadataFunc = @convention(c) (
    _: Any,
    _ index: Int,
    _ fieldMetadata: UnsafeMutablePointer<Any>
) -> Any

typealias MirrorRecursiveChildOffsetFunc = @convention(c) (_: Any, _ index: Int) -> Int

/// Dynamic shared object
class Dynamic {
    
    private static let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
    
    private static func dynamic<T>(symbol: String) -> T {
        guard let sym = dlsym(RTLD_DEFAULT, symbol) else {
            fatalError("\(symbol) is NOT found!")
        }
        return unsafeBitCast(sym, to: T.self)
    }
   
    // Functions
    static let mirrorRecursiveCount: MirrorRecursiveCountFunc = dynamic(symbol: "swift_reflectionMirror_recursiveCount")
    static let mirrorRecursiveChildMetadata: MirrorRecursiveChildMetadataFunc = dynamic(symbol: "swift_reflectionMirror_recursiveChildMetadata")
    static let mirrorRecursiveChildOffset: MirrorRecursiveChildOffsetFunc = dynamic(symbol: "swift_reflectionMirror_recursiveChildOffset")
}
 */
