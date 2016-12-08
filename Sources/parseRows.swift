//
//  parseRows.swift
//  PostgresSTORM
//
//  Created by Jonathan Guthrie on 2016-10-06.
//
//

import StORM
import MySQL
import PerfectLib
import Foundation

/// Supplies the parseRows method extending the main class.
extension MySQLStORM {

	/// parseRows takes the [String:Any] result and returns an array of StormRows
	public func parseRows(_ result: MySQLStmt.Results, resultSet: StORMResultSet) -> [StORMRow] {
		var resultRows = [StORMRow]()
		_ = result.forEachRow { row in
			var params = [String: Any]()

			for f in 0..<result.numFields {
				switch resultSet.fieldInfo[resultSet.fieldNames[f]]! {
				case "integer":
					params[resultSet.fieldNames[f]] = row[f]
				case "double":
					params[resultSet.fieldNames[f]] = row[f]
				case "bytes":
					params[resultSet.fieldNames[f]] = row[f]
				case "string":
					params[resultSet.fieldNames[f]] = row[f]
				case "date":
					params[resultSet.fieldNames[f]] = row[f]
				default: // null
					params[resultSet.fieldNames[f]] = String(describing: row[f]!)
					print("\(resultSet.fieldNames[f]) = \(String(describing: row[f]!))")
				}
			}
			let thisRow = StORMRow()
			thisRow.data = params
			resultRows.append(thisRow)
		}
		return resultRows
	}
}
