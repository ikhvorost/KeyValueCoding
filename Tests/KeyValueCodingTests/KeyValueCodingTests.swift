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
        
        XCTAssert(user.value(key: "id") == 12345)
        XCTAssert(user.value(key: "name") == "Bob")
        XCTAssert(user.value(key: "birthday") == date)
        XCTAssert(user.value(key: "type") == UserType.admin)
        
        let a = user.value(key: "id")
        print(a)
    }
    
    func test_inheritance() {
        var b = B()
        
        XCTAssert(b.properties.count == 2)
        
        b.setValue(10, key: "a")
        b.setValue(20, key: "b")
        
        XCTAssert(b.value(key: "a") == 10)
        XCTAssert(b.value(key: "b") == 20)
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
        
        XCTAssert(object.value(key: "name") == "objc")
    }
    
    func test_static() {
        var some = SomeClass()
        
        XCTAssert(swift_properties(of: some).count == 3)
        XCTAssert(swift_properties(of: some.self).count == 3)
        
        swift_setValue(11, key: "i", object: &some)
        
        XCTAssert(swift_value(of: &some, key: "i") == 11)
    }
    
    func test_struct() {
        var book = Book()
        
        book.setValue(12345, key: "id")
        book.setValue("Swift", key: "title")
        book.setValue("Struct", key: "info")
        
        XCTAssert(book.value(key: "id") == 12345)
        XCTAssert(book.value(key: "title") == "Swift")
        XCTAssert(book.value(key: "info") == "Struct")
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
