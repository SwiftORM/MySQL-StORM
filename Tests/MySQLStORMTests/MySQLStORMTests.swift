import XCTest
import PerfectLib
import Foundation
import StORM
import MySQLStORM
@testable import MySQLStORM


class User: MySQLStORM {
	// NOTE: First param in class should be the ID.
	var id				: Int = 0
	var firstname		: String = ""
	var lastname		: String = ""
	var email			: String = ""


	override open func table() -> String {
		return "usertests"
	}

	override func to(_ this: StORMRow) {
		id				= Int(this.data["id"] as! Int32)
		if let f = this.data["firstname"] {
			firstname = f as! String
		}
		if let f = this.data["lastname"] {
			lastname = f as! String
		}
		if let f = this.data["email"] {
			email = f as! String
		}
	}

	func rows() -> [User] {
		var rows = [User]()
		for i in 0..<self.results.rows.count {
			let row = User()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}
//	override func makeRow() {
//		self.to(self.results.rows[0])
//	}
}


class MySQLStORMTests: XCTestCase {



	override func setUp() {
		super.setUp()
//		StORMdebug = true
		#if os(Linux)
			MySQLConnector.host			= ProcessInfo.processInfo.environment["HOST"]!
			MySQLConnector.username		= ProcessInfo.processInfo.environment["USER"]!
			MySQLConnector.password		= ProcessInfo.processInfo.environment["PASS"]!
			MySQLConnector.database		= ProcessInfo.processInfo.environment["DB"]!
			MySQLConnector.port			= Int(ProcessInfo.processInfo.environment["PORT"]!)!

		#else
			MySQLConnector.host			= "127.0.0.1"
			MySQLConnector.username		= "root"
			MySQLConnector.password		= "root"
			MySQLConnector.database		= "perfect_testing"
			MySQLConnector.port			= 8889
			
		#endif
		let obj = User()
		try? obj.setup()
	}


	/* =============================================================================================
	Save - New
	============================================================================================= */
	func testSaveNew() {

		let obj = User()
		obj.firstname = "X"
		obj.lastname = "Y"

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(String(describing: error))
		}
		XCTAssert(obj.id > 0, "Object not saved (new)")
	}

	/* =============================================================================================
	SELECT via SQL
	============================================================================================= */
	func testSQLSelect() {
		//		StORMdebug = true
		let n = User()
		n.firstname = "X"
		n.lastname = "Y"

		do {
			try n.save {id in n.id = id as! Int }
		} catch {
			XCTFail(String(describing: error))
		}


		let obj = User()

		do {
			try obj.sql("SELECT firstname FROM \(obj.table()) WHERE id = ?", params: ["\(n.id)"])
		} catch {
			XCTFail(String(describing: error))
		}

	}


	/* =============================================================================================
	Save - Update
	============================================================================================= */
	func testSaveUpdate() {
		let obj = User()
		obj.firstname = "X"
		obj.lastname = "Y"

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(String(describing: error))
		}

		obj.firstname = "A"
		obj.lastname = "B"
		do {
			try obj.save()
		} catch {
			XCTFail(String(describing: error))
		}
		print("testSaveUpdate 1: \(obj.errorMsg)")
		XCTAssert(obj.id > 0, "Object not saved (update)")
	}

	/* =============================================================================================
	Save - Create
	============================================================================================= */
	func testSaveCreate() {
		let obj = User()

		do {
			obj.id			= 10001
			obj.firstname	= "Mister"
			obj.lastname		= "PotatoHead"
			obj.email		= "potato@example.com"
			try obj.create()
		} catch {
			print("testSaveCreate 1: \(obj.errorMsg)")
			XCTFail(String(describing: error))
		}
		XCTAssert(obj.id == 10001, "Object not saved (create)")

		// cleanup
		let objCleanup = User()
		objCleanup.id = 10001
		do {
			try objCleanup.delete()
		} catch {
			print("testSaveCreate: \(error)")
			XCTFail(String(describing: error))
		}

	}

	/* =============================================================================================
	Get (with id)
	============================================================================================= */
	func testGetByPassingID() {
		let obj = User()
		//obj.connection = connect    // Use if object was instantiated without connection
		obj.firstname = "X testGetByPassingID"
		obj.lastname = "Y testGetByPassingID"

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(String(describing: error))
		}

		let obj2 = User()

		do {
			try obj2.get(obj.id)
		} catch {
			XCTFail(String(describing: error))
		}
		XCTAssert(obj.id == obj2.id, "Object not the same (id)")
		XCTAssert(obj.firstname == obj2.firstname, "Object not the same (firstname)")
		XCTAssert(obj.lastname == obj2.lastname, "Object not the same (lastname)")
	}


	/* =============================================================================================
	Get (by id set)
	============================================================================================= */
	func testGetByID() {
		let obj = User()
		obj.firstname = "testGetByID"
		obj.lastname = "testGetByID"

		do {
			try obj.save {id in obj.id = id as! Int }
		} catch {
			XCTFail(String(describing: error))
		}

		let obj2 = User()
		obj2.id = obj.id

		do {
			try obj2.get()
		} catch {
			XCTFail(String(describing: error))
		}
		XCTAssert(obj.id == obj2.id, "Object not the same (id)")
		XCTAssert(obj.firstname == obj2.firstname, "Object not the same (firstname)")
		XCTAssert(obj.lastname == obj2.lastname, "Object not the same (lastname)")
	}

	/* =============================================================================================
	Get (with id) - integer too large
	============================================================================================= */
	func testGetByPassingIDtooLarge() {
		let obj = User()

		do {
			try obj.get(874682634789)
			XCTAssert(obj.results.cursorData.totalRecords == 0, "Object should have found no rows")
		} catch {
			XCTFail(error as! String)
		}
	}
	
	/* =============================================================================================
	Get (with id) - no record
	// test get where id does not exist (id)
	============================================================================================= */
	func testGetByPassingIDnoRecord() {
		let obj = User()

		do {
			try obj.get(1111111)
			XCTAssert(obj.results.cursorData.totalRecords == 0, "Object should have found no rows")
		} catch {
			XCTFail(error as! String)
		}
	}




	// test get where id does not exist ()
	/* =============================================================================================
	Get (preset id) - no record
	// test get where id does not exist (id)
	============================================================================================= */
	func testGetBySettingIDnoRecord() {
		let obj = User()
		obj.id = 1111111
		do {
			try obj.get()
			XCTAssert(obj.results.cursorData.totalRecords == 0, "Object should have found no rows")
		} catch {
			XCTFail(error as! String)
		}
	}


	/* =============================================================================================
	Returning DELETE statement to verify correct form
	// deleteSQL
	============================================================================================= */
	func testCheckDeleteSQL() {
		let obj = User()
		XCTAssert(obj.deleteSQL("test", idName: "testid") == "DELETE FROM test WHERE testid = ?", "DeleteSQL statement is not correct")

	}



	// delete(id: Int, idName: String = "id")
	// delete()


	/* =============================================================================================
	Find
	============================================================================================= */
	func testFind() {
		let obj = User()

		do {
			try obj.find([("firstname", "Joe")])
			//print("Find Record:  \(obj.id), \(obj.firstname), \(obj.lastname), \(obj.email)")
		} catch {
			XCTFail("Find error: \(obj.error.string())")
		}
	}


	/* =============================================================================================
	Count test
	Thanks @dindarm for finding the count bug!
	============================================================================================= */
	func testCount() {

		let obj1 = User()
		obj1.firstname = "COUNTTEST"
		obj1.lastname = "Y"

		let obj2 = User()
		obj2.firstname = "COUNTTEST"
		obj2.lastname = "Z"

		let objCount = User()
		do {
			try obj1.save()
			try obj2.save()
			try objCount.find(["firstname":"COUNTTEST"])

			try obj1.delete()
			try obj2.delete()
		} catch {
			XCTFail(String(describing: error))
		}


		print(objCount.results.cursorData.totalRecords)
		XCTAssert(objCount.results.cursorData.totalRecords == 2, "THERE SHOULD BE TWO ROWS")
	}


	/* =============================================================================================
	SELECT via SQL
	============================================================================================= */
	func testUTF8() {
		//	Thanks to @chip
		let n = User()
		n.firstname = "Jägermeister"
		n.lastname = "Jägermeister"

		do {
			try n.save {id in n.id = id as! Int }
		} catch {
			XCTFail(String(describing: error))
		}


		let obj = User()

		do {
			try obj.get(n.id)
			XCTAssert(obj.firstname == "Jägermeister", "UTF8 assertion failed (Jägermeister), \(obj.firstname)")
		} catch {
			XCTFail(String(describing: error))
		}

	}

	static var allTests : [(String, (MySQLStORMTests) -> () throws -> Void)] {
		return [
			("testSaveNew", testSaveNew),
			("testSaveUpdate", testSaveUpdate),
			("testSaveCreate", testSaveCreate),
			("testGetByPassingID", testGetByPassingID),
			("testGetByID", testGetByID),
			("testGetByPassingIDtooLarge", testGetByPassingIDtooLarge),
			("testGetByPassingIDnoRecord", testGetByPassingIDnoRecord),
			("testGetBySettingIDnoRecord", testGetBySettingIDnoRecord),
			("testCheckDeleteSQL", testCheckDeleteSQL),
			("testFind", testFind),
			("testUTF8", testUTF8)
		]
	}

}
