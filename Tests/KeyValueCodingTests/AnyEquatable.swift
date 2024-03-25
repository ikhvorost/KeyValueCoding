//
//  AnyEquatable.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 2024/03/25.
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


fileprivate extension Equatable {
  func isEqual(to: Any) -> Bool {
    self == to as? Self
  }
}

func ==<T>(lhs: T?, rhs: T?) -> Bool where T: Any {
  guard let lhs, let rhs else {
    return lhs == nil && rhs == nil
  }
  
  // Equatable
  if let isEqual = (lhs as? any Equatable)?.isEqual {
    return isEqual(rhs)
  }
  // [Any]
  else if let lhs = lhs as? [Any], let rhs = rhs as? [Any], lhs.count == rhs.count {
    return lhs.elementsEqual(rhs, by: ==)
  }
  // [AnyHashable: Any]
  else if let lhs = lhs as? [AnyHashable: Any], let rhs = rhs as? [AnyHashable: Any], lhs.count == rhs.count {
    return lhs.allSatisfy { $1 == rhs[$0] }
  }
  // (Any,...)
  else {
    let ml = Mirror(reflecting: lhs)
    let mr = Mirror(reflecting: rhs)
    guard ml.children.count == mr.children.count else {
      return false
    }
    return zip(ml.children, mr.children).allSatisfy { $0.value == $1.value }
  }
}
