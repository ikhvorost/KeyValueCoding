import XCTest
import KeyValueCoding
//@testable import KeyValueCoding


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
}

class UserClass: UserProtocol {
    let id = 0
    let name: String? = nil
    let type: UserType = .none
    let array: [Int] = [Int]()
    let classInfo = ClassInfo(phone: "", email: "")
    var classInfoOptional: ClassInfo? = nil
    let structInfo = StructInfo(phone: "", email: "")
    var structInfoOptional: StructInfo? = nil
}

class UserClass2: UserClass {
    let promoCode: Int = 0
}

class UserClassObjC: NSObject, UserProtocol {
    @objc let id = 0
    @objc let name: String? = nil
    let type: UserType = .none
    @objc let array: [Int] = [Int]()
    let classInfo = ClassInfo(phone: "", email: "")
    let classInfoOptional: ClassInfo? = nil
    let structInfo = StructInfo(phone: "", email: "")
    var structInfoOptional: StructInfo? = nil
}

struct UserStruct: UserProtocol {
    let id = 0
    let name: String? = nil
    let type: UserType = .none
    let array: [Int] = [Int]()
    let classInfo = ClassInfo(phone: "", email: "")
    let classInfoOptional: ClassInfo? = nil
    let structInfo = StructInfo(phone: "", email: "")
    var structInfoOptional: StructInfo? = nil
}

protocol SongProtocol: KeyValueCoding {
    var name: String { get set }
}

struct Song: SongProtocol {
    var name: String
}

final class KeyValueCodingTests: XCTestCase {
    
    func test_keyValueCoding<T: UserProtocol>(_ user: inout T, kind: Metadata.Kind, propertiesCount: Int = 8) {
        
        // Metadata
        
        let metadata = swift_metadata(of: user)
        XCTAssert(swift_metadata(of: T.self).kind == kind)
        XCTAssert(metadata.kind == kind)
        XCTAssert(user.metadata.kind == kind)
        
        let properties = metadata.properties
        XCTAssert(properties.count == propertiesCount)
        
        if kind == .class {
            XCTAssert(metadata.size == 8)
        }
        else {
            XCTAssert(metadata.size == 120)
        }
        
        let property = user.metadata.properties[0]
        XCTAssert(property.name == "id")
        XCTAssert(property.metadata.type is Int.Type)
        XCTAssert(property.metadata.type == Int.self)
        XCTAssert(property.isStrong == true)
        XCTAssert(property.isVar == false)
        
        // Nil
        XCTAssertNil(user[""])
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
        XCTAssert(swift_value(of: &user, key: "type") as? UserType == .user)
        XCTAssert(swift_value(of: &user, key: "array") as? [Int] == array)
        XCTAssert(swift_value(of: &user, key: "classInfo") as? ClassInfo == classInfo)
        XCTAssert(swift_value(of: &user, key: "classInfoOptional") as? ClassInfo == classInfo)
        XCTAssert(swift_value(of: &user, key: "structInfo") as? StructInfo == structInfo)
        XCTAssert(swift_value(of: &user, key: "structInfoOptional") as? StructInfo == structInfo)
        
        XCTAssertNil(user.value(key: "undefined"))
        XCTAssert(user.value(key: "id") as? Int == 3)
        XCTAssert(user.value(key: "name") as? String == "Alice")
        XCTAssert(user.value(key: "type") as? UserType == .user)
        XCTAssert(user.value(key: "array") as? [Int] == array)
        XCTAssert(user.value(key: "classInfo") as? ClassInfo == classInfo)
        XCTAssert(user.value(key: "classInfoOptional") as? ClassInfo == classInfo)
        XCTAssert(user.value(key: "structInfo") as? StructInfo == structInfo)
        XCTAssert(user.value(key: "structInfoOptional") as? StructInfo == structInfo)
        
        XCTAssertNil(user["undefined"])
        XCTAssert(user["id"] as? Int == 3)
        XCTAssert(user["name"] as? String == "Alice")
        XCTAssert(user["type"] as? UserType == .user)
        XCTAssert(user["array"] as? [Int] == array)
        XCTAssert(user["classInfo"] as? ClassInfo == classInfo)
        XCTAssert(user["classInfoOptional"] as? ClassInfo == classInfo)
        XCTAssert(user["structInfo"] as? StructInfo == structInfo)
        XCTAssert(user["structInfoOptional"] as? StructInfo == structInfo)
        
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
        XCTAssert(user["id"] as? Int == 3)
        XCTAssert(user["name"] as? String == "Alice")
        XCTAssert(user["type"] as? UserType == .user)
        XCTAssert(user["array"] as? [Int] == array)
        XCTAssert(user["classInfo"] as? ClassInfo == classInfo)
        XCTAssert(user["classInfoOptional"] as? ClassInfo == classInfo)
        XCTAssert(user["structInfo"] as? StructInfo == structInfo)
        XCTAssert(user["structInfoOptional"] as? StructInfo == structInfo)
        
        
        // Key path
        
        user["classInfo"] = classInfo
        user["classInfoOptional"] = classInfo
        user["structInfo"] = structInfo
        user["structInfoOptional"] = structInfo
        XCTAssert(user["classInfo.email"] as? String == classInfo.email)
        XCTAssert(user["classInfoOptional.email"] as? String == classInfo.email)
        XCTAssert(user["structInfo.email"] as? String == structInfo.email)
        XCTAssert(user["structInfoOptional.email"] as? String == structInfo.email)
        
        let email = "my@my.com"
        user["classInfo.email"] = email
        user["classInfoOptional.email"] = email
        user["structInfo.email"] = email
        user["structInfoOptional.email"] = email
        XCTAssert(user["classInfo.email"] as? String == email)
        XCTAssert(user["classInfoOptional.email"] as? String == email)
        XCTAssert(user["structInfo.email"] as? String == email)
        XCTAssert(user["structInfoOptional.email"] as? String == email)
                
        user["classInfoOptional"] = nil
        user["structInfoOptional"] = nil
        XCTAssertNil(user["classInfoOptional"])
        XCTAssertNil(user["classInfoOptional.email"])
        XCTAssertNil(user["structInfoOptional"])
        XCTAssertNil(user["structInfoOptional.email"])
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
        test_keyValueCoding(&user, kind: .class, propertiesCount: 9)
        
        user["promoCode"] = 100
        XCTAssert(user["promoCode"] as? Int == 100)
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
        XCTAssert(optional?["id"] as? Int == 123)
        XCTAssert(optional?.value(key: "id") as? Int == 123)
        XCTAssert(swift_value(of: &optional!, key: "id") as? Int == 123)
        
        XCTAssertNil(swift_value(of: &optional, key: "id"))
    }
}
