import XCTest
import KeyValueCoding
//@testable import KeyValueCoding


enum UserType {
    case none
    case guest
    case user
    case admin
}

protocol User: KeyValueCoding {
    var id: Int { get }
    var name: String? { get }
    var type: UserType { get }
}

class UserClass: User {
    let id = 0
    let name: String? = nil
    let type: UserType = .none
}

class UserClass2: UserClass {
    let promoCode: Int = 0
}

class UserClassObjC: NSObject, User {
    @objc let id = 0
    @objc let name: String? = nil
    let type: UserType = .none
}

struct UserStruct: User {
    let id = 0
    let name: String? = nil
    let type: UserType = .none
}

final class KeyValueCodingTests: XCTestCase {
    
    func test_keyValueCoding<T: User>(_ instance: inout T, kind: MetadataKind, propertiesCount: Int = 3) {
        // Metadata
        
        XCTAssert(swift_metadataKind(of: type(of: instance)) == kind)
        XCTAssert(swift_metadataKind(of: instance) == kind)
        XCTAssert(instance.metadataKind == kind)
        
        // Properties
        
        XCTAssert(swift_properties(of: type(of: instance)).count == propertiesCount)
        XCTAssert(swift_properties(of: instance).count == propertiesCount)
        XCTAssert(instance.properties.count == propertiesCount)
        
        let property = instance.properties[0]
        XCTAssert(property.name == "id")
        XCTAssert(property.type is Int.Type)
        XCTAssert(property.isStrong)
        XCTAssert(property.isVar == false)
        
        // Set value
        
        swift_setValue(1, instance: &instance, key: "id")
        swift_setValue("Bob", instance: &instance, key: "name")
        swift_setValue(UserType.admin, instance: &instance, key: "type")
        XCTAssert(instance.id == 1)
        XCTAssert(instance.name == "Bob")
        XCTAssert(instance.type == .admin)
        
        instance.setValue(2, key: "id")
        instance.setValue("John", key: "name")
        instance.setValue(UserType.guest, key: "type")
        XCTAssert(instance.id == 2)
        XCTAssert(instance.name == "John")
        XCTAssert(instance.type == .guest)
        
        instance["id"] = 3
        instance["name"] = "Alice"
        instance["type"] = UserType.user
        XCTAssert(instance.id == 3)
        XCTAssert(instance.name == "Alice")
        XCTAssert(instance.type == .user)
        
        // Get value
        
        XCTAssertNil(swift_value(of: &instance, key: "undefined"))
        XCTAssert(swift_value(of: &instance, key: "id") as? Int == 3)
        XCTAssert(swift_value(of: &instance, key: "name") as? String == "Alice")
        XCTAssert(swift_value(of: &instance, key: "type") as? UserType == .user)
        
        XCTAssertNil(instance.value(key: "undefined"))
        XCTAssert(instance.value(key: "id") as? Int == 3)
        XCTAssert(instance.value(key: "name") as? String == "Alice")
        XCTAssert(instance.value(key: "type") as? UserType == .user)
        
        XCTAssertNil(instance["undefined"])
        XCTAssert(instance["id"] as? Int == 3)
        XCTAssert(instance["name"] as? String == "Alice")
        XCTAssert(instance["type"] as? UserType == .user)
    }
    
    func test_class() {
        var user = UserClass()
        test_keyValueCoding(&user, kind: .class)
    }
    
    func test_class_inheritance() {
        var user = UserClass2()
        test_keyValueCoding(&user, kind: .class, propertiesCount: 4)
        
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
    }
}
