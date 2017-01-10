//
//  Convenience.swift
//  PostgresSTORM
//
//  Created by Jonathan Guthrie on 2016-10-04.
//
//


import StORM
import PerfectLogger

/// Convenience methods extending the main class.
extension MySQLStORM {

	/// Deletes one row, with an id.
	/// Presumes first property in class is the id.
	public func delete() throws {
		let (idname, idval) = firstAsKey()
		do {
			try exec(deleteSQL(self.table(), idName: idname), params: [String(describing: idval)])
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
	}

	/// Deletes one row, with the id as set.
	public func delete(_ id: Any) throws {
		let (idname, _) = firstAsKey()
		do {
			try exec(deleteSQL(self.table(), idName: idname), params: [String(describing: id)])
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
	}

	/// Retrieves a single row with the supplied ID.
	public func get(_ id: Any) throws {
		let (idname, _) = firstAsKey()
		do {
			try select(whereclause: "\(idname) = ?", params: [String(describing: id)], orderby: [])
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
	}

	/// Retrieves a single row with the ID as set.
	public func get() throws {
		let (idname, idval) = firstAsKey()
		do {
			try select(whereclause: "\(idname) = ?", params: [String(describing: idval)], orderby: [])
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
	}

	/// Performs a find on mathing column name/value pairs.
	public func find(_ data: [(String, Any)]) throws {
		let (idname, _) = firstAsKey()

		var paramsString = [String]()
		var set = [String]()
		for i in 0..<data.count {
			paramsString.append(data[i].1 as! String)
			set.append("\(data[i].0) = ?")
		}

		do {
			try select(whereclause: set.joined(separator: " AND "), params: paramsString, orderby: [idname])
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
		
	}

	/// Performs a find on mathing column name/value pairs.
	public func find(_ data: [String: Any]) throws {
		let (idname, _) = firstAsKey()

		var paramsString = [String]()
		var set = [String]()
		for i in data.keys {
			paramsString.append(data[i] as! String)
			set.append("\(i) = ?")
		}

		do {
			try select(whereclause: set.joined(separator: " AND "), params: paramsString, orderby: [idname])
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
		
	}

}
