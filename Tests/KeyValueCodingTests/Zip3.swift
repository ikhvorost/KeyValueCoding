//
//  Zip3.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 2024/05/16.
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

import Foundation


struct Zip3Sequence<E1, E2, E3>: Sequence, IteratorProtocol {
  private let _next: () -> (E1, E2, E3)?
  
  init<S1: Sequence, S2: Sequence, S3: Sequence>(_ s1: S1, _ s2: S2, _ s3: S3) where S1.Element == E1, S2.Element == E2, S3.Element == E3 {
    var it1 = s1.makeIterator()
    var it2 = s2.makeIterator()
    var it3 = s3.makeIterator()
    _next = {
      guard let e1 = it1.next(), let e2 = it2.next(), let e3 = it3.next() else { return nil }
      return (e1, e2, e3)
    }
  }
  
  mutating func next() -> (E1, E2, E3)? {
    return _next()
  }
}

func zip3<S1: Sequence, S2: Sequence, S3: Sequence>(_ s1: S1, _ s2: S2, _ s3: S3) -> Zip3Sequence<S1.Element, S2.Element, S3.Element> {
  return Zip3Sequence(s1, s2, s3)
}
