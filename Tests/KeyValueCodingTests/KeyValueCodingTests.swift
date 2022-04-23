import XCTest
import KeyValueCoding
//@testable import KeyValueCoding


enum UserType {
    case admin
    case guest
    case none
}

class User: KeyValueCoding {
    let id = 11
    let name = "John"
    let birthday: Date? = Date()
    let type: UserType = .none
}

final class KeyValueCodingTests: XCTestCase {
    
    func test_value() {
        var user = User()
        
        XCTAssertNil(user.value(forKey: "undefined"))
        
        XCTAssert(user.value(forKey: "id") as? Int  == user.id)
        XCTAssert(user.value(forKey: "name") as? String == user.name)
        XCTAssert(user.value(forKey: "birthday") as? Date == user.birthday)
        XCTAssert(user.value(forKey: "type") as? UserType == user.type)
    }
    
    func test_setValue() {
        var user = User()
        
        user.setValue(12345, forKey: "id")
        user.setValue("Bob", forKey: "name")
        
        let date = Date()
        user.setValue(date, forKey: "birthday")
        
        user.setValue(UserType.admin, forKey: "type")
        
        XCTAssertEqual(user.id, 12345)
        XCTAssertEqual(user.name, "Bob")
        XCTAssertEqual(user.birthday, date)
        XCTAssertEqual(user.type, .admin)
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
