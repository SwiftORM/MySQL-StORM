//
//  Insert.swift
//  PostgresStORM
//
//  Created by Jonathan Guthrie on 2016-09-24.
//
//

import StORM

extension MySQLStORM {


	@discardableResult
	public func insert(_ data: [(String, Any)]) throws -> Any {

		var keys = [String]()
		var vals = [String]()
		for i in data {
			keys.append(i.0)
			vals.append(String(describing: i.1))
		}
		do {
			return try insert(cols: keys, params: vals)
		} catch {
			throw StORMError.error(error.localizedDescription)
		}
	}


	public func insert(cols: [String], params: [Any]) throws -> Any {
		let (idname, _) = firstAsKey()
		do {
			return try insert(cols: cols, params: params, idcolumn: idname)
		} catch {
			throw StORMError.error(error.localizedDescription)
		}
	}

	public func insert(cols: [String], params: [Any], idcolumn: String) throws -> Any {

		// PostgreSQL specific insert staement exec
		var paramString = [String]()
		var substString = [String]()
		for i in 0..<params.count {
			paramString.append(String(describing: params[i]))
//			substString.append("$\(i+1)")
			substString.append("?")
		}
		let str = "INSERT INTO \(self.table()) (\(cols.joined(separator: ","))) VALUES(\(substString.joined(separator: ",")))"

		do {
			_ = try exec(str, params: paramString, isInsert: true)
//			return lastStatement?.insertId()
			return results.insertedID
		} catch {
			self.error = StORMError.error(error.localizedDescription)
			throw error
		}

	}


}
