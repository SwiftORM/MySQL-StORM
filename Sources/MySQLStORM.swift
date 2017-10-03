//
//  MySQLStORM.swift
//  MySQLStORM
//
//  Created by Jonathan Guthrie on 2016-10-03.
//
//

import StORM
import PerfectMySQL
import PerfectLogger

/// MySQLConnector sets the connection parameters for the PostgreSQL Server access
/// Usage:
/// MySQLConnector.host = "XXXXXX"
/// MySQLConnector.username = "XXXXXX"
/// MySQLConnector.password = "XXXXXX"
/// MySQLConnector.port = 3306
public struct MySQLConnector {

	public static var host: String		= ""
	public static var username: String	= ""
	public static var password: String	= ""
	public static var database: String	= ""
	public static var port: Int			= 3306
	public static var charset: String	= "utf8mb4"

	public static var quiet: Bool		= false

	private init(){}

}


/// SuperClass that inherits from the foundation "StORM" class.
/// Provides MySQLL-specific ORM functionality to child classes
open class MySQLStORM: StORM, StORMProtocol {

	/// Holds the last statement executed
	public var lastStatement: MySQLStmt?

	/// Table that the child object relates to in the database.
	/// Defined as "open" as it is meant to be overridden by the child class.
	open func table() -> String {
		let m = Mirror(reflecting: self)
		return ("\(m.subjectType)").lowercased()
	}

	/// Public init
	override public init() {
		super.init()
	}

	private func printDebug(_ statement: String, _ params: [String]) {
		if StORMdebug { LogFile.debug("StORM Debug: \(statement) : \(params.joined(separator: ", "))", logFile: "./StORMlog.txt") }
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
			port:		MySQLConnector.port,
			charset:	MySQLConnector.charset
		)



		thisConnection.open()
		//		defer { thisConnection.server.close() }
		thisConnection.statement = statement

		printDebug(statement, [])
		let querySuccess = thisConnection.server.query(statement: statement)

		guard querySuccess else {
			throw StORMError.error(thisConnection.server.errorMessage())
		}
		let result = thisConnection.server.storeResults()!
		thisConnection.server.close()
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
			port:		MySQLConnector.port,
			charset:	MySQLConnector.charset
		)
		thisConnection.open()
		//		defer { thisConnection.server.close() }
		thisConnection.statement = statement

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
			if !MySQLConnector.quiet {
				print(thisConnection.server.errorMessage())
				print(thisConnection.server.errorCode())
			}
			throw StORMError.error(thisConnection.server.errorMessage())
		}

		let result = lastStatement?.results()
		results.foundSetCount = (result?.numRows)!
		if isInsert {
			results.insertedID = Int((lastStatement?.insertId())!)
		}
		thisConnection.server.close()
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
			port:		MySQLConnector.port,
			charset:	MySQLConnector.charset
		)

		thisConnection.open()
		//		defer { thisConnection.server.close() }
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
		thisConnection.server.close()
		return resultRows
	}


	/// Generic "to" function
	/// Defined as "open" as it is meant to be overridden by the child class.
	///
	/// Sample usage:
	///		id				= this.data["id"] as? Int ?? 0
	///		firstname		= this.data["firstname"] as? String ?? ""
	///		lastname		= this.data["lastname"] as? String ?? ""
	///		email			= this.data["email"] as? String ?? ""
	open func to(_ this: StORMRow) {
	}

	/// Generic "makeRow" function
	/// Defined as "open" as it is meant to be overridden by the child class.
	open func makeRow() {
		self.to(self.results.rows[0])
	}

	/// Standard "Save" function.
	/// Designed as "open" so it can be overriden and customized.
	/// If an ID has been defined, save() will perform an updae, otherwise a new document is created.
	/// On error can throw a StORMError error.
	open func save() throws {
		do {
			if keyIsEmpty() {
				try insert(asData(1))
			} else {
				let (idname, idval) = firstAsKey()
				try update(data: asData(1), idName: idname, idValue: idval)
			}
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
	}

	/// Alternate "Save" function.
	/// This save method will use the supplied "set" to assign or otherwise process the returned id.
	/// Designed as "open" so it can be overriden and customized.
	/// If an ID has been defined, save() will perform an updae, otherwise a new document is created.
	/// On error can throw a StORMError error.
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
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
	}

	/// Unlike the save() methods, create() mandates the addition of a new document, regardless of whether an ID has been set or specified.
	override open func create() throws {
		do {
			try insert(asData())
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
	}


	/// Table Creation (alias for setup)
	open func setupTable(_ str: String = "") throws {
		try setup(str)
	}

	/// Table Creation
	/// Requires the connection to be configured, as well as a valid "table" property to have been set in the class
	open func setup(_ str: String = "") throws {
		LogFile.info("Running setup: \(table())", logFile: "./StORMlog.txt")
		var createStatement = str
		if str.characters.count == 0 {
			var opt = [String]()
			var keyName = ""
			for child in Mirror(reflecting: self).children {
				guard let key = child.label else {
					continue
				}
				var verbage = ""
				if !key.hasPrefix("internal_") && !key.hasPrefix("_") {
					verbage = "`\(key)` "
					if child.value is Int && opt.count == 0 {
						verbage += "int"
					} else if child.value is Int {
						verbage += "int"
					} else if child.value is Bool {
						verbage += "int" // MySQL has no bool type
					} else if child.value is Double {
						verbage += "float"
					} else if child.value is UInt || child.value is UInt8 || child.value is UInt16 || child.value is UInt32 || child.value is UInt64 {
						verbage += "blob"
					} else {
						verbage += "text"
					}
					if opt.count == 0 {
						if child.value is Int {
							verbage = "`\(key)` int NOT NULL AUTO_INCREMENT"
						} else {
							verbage = "`\(key)` varchar(255) NOT NULL"
						}
						keyName = key
					}
					opt.append(verbage)
				}
			}
			let keyComponent = ", PRIMARY KEY (`\(keyName)`)"

			createStatement = "CREATE TABLE IF NOT EXISTS \(table()) (\(opt.joined(separator: ", "))\(keyComponent));"
			if StORMdebug { LogFile.info("createStatement: \(createStatement)", logFile: "./StORMlog.txt") }
		}
		do {
			try sql(createStatement, params: [])
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
	}
	
}
