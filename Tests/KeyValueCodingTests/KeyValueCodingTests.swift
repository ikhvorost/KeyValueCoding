import XCTest
import KeyValueCoding
//@testable import KeyValueCoding


enum UserType {
    case admin
    case guest
    case none
}

class User: KeyValueCoding {
    let id = 0
    let name = ""
    let birthday: Date? = nil
    let type: UserType = .none
}

class A {
    let a = 0
}

class B : A, KeyValueCoding {
    let b = 0
}

class Object: NSObject, KeyValueCoding {
    @objc let name: String? = ""
}

class SomeClass {
    let i = 0
    let s = "text"
    let o: Int? = nil
}

// Struct

struct Book: KeyValueCoding {
    let id = 0
    let title = ""
    let info: String? = nil
}

final class KeyValueCodingTests: XCTestCase {
    
    func test_class() {
        var user = User()
        
        // Set
        user.setValue(12345, key: "id")
        user.setValue("Bob", key: "name")
        
        let date = Date()
        user.setValue(date, key: "birthday")
        
        user.setValue(UserType.admin, key: "type")
        
        // Get
        
        XCTAssertNil(user.value(key: "undefined"))
        
        XCTAssert(user.value(key: "id") as? Int == 12345)
        XCTAssert(user.value(key: "name") as? String == "Bob")
        XCTAssert(user.value(key: "birthday") as? Date == date)
        XCTAssert(user.value(key: "type") as? UserType == .admin)
        
        // Set nil
        user.setValue(nil, key: "birthday")
        XCTAssertNil(user.value(key: "birthday") as? Date)
        
        _ = user.value(key: "id")
    }
    
    func test_subscript() {
        var user = User()
        
        user["id"] = 100
        user["name"] = "Bob"
        let date = Date()
        user["birthday"] = date
        user["type"] = UserType.admin
        
        XCTAssert(user["id"] as? Int == 100)
        XCTAssert(user["name"] as? String == "Bob")
        XCTAssert(user["birthday"] as? Date == date)
        XCTAssert(user["type"] as? UserType == .admin)
    }
    
    func test_static() {
        var some = SomeClass()
        
        XCTAssert(swift_properties(of: some).count == 3)
        XCTAssert(swift_properties(of: some.self).count == 3)
        
        swift_setValue(11, key: "i", object: &some)
        
        XCTAssert(swift_value(of: &some, key: "i") as? Int  == 11)
        
        _ = swift_value(of: &some, key: "i")
    }
    
    func test_inheritance() {
        var b = B()
        
        XCTAssert(b.properties.count == 2)
        
        b.setValue(10, key: "a")
        b.setValue(20, key: "b")
        
        XCTAssert(b.value(key: "a") as? Int == 10)
        XCTAssert(b.value(key: "b") as? Int == 20)
    }
    
    func test_properties() {
        let user = User()
        
        XCTAssert(user.properties.count == 4)
        
        let property = user.properties[0]
        XCTAssert(property.name == "id")
        XCTAssert(property.type is Int.Type)
        XCTAssert(property.isStrong)
        XCTAssert(property.isVar == false)
    }
    
    func test_nsobject() {
        var object = Object()
        
        object.setValue("objc", key: "name")
        //object.setValue("objc", forKey: "name")
        
        XCTAssert(object.value(key: "name") as? String == "objc")
    }
    
    func test_struct() {
        var book = Book()
        
        book.setValue(12345, key: "id")
        book.setValue("Swift", key: "title")
        book.setValue("Struct", key: "info")
        
        XCTAssert(book.value(key: "id") as? Int == 12345)
        XCTAssert(book.value(key: "title") as? String == "Swift")
        XCTAssert(book.value(key: "info") as? String == "Struct")
    }
}
