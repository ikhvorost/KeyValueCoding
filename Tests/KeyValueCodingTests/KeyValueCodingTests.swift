import XCTest
/*@testable*/ import KeyValueCoding


enum TestError: Error, Equatable {}

extension StaticString : Equatable {
  public static func == (lhs: StaticString, rhs: StaticString) -> Bool {
    "\(lhs)" == "\(rhs)"
  }
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
}

struct Struct: Props {
  let int: Int = 1
  let float: Float = 1.0
  let double: Double = 1.0
  let char: Character = "a"
  let string: String = "string"
  let staticString: StaticString = "static"
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
}

class Class: Props {
  let int: Int = 1
  let float: Float = 1.0
  let double: Double = 1.0
  let char: Character = "a"
  let string: String = "string"
  let staticString: StaticString = "static"
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
}

fileprivate func key(keyPath: AnyKeyPath) -> String {
  var key = "\(keyPath)"
  let index = key.firstIndex(of: ".")!
  key = String(key[key.index(index, offsetBy: 1)..<key.endIndex])
  return key.replacingOccurrences(of: #"[\?\!]"#, with: "", options: [.regularExpression])
}

final class _KeyValueCodingTests: XCTestCase {
  
  struct Prop {
    let keyPath: AnyKeyPath
    let value: Any?
  }
  
  func propsEqual(object: inout any KeyValueCoding, props: [Prop]) {
    props.forEach { prop in
      let key = key(keyPath: prop.keyPath)
      
      XCTAssert(object[key] == prop.value, key)
      XCTAssert(object[prop.keyPath] == prop.value, key)
    }
  }
  
  func propsSet(object: inout any KeyValueCoding, props: [Prop]) {
    props.forEach { prop in
      let key = key(keyPath: prop.keyPath)
      
      object[key] = prop.value
      //object.setValue(prop.value, key: key)
      //swift_setValue(prop.value, to: &object, key: key)
      
      object[prop.keyPath] = prop.value
      //object.setValue(prop.value, keyPath: prop.keyPath)
      //swift_setValue(prop.value, to: &object, keyPath: prop.keyPath)
    }
  }
  
  let props = [
    Prop(keyPath: \Props.int, value: 1),
    Prop(keyPath: \Props.float, value: Float(1.0)),
    Prop(keyPath: \Props.double, value: 1.0),
    Prop(keyPath: \Props.char, value: Character("a")),
    Prop(keyPath: \Props.string, value: "string"),
    Prop(keyPath: \Props.staticString, value: StaticString("static")),
    Prop(keyPath: \Props.bool, value: true),
    Prop(keyPath: \Props.options, value: Options.a),
    Prop(keyPath: \Props.enum, value: Enum.a),
    Prop(keyPath: \Props.result, value: Result<Int, TestError>.success(200)),
    Prop(keyPath: \Props.range, value: 0..<3),
    Prop(keyPath: \Props.closedRange, value: 0...3),
    Prop(keyPath: \Props.tuple, value: (1, "a")),
    Prop(keyPath: \Props.arrayInt, value: [1, 2]),
    Prop(keyPath: \Props.arrayAny, value: [1, "2"]),
    Prop(keyPath: \Props.dictInt, value: ["a" : 1, "b" : 2]),
    Prop(keyPath: \Props.dictAny, value: ["a" : 1, "b" : "2"]),
    Prop(keyPath: \Props.setInt, value: Set([1, 2])),
    Prop(keyPath: \Props.optional, value: 1),
    Prop(keyPath: \Props.optional, value: Optional<Int>.some(1)),
    Prop(keyPath: \Props.date, value: Date(timeIntervalSince1970: 1000)),
    Prop(keyPath: \Class.lazyInt, value: nil),
    Prop(keyPath: \Props.observed, value: 1),
  ]
  
  /*
  class A {
    let i: Int
    
    init(i: Int) {
      self.i = i
    }
  }
  
  func test_weak() {
    struct B: KeyValueCoding {
      weak var a: A?
      //var a: A?
    }
    
    var b = B()
    let a = A(i: 20)
    
    //print(b[\B.a])
    b.a = a
    print(b[\B.a])
    
    //    b["a"] = a
    //    print(b.a?.i)
  }
  
  func test_unowned() {
    struct B: KeyValueCoding {
      unowned var a: A?
    }
    
    var b = B()
    let a = A(i: 10)
    
    b.a = a
    print(b["a.i"])
    
//    b["a"] = a
//    print(b.a?.i)
  }
  
  
  @propertyWrapper 
  struct Wrapper {
    var value: Int = 0
    
    var wrappedValue: Int {
      get { value }
      set { value = newValue * 10 }
    }
    
    init(wrappedValue defaultValue: Int) {
      self.value = wrappedValue
    }
  }
  
  func test_property_wrapper() {
    struct B: KeyValueCoding {
      @Wrapper
      var i: Int = 0
    }
    
    var b = B()
    
    //let props = b.metadata.properties
    let props = swift_metadata(of: Wrapper.self)
    
    //b.i = 10
    b["_i"] = 10
    //b.i = 11
    
    //print(b["_i"])
    print(b.i)
  }
  */
  
  func test_struct_metadata() {
    let object = Struct()
    
    XCTAssert(object.metadata.kind == .struct)
    XCTAssert(object.metadata.type == Struct.self)
    XCTAssert(object.metadata.size == 264)
    XCTAssert(object.metadata.properties.count == 22)
    
    let props: [(name: String, isStrong: Bool, isVar: Bool, type: Any.Type)] = [
      ("int", true, false, Int.self),
      ("float", true, false, Float.self),
      ("double", true, false, Double.self),
      ("char", true, false, Character.self),
      ("string", true, false, String.self),
      ("staticString", true, false, StaticString.self),
      ("bool", true, false, Bool.self),
      ("options", true, false, Options.self),
      ("enum", true, false, Enum.self),
      ("result", true, false, Result<Int, TestError>.self),
      ("range", true, false, Range<Int>.self),
      ("closedRange", true, false, ClosedRange<Int>.self),
      ("tuple", true, false, (Int, String).self),
      ("arrayInt", true, false, [Int].self),
      ("arrayAny", true, false, [Any].self),
      ("dictInt", true, false, [String : Int].self),
      ("dictAny", true, false, [String : Any].self),
      ("setInt", true, false, Set<Int>.self),
      ("optional", true, false, Optional<Int>.self),
      ("date", true, false, Date.self),
      ("lazyInt", true, true, Optional<Int>.self),
      ("observed", true, true, Int.self),
    ]
    
    zip(object.metadata.properties, props).forEach { (prop, item) in
      let (name, isStrong, isVar, type) = item
      
      XCTAssert(prop.name == name, name)
      XCTAssert(prop.isStrong == isStrong, name)
      XCTAssert(prop.isVar == isVar, name)
      XCTAssert(prop.metadata.type == type, name)
    }
  }
  
  func test_struct() {
    var object: any KeyValueCoding = Struct()
    propsEqual(object: &object, props: props)
  }
  
  func test_struct_set_wrong_values() {
    var object: any KeyValueCoding = Struct()
    
    let props2: [Prop] = [
      Prop(keyPath: \Props.int, value: ""),
      Prop(keyPath: \Props.float, value: ""),
      Prop(keyPath: \Props.double, value: ""),
      Prop(keyPath: \Props.char, value: 1),
      Prop(keyPath: \Props.string, value: 1),
      Prop(keyPath: \Props.staticString, value: 1),
      Prop(keyPath: \Props.bool, value: ""),
      Prop(keyPath: \Props.options, value: ""),
      Prop(keyPath: \Props.enum, value: ""),
      Prop(keyPath: \Props.result, value: ""),
      Prop(keyPath: \Props.range, value: ""),
      Prop(keyPath: \Props.closedRange, value: ""),
      Prop(keyPath: \Props.tuple, value: ""),
      Prop(keyPath: \Props.arrayInt, value: ""),
      Prop(keyPath: \Props.arrayAny, value: ""),
      Prop(keyPath: \Props.dictInt, value: ""),
      Prop(keyPath: \Props.dictAny, value: ""),
      Prop(keyPath: \Props.setInt, value: ""),
      Prop(keyPath: \Props.optional, value: ""),
      Prop(keyPath: \Props.date, value: ""),
      Prop(keyPath: \Class.lazyInt, value: ""),
      Prop(keyPath: \Props.observed, value: ""),
    ]
    propsSet(object: &object, props: props2)
    propsEqual(object: &object, props: props)
  }
  
  func test_struct_set_values() {
    var object: any KeyValueCoding = Struct()
    
    let props: [Prop] = [
      Prop(keyPath: \Props.int, value: 2),
      Prop(keyPath: \Props.float, value: Float(2.0)),
      Prop(keyPath: \Props.double, value: 2.0),
      Prop(keyPath: \Props.char, value: Character("b")),
      Prop(keyPath: \Props.string, value: "b"),
      Prop(keyPath: \Props.staticString, value: StaticString("b")),
      Prop(keyPath: \Props.bool, value: false),
      Prop(keyPath: \Props.options, value: Options.b),
      Prop(keyPath: \Props.enum, value: Enum.b(10)),
      Prop(keyPath: \Props.result, value: Result<Int, TestError>.success(500)),
      Prop(keyPath: \Props.range, value: 10..<20),
      Prop(keyPath: \Props.closedRange, value: 10...20),
      Prop(keyPath: \Props.tuple, value: (2, "b")),
      Prop(keyPath: \Props.arrayInt, value: [10, 11]),
      Prop(keyPath: \Props.arrayAny, value: [10, "11"]),
      Prop(keyPath: \Props.dictInt, value: ["c" : 2, "d" : 3]),
      Prop(keyPath: \Props.dictAny, value: ["c" : 2, "d" : "3"]),
      Prop(keyPath: \Props.setInt, value: Set([10, 11])),
      Prop(keyPath: \Props.optional, value: 2),
      Prop(keyPath: \Props.date, value: Date(timeIntervalSince1970: 2000)),
      Prop(keyPath: \Class.lazyInt, value: 2),
      Prop(keyPath: \Props.observed, value: 2),
    ]
    propsSet(object: &object, props: props)
    propsEqual(object: &object, props: props)
    
    var s = object as! Props
    XCTAssert(s.int == 2)
    XCTAssert(s.float == 2.0)
    XCTAssert(s.double == 2.0)
    XCTAssert(s.char == "b")
    XCTAssert(s.string == "b")
    XCTAssert(s.staticString == "b")
    XCTAssert(s.bool == false)
    XCTAssert(s.options == .b)
    XCTAssert(s.enum == .b(10))
    XCTAssert(s.result == .success(500))
    XCTAssert(s.range == 10..<20)
    XCTAssert(s.closedRange  == 10...20)
    XCTAssert(s.tuple == (2, "b"))
    XCTAssert(s.arrayInt == [10, 11])
    XCTAssert(s.arrayAny == [10, "11"])
    XCTAssert(s.dictInt == ["c" : 2, "d" : 3])
    XCTAssert(s.dictAny == ["c" : 2, "d" : "3"])
    XCTAssert(s.setInt == [10, 11])
    XCTAssert(s.optional == 2)
    XCTAssert(s.date == Date(timeIntervalSince1970: 2000))
    XCTAssert(s.lazyInt == 2)
    XCTAssert(s.observed == 2)
  }
  
  func test_struct_key_path() {
    class Class2 {
      let s = Class()
    }
    struct Struct2: KeyValueCoding {
      let s = Struct()
    }
    var object: any KeyValueCoding = Struct2()
    
    let props = [
      Prop(keyPath: \Struct2.s.int, value: 1),
      Prop(keyPath: \Struct2.s.float, value: Float(1.0)),
      Prop(keyPath: \Struct2.s.double, value: 1.0),
      Prop(keyPath: \Struct2.s.char, value: Character("a")),
      Prop(keyPath: \Struct2.s.string, value: "string"),
      Prop(keyPath: \Struct2.s.staticString, value: StaticString("static")),
      Prop(keyPath: \Struct2.s.bool, value: true),
      Prop(keyPath: \Struct2.s.options, value: Options.a),
      Prop(keyPath: \Struct2.s.enum, value: Enum.a),
      Prop(keyPath: \Struct2.s.result, value: Result<Int, TestError>.success(200)),
      Prop(keyPath: \Struct2.s.range, value: 0..<3),
      Prop(keyPath: \Struct2.s.closedRange, value: 0...3),
      Prop(keyPath: \Struct2.s.tuple, value: (1, "a")),
      Prop(keyPath: \Struct2.s.arrayInt, value: [1, 2]),
      Prop(keyPath: \Struct2.s.arrayAny, value: [1, "2"]),
      Prop(keyPath: \Struct2.s.dictInt, value: ["a" : 1, "b" : 2]),
      Prop(keyPath: \Struct2.s.dictAny, value: ["a" : 1, "b" : "2"]),
      Prop(keyPath: \Struct2.s.setInt, value: Set([1, 2])),
      Prop(keyPath: \Struct2.s.optional, value: 1),
      Prop(keyPath: \Struct2.s.optional, value: Optional<Int>.some(1)),
      Prop(keyPath: \Struct2.s.date, value: Date(timeIntervalSince1970: 1000)),
      Prop(keyPath: \Class2.s.lazyInt, value: nil),
      Prop(keyPath: \Struct2.s.observed, value: 1),
    ]
    
    propsEqual(object: &object, props: props)
  }
  
  func test_struct_optional_key_path() {
    class S: KeyValueCoding {
      let i: Int? = nil
      lazy var a: Int = { XCTFail(); return 11 }()
    }
    
    var s = S()
    
    XCTAssert(s[\S.i] == nil)
    s[\S.i] = 1
    XCTAssert(s[\S.i] == 1)
    XCTAssert(s.i == 1)
    
    XCTAssert(s[\S.a] == nil)
    s[\S.a] = 2
    XCTAssert(s[\S.a] == 2)
    XCTAssert(s.a == 2)
  }
  
  func test_class() {
    var object: any KeyValueCoding = Class()
    propsEqual(object: &object, props: props)
  }
  
  func test_class_inheritance() {
    class Class2: Class {
    }
    
    var c: any KeyValueCoding = Class2()
    propsEqual(object: &c, props: props)
  }
  
  func test_class_override() {
    class C1: KeyValueCoding {
      var a: String = "C1"
    }
    
    class C2: C1 {
      override var a: String {
        get { XCTFail(); return "C2" }
        set { XCTFail() }
      }
    }
    
    var c1 = C1()
    XCTAssert(c1[\C1.a] == "C1")
    
    var c2 = C2()
    XCTAssert(c2[\C2.a] == "C1")
    c2[\C2.a] = "C11"
    XCTAssert(c2[\C2.a] == "C11")
  }
  
  func test_class_objc() {
    class C: NSObject, KeyValueCoding {
      let a = 1
      @objc let b = 2
    }
    
    var c = C()
    XCTAssert(c[\C.a] == 1)
    XCTAssert(c[\C.b] == 2)
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
}


enum UserType {
  case none
  case guest
  case user
  case admin
}

class ClassInfo: Equatable {
  let phone: String
  let email: String
  
  init(phone: String, email: String) {
    self.phone = phone
    self.email = email
  }
  
  static func == (lhs: ClassInfo, rhs: ClassInfo) -> Bool {
    lhs.phone == rhs.phone && lhs.email == rhs.email
  }
}

struct StructInfo: Equatable {
  let phone: String
  let email: String
}

protocol UserProtocol: KeyValueCoding {
  var id: Int { get }
  var name: String? { get }
  var type: UserType { get }
  var array: [Int] { get }
  var classInfo: ClassInfo { get }
  var classInfoOptional: ClassInfo? { get }
  var structInfo: StructInfo { get }
  var structInfoOptional: StructInfo? { get }
  var observed: Int { get set }
  var computed: Int { get }
}

class UserClass: UserProtocol {
  let id = 0
  let name: String? = nil
  var type: UserType = .none
  let array: [Int] = [Int]()
  let classInfo = ClassInfo(phone: "", email: "")
  var classInfoOptional: ClassInfo? = nil
  let structInfo = StructInfo(phone: "", email: "")
  var structInfoOptional: StructInfo? = nil
  var observed: Int = 0 {
    willSet { XCTFail() }
    didSet { XCTFail() }
  }
  var computed: Int {
    XCTFail();
    return 0
  }
}

class UserClass2: UserClass {
  private let promoCode: Int = 0
}

class UserClassObjC: NSObject, UserProtocol {
  @objc let id = 0
  @objc let name: String? = nil
  var type: UserType = .none
  @objc let array: [Int] = [Int]()
  let classInfo = ClassInfo(phone: "", email: "")
  let classInfoOptional: ClassInfo? = nil
  let structInfo = StructInfo(phone: "", email: "")
  var structInfoOptional: StructInfo? = nil
  var observed: Int = 0 {
    willSet { XCTFail() }
    didSet { XCTFail() }
  }
  var computed: Int {
    XCTFail();
    return 0
  }
}

struct UserStruct: UserProtocol {
  let id = 0
  let name: String? = nil
  var type: UserType = .none
  let array: [Int] = [Int]()
  let classInfo = ClassInfo(phone: "", email: "")
  let classInfoOptional: ClassInfo? = nil
  let structInfo = StructInfo(phone: "", email: "")
  var structInfoOptional: StructInfo? = nil
  var observed: Int = 0 {
    willSet { XCTFail() }
    didSet { XCTFail() }
  }
  var computed: Int {
    XCTFail();
    return 0
  }
}

protocol SongProtocol: KeyValueCoding {
  var name: String { get set }
}

struct Song: SongProtocol {
  var name: String
}

final class KeyValueCodingTests: XCTestCase {
  
  func test_keyValueCoding<T: UserProtocol>(_ user: inout T, kind: Metadata.Kind, propertiesCount: Int = 9) {
    
    // Metadata
    
    let metadata = swift_metadata(of: user)
    XCTAssert(swift_metadata(of: T.self).kind == kind)
    XCTAssert(metadata.kind == kind)
    XCTAssert(user.metadata.kind == kind)
    XCTAssert(metadata.description.hasPrefix("Metadata(type: \(String(describing: metadata.type)), kind: .\(kind), size: \(metadata.size)"))
    
    let properties = metadata.properties
    XCTAssert(properties.count == propertiesCount)
    
    if kind == .class {
      XCTAssert(metadata.size == 8)
    }
    else {
      XCTAssert(metadata.size == 128)
    }
    
    let property = user.metadata.properties[0]
    XCTAssert(property.name == "id")
    XCTAssert(property.metadata.type is Int.Type)
    XCTAssert(property.metadata.type == Int.self)
    XCTAssert(property.isStrong == true)
    XCTAssert(property.isVar == false)
    XCTAssert(property.description == "Property(name: \'id\', isStrong: true, isVar: false, offset: \(property.offset))")
    
    // Nil
    XCTAssertNil(user[""])
    XCTAssertNil(user["."])
    XCTAssertNil(user["..."])
    XCTAssertNil(user["undefined"])
    XCTAssertNil(user["name"])
    XCTAssertNil(user["classInfo.undefined"])
    XCTAssertNil(user["classInfoOptional"])
    XCTAssertNil(user["classInfoOptional.undefined"])
    XCTAssertNil(user["classInfoOptional.email"])
    XCTAssertNil(user["structInfoOptional"])
    XCTAssertNil(user["structInfoOptional.undefined"])
    XCTAssertNil(user["structInfoOptional.email"])
    
    // Set value
    
    let array = [1, 2, 3]
    let classInfo = ClassInfo(phone: "1234567890", email: "mail@domain.com")
    let structInfo = StructInfo(phone: "1234567890", email: "mail@domain.com")
    
    swift_setValue(1, to: &user, key: "id")
    swift_setValue("Bob", to: &user, key: "name")
    swift_setValue(UserType.admin, to: &user, key: "type")
    swift_setValue(array, to: &user, key: "array")
    swift_setValue(classInfo, to: &user, key: "classInfo")
    swift_setValue(classInfo, to: &user, key: "classInfoOptional")
    swift_setValue(structInfo, to: &user, key: "structInfo")
    swift_setValue(structInfo, to: &user, key: "structInfoOptional")
    XCTAssert(user.id == 1)
    XCTAssert(user.name == "Bob")
    XCTAssert(user.type == .admin)
    XCTAssert(user.array == array)
    XCTAssert(user.classInfo == classInfo)
    XCTAssert(user.classInfoOptional == classInfo)
    XCTAssert(user.structInfo == structInfo)
    XCTAssert(user.structInfoOptional == structInfo)
    
    user.setValue(2, key: "id")
    user.setValue(nil, key: "name")
    user.setValue(UserType.guest, key: "type")
    user.setValue([], key: "array")
    user.setValue(ClassInfo(phone:"", email: ""), key: "classInfo")
    user.setValue(ClassInfo(phone:"", email: ""), key: "classInfoOptional")
    user.setValue(StructInfo(phone:"", email: ""), key: "structInfo")
    user.setValue(StructInfo(phone:"", email: ""), key: "structInfoOptional")
    XCTAssert(user.id == 2)
    XCTAssert(user.name == nil)
    XCTAssert(user.type == .guest)
    XCTAssert(user.array == [])
    XCTAssert(user.classInfo == ClassInfo(phone:"", email: ""))
    XCTAssert(user.classInfoOptional == ClassInfo(phone:"", email: ""))
    XCTAssert(user.structInfo == StructInfo(phone:"", email: ""))
    XCTAssert(user.structInfoOptional == StructInfo(phone:"", email: ""))
    
    user[""] = ""
    user["id"] = 3
    user["name"] = "Alice"
    user["type"] = UserType.user
    user["array"] = array
    user["classInfo"] = classInfo
    user["classInfoOptional"] = classInfo
    user["structInfo"] = structInfo
    user["structInfoOptional"] = structInfo
    XCTAssert(user.id == 3)
    XCTAssert(user.name == "Alice")
    XCTAssert(user.type == .user)
    XCTAssert(user.array == array)
    XCTAssert(user.classInfo == classInfo)
    XCTAssert(user.classInfoOptional == classInfo)
    XCTAssert(user.structInfo == structInfo)
    XCTAssert(user.structInfoOptional == structInfo)
    
    // Get value
    
    XCTAssertNil(swift_value(of: &user, key: "undefined"))
    XCTAssert(swift_value(of: &user, key: "id") as? Int == 3)
    XCTAssert(swift_value(of: &user, key: "name") as? String == "Alice")
    XCTAssert(swift_value(of: &user, key: "type") as? UserType == UserType.user)
    XCTAssert(swift_value(of: &user, key: "array") as? [Int] == array)
    XCTAssert(swift_value(of: &user, key: "classInfo") as? ClassInfo  == classInfo)
    XCTAssert(swift_value(of: &user, key: "classInfoOptional") as? ClassInfo == classInfo)
    XCTAssert(swift_value(of: &user, key: "structInfo") as? StructInfo == structInfo)
    XCTAssert(swift_value(of: &user, key: "structInfoOptional") as? StructInfo == structInfo)
    
    XCTAssertNil(user.value(key: "undefined"))
    XCTAssert(user.value(key: "id") == 3)
    XCTAssert(user.value(key: "name") == "Alice")
    XCTAssert(user.value(key: "type") == UserType.user)
    XCTAssert(user.value(key: "array") == array)
    XCTAssert(user.value(key: "classInfo") == classInfo)
    XCTAssert(user.value(key: "classInfoOptional") == classInfo)
    XCTAssert(user.value(key: "structInfo") == structInfo)
    XCTAssert(user.value(key: "structInfoOptional") == structInfo)
    
    XCTAssertNil(user["undefined"])
    XCTAssert(user["id"] == 3)
    XCTAssert(user["name"] == "Alice")
    XCTAssert(user["type"] == UserType.user)
    XCTAssert(user["array"] == array)
    XCTAssert(user["classInfo"] == classInfo)
    XCTAssert(user["classInfoOptional"] == classInfo)
    XCTAssert(user["structInfo"] == structInfo)
    XCTAssert(user["structInfoOptional"] == structInfo)
    
    // Set wrong type
    
    user["id"] = "Hello"
    user["name"] = 11
    user["type"] = nil
    user["array"] = ["1", "2"]
    user["classInfo"] = "123"
    user["classInfo.phone"] = 10
    user["classInfoOptioanal"] = "123"
    user["classInfoOptioanal.phone"] = 10
    user["structInfo"] = "123"
    user["structInfo.phone"] = 10
    user["structInfoOptioanal"] = "123"
    user["structInfoOptioanal.phone"] = 10
    XCTAssert(user["id"] == 3)
    XCTAssert(user["name"] == "Alice")
    XCTAssert(user["type"] == UserType.user)
    XCTAssert(user["array"] == array)
    XCTAssert(user["classInfo"] == classInfo)
    XCTAssert(user["classInfoOptional"] == classInfo)
    XCTAssert(user["structInfo"] == structInfo)
    XCTAssert(user["structInfoOptional"] == structInfo)
    
    
    // Key path
    
    user["classInfo"] = classInfo
    user["classInfoOptional"] = classInfo
    user["structInfo"] = structInfo
    user["structInfoOptional"] = structInfo
    XCTAssert(user["classInfo.email"] == classInfo.email)
    XCTAssert(user["classInfoOptional.email"] == classInfo.email)
    XCTAssert(user["structInfo.email"] == structInfo.email)
    XCTAssert(user["structInfoOptional.email"] == structInfo.email)
    
    let email = "my@my.com"
    user["classInfo.email"] = email
    user["classInfoOptional.email"] = email
    user["structInfo.email"] = email
    user["structInfoOptional.email"] = email
    XCTAssert(user["classInfo.email"] == email)
    XCTAssert(user["classInfoOptional.email"] == email)
    XCTAssert(user["structInfo.email"] == email)
    XCTAssert(user["structInfoOptional.email"] == email)
    
    user["classInfoOptional"] = nil
    user["structInfoOptional"] = nil
    XCTAssertNil(user["classInfoOptional"])
    XCTAssertNil(user["classInfoOptional.email"])
    XCTAssertNil(user["structInfoOptional"])
    XCTAssertNil(user["structInfoOptional.email"])
    
    // Observed
    user["observed"] = 10
    
    // Computed
    user["computed"] = 100
    XCTAssertNil(user["computed"])
  }
  
  func test_class() {
    var user = UserClass()
    test_keyValueCoding(&user, kind: .class)
    
    // Existential
    /*
     var p: UserProtocol = user
     swift_setValue(777, to: &p, key: "id")
     XCTAssert(swift_value(of: &p, key: "id") as? Int == 777)
     */
  }
  
  func test_class_inheritance() {
    var user = UserClass2()
    test_keyValueCoding(&user, kind: .class, propertiesCount: 10)
    
    user["id"] = 100
    user["name"] = "Jack"
    XCTAssert(user["id"] == 100)
    XCTAssert(user["name"] == "Jack")
    
    // Private
    user["promoCode"] = 100
    XCTAssert(user["promoCode"] == 100)
  }
  
  func test_class_objc() {
    var user = UserClassObjC()
    test_keyValueCoding(&user, kind: .class)
  }
  
  func test_struct() {
    var user = UserStruct()
    test_keyValueCoding(&user, kind: .struct)
    
    // Existential
    /*
     var p: UserProtocol = user
     swift_setValue(777, to: &p, key: "id")
     XCTAssert(swift_value(of: &p, key: "id") as? Int == 777)
     */
    
    var song: SongProtocol = Song(name: "")
    swift_setValue("Blue Suede Shoes", to: &song, key: "name")
    XCTAssert(swift_value(of: &song, key: "name") as? String == "Blue Suede Shoes")
  }
  
  func test_optional() {
    var optional: UserClass? = UserClass()
    test_keyValueCoding(&optional!, kind: .class)
    
    optional?["id"] = 123
    XCTAssert(optional?["id"] == 123)
    XCTAssert(optional?.value(key: "id") == 123)
    XCTAssert(swift_value(of: &optional!, key: "id") as? Int == 123)
    
    XCTAssertNil(swift_value(of: &optional, key: "id"))
  }
}
