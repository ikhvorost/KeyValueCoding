import XCTest
/*@testable*/ import KeyValueCoding


enum TestError: Error, Equatable {
  case fail
}

struct Options: OptionSet {
  let rawValue: Int
  
  static let a = Options(rawValue: 1 << 0)
  static let b = Options(rawValue: 1 << 1)
}

enum Enum: Equatable {
  case a
  case b(Int)
}

class A {
  let a: Int
  
  init(a: Int) {
    self.a = a
  }
}

protocol Props: KeyValueCoding {
  var int: Int { get }
  var float: Float { get }
  var double: Double { get }
  var char: Character { get }
  var string: String { get }
  var staticString: StaticString { get }
  var bool: Bool { get }
  
  var options: Options { get }
  var `enum`: Enum { get }
  var result: Result<Int, TestError> { get }
  var range: Range<Int> { get }
  var closedRange: ClosedRange<Int> { get }
  var tuple: (Int, String) { get }
  
  var arrayInt: [Int] { get }
  var arrayAny: [Any] { get }
  var dictInt: [String : Int] { get }
  var dictAny: [String : Any] { get }
  var setInt: Set<Int> { get }
  
  var optional: Int? { get }
  
  var date: Date { get }
  var lazyInt: Int { mutating get }
  var observed: Int { get }
  
  var classA: A { get }
  
  // TODO
  // weak
  // unownged
  // wrapper
}

struct Struct: Props {
  let int: Int = 1
  let float: Float = 1.0
  let double: Double = 1.0
  let char: Character = "a"
  let string: String = "a"
  let staticString: StaticString = "a"
  let bool: Bool = true
  
  let options: Options = .a
  let `enum`: Enum = .a
  let result: Result<Int, TestError> = .success(200)
  let range: Range = 0..<3
  let closedRange: ClosedRange = 0...3
  let tuple: (Int, String) = (1, "a")
  
  let arrayInt: [Int] = [1, 2]
  let arrayAny: [Any] = [1, "2"]
  let dictInt: [String : Int] = ["a" : 1, "b" : 2]
  let dictAny: [String : Any] = ["a" : 1, "b" : "2"]
  let setInt: Set<Int> = [1, 2]
  
  let optional: Int? = 1
  let date: Date = Date(timeIntervalSince1970: 1000)
  lazy var lazyInt: Int = { XCTFail(); return 1 }()
  
  var observed: Int = 1 {
    willSet { XCTFail() }
    didSet { XCTFail() }
  }
  
  var classA: A = A(a: 1)
}

class Class: Props {
  let int: Int = 1
  let float: Float = 1.0
  let double: Double = 1.0
  let char: Character = "a"
  let string: String = "a"
  let staticString: StaticString = "a"
  let bool: Bool = true
  
  let options: Options = .a
  let `enum`: Enum = .a
  let result: Result<Int, TestError> = .success(200)
  let range: Range = 0..<3
  let closedRange: ClosedRange = 0...3
  let tuple: (Int, String) = (1, "a")
  
  let arrayInt: [Int] = [1, 2]
  let arrayAny: [Any] = [1, "2"]
  let dictInt: [String : Int] = ["a" : 1, "b" : 2]
  let dictAny: [String : Any] = ["a" : 1, "b" : "2"]
  let setInt: Set = [1, 2]
  
  let optional: Int? = 1
  
  let date: Date = Date(timeIntervalSince1970: 1000)
  
  lazy var lazyInt: Int = { XCTFail(); return 1 }()
  var observed: Int = 1 {
    willSet { XCTFail() }
    didSet { XCTFail() }
  }
  
  var classA: A = A(a: 1)
}

class ClassObjc: NSObject, Props {
  @objc let int: Int = 1
  let float: Float = 1.0
  let double: Double = 1.0
  let char: Character = "a"
  let string: String = "a"
  let staticString: StaticString = "a"
  let bool: Bool = true
  
  let options: Options = .a
  let `enum`: Enum = .a
  let result: Result<Int, TestError> = .success(200)
  let range: Range = 0..<3
  let closedRange: ClosedRange = 0...3
  let tuple: (Int, String) = (1, "a")
  
  let arrayInt: [Int] = [1, 2]
  let arrayAny: [Any] = [1, "2"]
  let dictInt: [String : Int] = ["a" : 1, "b" : 2]
  let dictAny: [String : Any] = ["a" : 1, "b" : "2"]
  let setInt: Set = [1, 2]
  
  let optional: Int? = 1
  
  let date: Date = Date(timeIntervalSince1970: 1000)
  
  lazy var lazyInt: Int = { XCTFail(); return 1 }()
  var observed: Int = 1 {
    willSet { XCTFail() }
    didSet { XCTFail() }
  }
  
  var classA: A = A(a: 1)
}

final class KeyValueCodingTests: XCTestCase {
  
  let keyPaths: [AnyKeyPath] = [
    \Props.int,
     \Props.float,
     \Props.double,
     \Props.char,
     \Props.string,
     \Props.staticString,
     \Props.bool,
     \Props.options,
     \Props.`enum`,
     \Props.result,
     \Props.range,
     \Props.closedRange,
     \Props.tuple,
     \Props.arrayInt,
     \Props.arrayAny,
     \Props.dictInt,
     \Props.dictAny,
     \Props.setInt,
     \Props.optional,
     \Props.date,
     \Class.lazyInt,
     \Props.observed,
     \Props.classA,
  ]
  
  let defaultValues: [Any?] = [
    1,
    Float(1.0),
    1.0,
    Character("a"),
    "a",
    StaticString("a"),
    true,
    Options.a,
    Enum.a,
    Result<Int, TestError>.success(200),
    0..<3,
    0...3,
    (1, "a"),
    [1, 2],
    [1, "2"],
    ["a" : 1, "b" : 2],
    ["a" : 1, "b" : "2"],
    Set([1, 2]),
    1,
    Date(timeIntervalSince1970: 1000),
    nil,
    1,
    A(a: 1)
  ]
  
  let wrongValues: [Any?] = [
    "a",
    "a",
    "a",
    1,
    1,
    1,
    "a",
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    "a",
    1,
    "a",
    "a",
    "a",
  ]
  
  let values: [Any?] = [
    2,
    Float(2.0),
    2.0,
    Character("b"),
    "b",
    StaticString("b"),
    false,
    Options.b,
    Enum.b(1),
    Result<Int, TestError>.failure(.fail),
    10..<13,
    10...13,
    (2, "b"),
    [2, 3],
    [2, "3"],
    ["b" : 2, "c" : 3],
    ["b" : 2, "c" : "3"],
    Set([2, 3]),
    nil,
    Date(timeIntervalSince1970: 2),
    2,
    2,
    A(a: 2)
  ]
  
  var objects: [KeyValueCoding] = [Struct(), Class(), ClassObjc()]
  
  func verify(object: inout KeyValueCoding, values: [Any?]) {
    let metadata = object.metadata
    XCTAssert(metadata.properties.count == values.count)
    XCTAssert(metadata.properties.count == keyPaths.count)
    
    zip3(metadata.properties, keyPaths, values).forEach { (prop, keyPath, value) in
      let key = prop.name
      XCTAssert(object[key] == value, key)
      XCTAssert(object[keyPath] == value, "\(keyPath)")
    }
  }
  
  func verify(object: inout Props, values: [Any?]) {
    let metadata = swift_metadata(of: object)
    XCTAssert(metadata.properties.count == values.count)
    XCTAssert(metadata.properties.count == keyPaths.count)
    
    zip3(metadata.properties, keyPaths, values).forEach { (prop, keyPath, value) in
      let key = prop.name
      XCTAssert(swift_value(of: &object, key: key) == value, key)
      XCTAssert(swift_value(of: &object, keyPath: keyPath) == value, "\(keyPath)")
    }
  }
  
  func set(object: inout KeyValueCoding, values: [Any?]) {
    let metadata = object.metadata
    XCTAssert(metadata.properties.count == values.count)
    XCTAssert(metadata.properties.count == keyPaths.count)
    
    zip3(metadata.properties, keyPaths, values).forEach { (prop, keyPath, value) in
      let key = prop.name
      object[key] = value
      object[keyPath] = value
    }
  }
  
  func test_metadata() {
    
    let metadatas: [(kind: Metadata.Kind, type: Any.Type, size: Int)] = [
      (.struct, Struct.self, 272),
      (.class, Class.self, 8),
      (.class, ClassObjc.self, 8),
    ]
    XCTAssert(objects.count == metadatas.count)
    
    zip(objects, metadatas).forEach { (object, item) in
      let metadata = object.metadata
      XCTAssert(metadata.kind == item.kind)
      XCTAssert(metadata.type == item.type)
      XCTAssert(metadata.size == item.size, "\(metadata.size)")
      XCTAssert(metadata.properties.count == 23)
      
      let props: [(name: String, isStrong: Bool, isLazy: Bool, isVar: Bool, type: Any.Type)] = [
        ("int", true, false, false, Int.self),
        ("float", true, false, false, Float.self),
        ("double", true, false, false, Double.self),
        ("char", true, false, false, Character.self),
        ("string", true, false, false, String.self),
        ("staticString", true, false, false, StaticString.self),
        ("bool", true, false, false, Bool.self),
        ("options", true, false, false, Options.self),
        ("enum", true, false, false, Enum.self),
        ("result", true, false, false, Result<Int, TestError>.self),
        ("range", true, false, false, Range<Int>.self),
        ("closedRange", true, false, false, ClosedRange<Int>.self),
        ("tuple", true, false, false, (Int, String).self),
        ("arrayInt", true, false, false, [Int].self),
        ("arrayAny", true, false, false, [Any].self),
        ("dictInt", true, false, false, [String : Int].self),
        ("dictAny", true, false, false, [String : Any].self),
        ("setInt", true, false, false, Set<Int>.self),
        ("optional", true, false, false, Optional<Int>.self),
        ("date", true, false, false, Date.self),
        ("lazyInt", true, true, true, Optional<Int>.self),
        ("observed", true, false, true, Int.self),
        ("classA", true, false, true, A.self),
      ]
      
      XCTAssert(metadata.properties.count == props.count)
      
      zip(metadata.properties, props).forEach { (prop, item) in
        let (name, isStrong, isLazy, isVar, type) = item
        
        XCTAssert(prop.name == name, name)
        XCTAssert(prop.isStrong == isStrong, name)
        XCTAssert(prop.isLazy == isLazy, name)
        XCTAssert(prop.isVar == isVar, name)
        XCTAssert(prop.metadata.type == type, name)
      }
    }
  }
  
  func test_metadata_text() {
    struct A {
      let a = 10
      let b = "b"
    }
    
    let metadata = swift_metadata(of: A.self)
    let description = metadata.description
    XCTAssert("\(description)" == "Metadata(type: A, kind: .struct, size: 24, properties: [Property(name: 'a', isStrong: true, isLazy: false, isVar: false, offset: 0), Property(name: 'b', isStrong: true, isLazy: false, isVar: false, offset: 8)])")
  }
  
  func test_default() {
    objects.indices.forEach {
      verify(object: &objects[$0], values: defaultValues)
    }
  }
  
  func test_default_existensial() {
    var objects: [Props] = [Struct(), Class(), ClassObjc()]
    objects.indices.forEach {
      verify(object: &objects[$0], values: defaultValues)
    }
    
    // Small struct (ExistentialContainerBuffer)
    struct S {
      let a = "a"
    }
    var s: Any = S()
    XCTAssert(swift_value(of: &s, key: "a") == "a")
  }
    
  func test_wrong() {
    objects.indices.forEach {
      set(object: &objects[$0], values: wrongValues)
      verify(object: &objects[$0], values: defaultValues)
    }
  }
  
  func test_values() {
    objects.indices.forEach {
      set(object: &objects[$0], values: values)
      verify(object: &objects[$0], values: values)
      
      var p = objects[$0] as! Props
      XCTAssert(p.int == values[0])
      XCTAssert(p.float == values[1])
      XCTAssert(p.double == values[2])
      XCTAssert(p.char == values[3])
      XCTAssert(p.string == values[4])
      XCTAssert(p.staticString == values[5])
      XCTAssert(p.bool == values[6])
      XCTAssert(p.options == values[7])
      XCTAssert(p.enum == values[8])
      XCTAssert(p.result == values[9])
      XCTAssert(p.range == values[10])
      XCTAssert(p.closedRange == values[11])
      XCTAssert(p.tuple == values[12])
      XCTAssert(p.arrayInt == values[13])
      XCTAssert(p.arrayAny == values[14])
      XCTAssert(p.dictInt == values[15])
      XCTAssert(p.dictAny == values[16])
      XCTAssert(p.setInt == values[17])
      XCTAssert(p.optional == values[18])
      XCTAssert(p.date == values[19])
      XCTAssert(p.lazyInt == values[20])
      XCTAssert(p.observed == values[21])
      XCTAssert(p.classA == values[22])
    }
  }
  
  func test_class_inheritance() {
    class A: KeyValueCoding {
      var a: String = "a"
    }
    
    class B: A {
    }
    
    var b = B()
    XCTAssert(b[\B.a] == "a")
    XCTAssert(b["a"] == "a")
    
    b[\B.a] = "b"
    XCTAssert(b[\B.a] == "b")
    XCTAssert(b["a"] == "b")
    XCTAssert(b.a == "b")
  }
  
  func test_class_override() {
    class A: KeyValueCoding {
      var a: String = "a"
    }
    
    class B: A {
      override var a: String {
        get { return "c" }
        set { XCTFail() }
      }
    }
    
    var b = B()
    XCTAssert(b[\A.a] == "a")
    XCTAssert(b["a"] == "a")
    
    b[\B.a] = "b"
    XCTAssert(b[\B.a] == "b")
    XCTAssert(b["a"] == "b")
    
    XCTAssert(b.a == "c")
  }
  
  func test_computed() {
    struct S: KeyValueCoding {
      var computed: Int { XCTFail(); return 1 }
    }
    
    var s = S()
    XCTAssertNil(s[\S.computed])
    s[\S.computed] = 10
    XCTAssertNil(s[\S.computed])
  }
  
  func test_composition() {
    struct A {
      let a = "a"
      let optA: String? = "a"
    }
    struct B {
      let a = A()
      let optA: A? = A()
    }
    struct C: KeyValueCoding {
      let b = B()
      let optB: B? = B()
    }
    
    var c = C()
    
    XCTAssert(c["b.a.a"] == "a")
    XCTAssert(c[\C.b.a.a] == "a")
    c["b.a.a"] = "b"
    XCTAssert(c["b.a.a"] == "b")
    XCTAssert(c[\C.b.a.a] == "b")
    XCTAssert(c.b.a.a == "b")
    
    XCTAssert(c["optB.optA.optA"] == "a")
    XCTAssert(c[\C.optB?.optA?.optA] == "a")
    c["optB.optA.optA"] = "b"
    XCTAssert(c["optB.optA.optA"] == "b")
    XCTAssert(c[\C.optB?.optA?.optA] == "b")
    XCTAssert(c.optB?.optA?.optA == "b")
  }
  
  func test_lazy() {
    struct A: KeyValueCoding {
      lazy var a: Int = { 1 }()
    }
    
    var a = A()
    XCTAssert(a.a == 1)
    
    a["a"] = 2
    XCTAssert(a["a"] == 2)
    XCTAssert(a.a == 2)
  }
}
