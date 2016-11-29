//
//  MySQLStORM.swift
//  MySQLStORM
//
//  Created by Jonathan Guthrie on 2016-10-03.
//
//

import StORM
import MySQL

public struct MySQLConnector {

	public static var host: String		= ""
	public static var username: String	= ""
	public static var password: String	= ""
	public static var database: String	= ""
	public static var port: Int			= 0

	private init(){}

}


open class MySQLStORM: StORM, StORMProtocol {
	private var connection = MySQLConnect()
	public var lastStatement: MySQLStmt?

	open func table() -> String {
		return "unset"
	}

	override public init() {
		super.init()
	}

//	public init(_ connect: MySQLConnect) {
//		super.init()
//		self.connection = connect
//		lastStatement = MySQLStmt(connect.server)
//	}

	private func printDebug(_ statement: String, _ params: [String]) {
		if StORMdebug { print("StORM Debug: \(statement) : \(params.joined(separator: ", "))") }
	}

	// Internal function which executes statements, with parameter binding
	// Returns raw result
	@discardableResult
	func exec(_ statement: String) throws -> MySQL.Results {

		let thisConnection = MySQLConnect(
			host:		MySQLConnector.host,
			username:	MySQLConnector.username,
			password:	MySQLConnector.password,
			database:	MySQLConnector.database,
			port:		MySQLConnector.port
		)



		thisConnection.open()
		defer { thisConnection.server.close() }
		thisConnection.statement = statement

		printDebug(statement, [])
		let querySuccess = thisConnection.server.query(statement: statement)

		guard querySuccess else {
			throw StORMError.error(thisConnection.server.errorMessage())
		}
		let result = thisConnection.server.storeResults()!
		return result
	}
	
	private func fieldNamesToStringArray(_ arr: [Int:String]) -> [String] {
		var out = [String]()
		for i in 0..<arr.count {
			out.append(arr[i]!)
		}
		return out
	}

//	@discardableResult
	func exec(_ statement: String, params: [String], isInsert: Bool = false) throws {
		let thisConnection = MySQLConnect(
			host:		MySQLConnector.host,
			username:	MySQLConnector.username,
			password:	MySQLConnector.password,
			database:	MySQLConnector.database,
			port:		MySQLConnector.port
		)
		thisConnection.open()
		defer { thisConnection.server.close() }
		thisConnection.statement = statement

//		printDebug(statement, params)

		lastStatement = MySQLStmt(thisConnection.server)
		defer { lastStatement?.close() }
		var res = lastStatement?.prepare(statement: statement)
		guard res! else {
			throw StORMError.error(thisConnection.server.errorMessage())
		}

		for p in params {
			lastStatement?.bindParam(p)
		}

		res = lastStatement?.execute()
		guard res! else {
			print(thisConnection.server.errorMessage())
			print(thisConnection.server.errorCode())
			throw StORMError.error(thisConnection.server.errorMessage())
		}

		let result = lastStatement?.results()
		results.foundSetCount = (result?.numRows)!
		if isInsert {
			results.insertedID = Int((lastStatement?.insertId())!)
		}
	}

	// Internal function which executes statements, with parameter binding
	// Returns a processed row set
	@discardableResult
	func execRows(_ statement: String, params: [String]) throws -> [StORMRow] {
		let thisConnection = MySQLConnect(
			host:		MySQLConnector.host,
			username:	MySQLConnector.username,
			password:	MySQLConnector.password,
			database:	MySQLConnector.database,
			port:		MySQLConnector.port
		)

		thisConnection.open()
		defer { thisConnection.server.close() }
		thisConnection.statement = statement

		printDebug(statement, params)

		lastStatement = MySQLStmt(thisConnection.server)
		var res = lastStatement?.prepare(statement: statement)
		guard res! else {
			throw StORMError.error(thisConnection.server.errorMessage())
		}

		for p in params {
			lastStatement?.bindParam(p)
		}

		res = lastStatement?.execute()

		for index in 0..<Int((lastStatement?.fieldCount())!) {
			let this = lastStatement?.fieldInfo(index: index)!
			results.fieldInfo[this!.name] = String(describing: this!.type)
		}

		guard res! else {
			throw StORMError.error(thisConnection.server.errorMessage())
		}

		let result = lastStatement?.results()

		results.foundSetCount = (result?.numRows)!
		results.fieldNames = fieldNamesToStringArray((lastStatement?.fieldNames())!)

		let resultRows = parseRows(result!, resultSet: results)
		return resultRows
	}


	open func to(_ this: StORMRow) {
		//		id				= this.data["id"] as! Int
		//		firstname		= this.data["firstname"] as! String
		//		lastname		= this.data["lastname"] as! String
		//		email			= this.data["email"] as! String
	}

	open func makeRow() {
		self.to(self.results.rows[0])
	}

	@discardableResult
	open func save() throws {
		do {
			if keyIsEmpty() {
				try insert(asData(1))
			} else {
				let (idname, idval) = firstAsKey()
				try update(data: asData(1), idName: idname, idValue: idval)
			}
		} catch {
			throw StORMError.error(error.localizedDescription)
		}
	}
	@discardableResult
	open func save(set: (_ id: Any)->Void) throws {
		do {
			if keyIsEmpty() {
				let setId = try insert(asData(1))
				set(setId)
			} else {
				let (idname, idval) = firstAsKey()
				try update(data: asData(1), idName: idname, idValue: idval)
			}
		} catch {
			throw StORMError.error(error.localizedDescription)
		}
	}

	@discardableResult
	override open func create() throws {
		do {
			try insert(asData())
		} catch {
			throw StORMError.error(error.localizedDescription)
		}
	}


	/// Table Create Statement
	@discardableResult
	open func setupTable(_ str: String = "") throws {
		var createStatement = str
		if str.characters.count == 0 {
			var opt = [String]()
			var keyName = ""
			for child in Mirror(reflecting: self).children {
				guard let key = child.label else {
					continue
				}
				var verbage = ""
				if !key.hasPrefix("internal_") {
					verbage = "\(key) "
					if child.value is Int && opt.count == 0 {
						verbage += "int"
					} else if child.value is Int {
						verbage += "int"
					} else if child.value is Bool {
						verbage += "bool"
					} else if child.value is Double {
						verbage += "float"
					} else if child.value is UInt || child.value is UInt8 || child.value is UInt16 || child.value is UInt32 || child.value is UInt64 {
						verbage += "bytes"
					} else {
						verbage += "text"
					}
					if opt.count == 0 {
						verbage += " NOT NULL AUTO_INCREMENT"
						keyName = key
					}
					opt.append(verbage)
				}
			}
			let keyComponent = ", PRIMARY KEY (`\(keyName)`)"

			createStatement = "CREATE TABLE IF NOT EXISTS \(table()) (\(opt.joined(separator: ", "))\(keyComponent));"

		}
		do {
			try sql(createStatement, params: [])
		} catch {
			print(error)
			throw StORMError.error(String(describing: error))
		}
	}
	
}
