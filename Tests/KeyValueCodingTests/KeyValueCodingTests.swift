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
  
  static let first = Options(rawValue: 1 << 0)
  static let second = Options(rawValue: 1 << 1)
}

enum Enum: Equatable {
  case a
  case b(Int)
}

protocol Props {
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
  
  var `lazy`: Int { mutating get }
  var observed: Int { get }
  var computed: Int { get }
}

struct Struct: Props, KeyValueCoding {
  let int: Int = 1
  let float: Float = 1.0
  let double: Double = 1.0
  let char: Character = "a"
  let string: String = "string"
  let staticString: StaticString = "static"
  let bool: Bool = true
  
  let options: Options = .first
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
  
  lazy var `lazy`: Int = { XCTFail(); return 1 }()
  var observed: Int = 1 {
    willSet { XCTFail() }
    didSet { XCTFail() }
  }
  var computed: Int { XCTFail(); return 1 }
}

class Class: Props, KeyValueCoding {
  let int: Int = 1
  let float: Float = 1.0
  let double: Double = 1.0
  let char: Character = "a"
  let string: String = "string"
  let staticString: StaticString = "static"
  let bool: Bool = true
  
  let options: Options = .first
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
  
  lazy var `lazy`: Int = { XCTFail(); return 1 }()
  var observed: Int = 1 {
    willSet { XCTFail() }
    didSet { XCTFail() }
  }
  var computed: Int { XCTFail(); return 1 }
}

func key(keyPath: AnyKeyPath) -> String {
  let key = "\(keyPath)"
  var index = key.firstIndex(of: ".")!
  index = key.index(index, offsetBy: 1)
  return String(key[index..<key.endIndex])
}

final class _KeyValueCodingTests: XCTestCase {
  
  struct Prop {
    let keyPath: AnyKeyPath
    let value: Any?
  }
  
  func propsEqual<T: KeyValueCoding>(object: inout T, props: [Prop]) {
    props.forEach { prop in
      let key = key(keyPath: prop.keyPath)
      
      XCTAssert(object[key] == prop.value, key)
      //XCTAssert(object[prop.key] as? U == prop.value)
      
      XCTAssert(object.value(key: key) == prop.value, key)
      //XCTAssert(object.value(key: prop.key) as? U == prop.value)
      
      XCTAssert(object[prop.keyPath] == prop.value, key)
      //XCTAssert(object[prop.keyPath] as? U == prop.value)
      
      XCTAssert(object.value(keyPath: prop.keyPath) == prop.value, key)
      //XCTAssert(object.value(keyPath: prop.keyPath) as? U == prop.value)
      
      XCTAssert(swift_value(of: &object, key: key) == prop.value, key)
      //XCTAssert(swift_value(of: &object, key: key) as? U == prop.value)
      
      XCTAssert(swift_value(of: &object, keyPath: prop.keyPath) == prop.value, key)
      //XCTAssert(swift_value(of: &object, keyPath: KeyPath) as? U == prop.value)
    }
  }
  
  func propsSet<T: KeyValueCoding>(object: inout T, props: [Prop]) {
    props.forEach { prop in
      let key = key(keyPath: prop.keyPath)
      
      object[key] = prop.value
      object.setValue(prop.value, key: key)
      
      object[prop.keyPath] = prop.value
      object.setValue(prop.value, keyPath: prop.keyPath)
      
      swift_setValue(prop.value, to: &object, key: key)
      swift_setValue(prop.value, to: &object, keyPath: prop.keyPath)
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
    Prop(keyPath: \Props.options, value: Options.first),
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
    Prop(keyPath: \Class.lazy, value: nil),
    Prop(keyPath: \Props.observed, value: 1),
    Prop(keyPath: \Props.computed, value: nil),
  ]
  
  func test_struct() {
    var object = Struct()
    propsEqual(object: &object, props: props)
  }
  
  func test_class() {
    var object = Class()
    propsEqual(object: &object, props: props)
  }
  
  func test_struct_set_wrong() {
    var object = Struct()
    propsSet(object: &object, props: [
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
      //Prop(keyPath: \Props.tuple, value: (1, "text")),
      Prop(keyPath: \Props.arrayInt, value: ""),
      Prop(keyPath: \Props.arrayAny, value: ""),
      Prop(keyPath: \Props.dictInt, value: ""),
      Prop(keyPath: \Props.dictAny, value: ""),
      Prop(keyPath: \Props.setInt, value: ""),
      Prop(keyPath: \Props.optional, value: ""),
      Prop(keyPath: \Props.date, value: ""),
      //Prop(keyPath: \Struct.lazy, value: nil),
      Prop(keyPath: \Props.observed, value: ""),
      Prop(keyPath: \Props.computed, value: ""),
    ])
    propsEqual(object: &object, props: props)
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
