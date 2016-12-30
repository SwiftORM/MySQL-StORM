//
//  Update.swift
//  PostgresStORM
//
//  Created by Jonathan Guthrie on 2016-09-24.
//
//

import StORM
import PerfectLogger

/// Extends the main class with update functions.
extension MySQLStORM {

	/// Updates the row with the specified data.
	/// This is an alternative to the save() function.
	/// Specify matching arrays of columns and parameters, as well as the id name and value.
	@discardableResult
	public func update(cols: [String], params: [Any], idName: String, idValue: Any) throws -> Bool {

		var paramsString = [String]()
		var set = [String]()
		for i in 0..<params.count {
			paramsString.append(String(describing: params[i]))
			set.append("\(cols[i]) = ?")
		}
		paramsString.append(String(describing: idValue))

		let str = "UPDATE \(self.table()) SET \(set.joined(separator: ", ")) WHERE \(idName) = ?"

		do {
			try exec(str, params: paramsString)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}

		return true
	}

	/// Updates the row with the specified data.
	/// This is an alternative to the save() function.
	/// Specify a [(String, Any)] of columns and parameters, as well as the id name and value.
	@discardableResult
	public func update(data: [(String, Any)], idName: String = "id", idValue: Any) throws -> Bool {

		var keys = [String]()
		var vals = [String]()
		for i in 0..<data.count {
			keys.append(data[i].0)
			vals.append("\(data[i].1)")
		}
		do {
			return try update(cols: keys, params: vals, idName: idName, idValue: idValue)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			throw StORMError.error("\(error)")
		}
	}

}
