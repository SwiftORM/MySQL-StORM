//
//  Delete.swift
//  PostgresStORM
//
//  Created by Jonathan Guthrie on 2016-09-24.
//
//

import PerfectLib
import StORM

// TODO:  detect response and return t/f as appropriate

extension MySQLStORM {

	func deleteSQL(_ table: String, idName: String = "id") -> String {
		return "DELETE FROM \(table) WHERE \(idName) = ?"
	}

	/// Deletes one row, with an id as an integer
	@discardableResult
	public func delete(_ id: Int, idName: String = "id") throws -> Bool {
		do {
			try exec(deleteSQL(self.table(), idName: idName), params: [String(id)])
		} catch {
			self.error = StORMError.error(error.localizedDescription)
			throw error
		}
		return true
	}

	/// Deletes one row, with an id as a String
	@discardableResult
	public func delete(_ id: String, idName: String = "id") throws -> Bool {
		do {
			try exec(deleteSQL(self.table(), idName: idName), params: [id])
		} catch {
			self.error = StORMError.error(error.localizedDescription)
			throw error
		}
		return true
	}

	/// Deletes one row, with an id as a UUID
	@discardableResult
	public func delete(_ id: UUID, idName: String = "id") throws -> Bool {
		do {
			try exec(deleteSQL(self.table(), idName: idName), params: [id.string])
		} catch {
			self.error = StORMError.error(error.localizedDescription)
			throw error
		}
		return true
	}

}
