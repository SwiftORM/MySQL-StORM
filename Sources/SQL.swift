//
//  SQL.swift
//  PostgresStORM
//
//  Created by Jonathan Guthrie on 2016-09-24.
//
//

import StORM
import MySQL

extension MySQLStORM {

	/// Execute Raw SQL (with parameter binding)
	/// Returns PGResult (discardable)
	@discardableResult
	public func sql(_ statement: String, params: [String]) throws {
		do {
			try exec(statement, params: params)
		} catch {
			self.error = StORMError.error(error.localizedDescription)
			throw error
		}
	}

	@discardableResult
	public func sqlRows(_ statement: String, params: [String]) throws -> [StORMRow] {
		do {
			return try execRows(statement, params: params)
		} catch {
			self.error = StORMError.error(error.localizedDescription)
			throw error
		}
	}

}
