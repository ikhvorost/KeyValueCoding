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

class Object: NSObject, KeyValueCoding {
    @objc let name: String? = ""
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
        
        XCTAssert(user.value(key: "id") as? Int  == 12345)
        XCTAssert(user.value(key: "name") as? String == "Bob")
        XCTAssert(user.value(key: "birthday") as? Date == date)
        XCTAssert(user.value(key: "type") as? UserType == .admin)
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
    
    func test_class_objc() {
        var object = Object()
        
        object.setValue("objc", key: "name")
        //object.setValue("objc", forKey: "name")
        
        XCTAssert(object.value(key: "name") as? String == "objc")
    }
}


/*
 // Struct

 struct Book: KeyValueCoding {
     let id = 0
     let title = "Swift"
     let info: String? = nil
 }

 var book = Book()
 book.setValue(56789, forKey: "id")
 book.setValue("ObjC", forKey: "title")
 book.setValue("Development", forKey: "info")
 print(book.id, book.title, book.info!)

 */
