//
//  Upsert.swift
//  PostgresStORM
//
//  Created by Jonathan Guthrie on 2016-09-24.
//
//

import StORM


extension MySQLStORM {
	
	public func upsert(cols: [String], params: [Any], conflictkeys: [String]) throws {

		// PostgreSQL specific insert staement exec
		var paramsString = [String]()
		var substString = [String]()
		var upsertString = [String]()
		for i in 0..<params.count {
			paramsString.append(String(describing: params[i]))
			substString.append("?")

			if i >= conflictkeys.count {
				upsertString.append("\(String(describing: cols[i])) = ?")

			}

		}
		let str = "INSERT INTO \(self.table()) (\(cols.joined(separator: ","))) VALUES(\(substString.joined(separator: ","))) ON CONFLICT (\(conflictkeys.joined(separator: ","))) DO UPDATE SET \(upsertString.joined(separator: ","))"
		do {
			try exec(str, params: paramsString)
		} catch {
			self.error = StORMError.error(error.localizedDescription)
			throw error
		}

	}

}
