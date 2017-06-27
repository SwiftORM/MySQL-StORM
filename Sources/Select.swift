//
//  Select.swift
//  PostgresStORM
//
//  Created by Jonathan Guthrie on 2016-09-24.
//
//

import StORM
import PerfectLogger

/// Provides select functions as an extension to the main class.
extension MySQLStORM {

	/// Retrieves all rows in the table, only limited by the cursor (9,999,999 rows)
	public func findAll() throws {
		do {
			let cursor = StORMCursor(limit: 9999999,offset: 0)
			try select(
				columns: [],
				whereclause: "1",
				params: [],
				orderby: [],
				cursor: cursor
			)
		} catch {
			throw StORMError.error("\(error)")
		}
	}
	/// Select function with specific where clause.
	/// Parameterized statements are used, so all params should be passed in using the [Any] params array.
	/// The whereclause should be specified in the following format: "name = ? AND email LIKE ?"
	/// An orderby array can be specified in a String array like ["name DESC","email ASC"]
	/// A StORMCursor can be supplied, otherwise the default values are used.
	/// Note that the joins, having and groupBy functionality is unimplemented at this time.
	/// The select function will populate the object with the results of the query.
	public func select(
		whereclause:	String,
		params:			[Any],
		orderby:		[String],
		cursor:			StORMCursor = StORMCursor(),
		joins:			[StORMDataSourceJoin] = [],
		having:			[String] = [],
		groupBy:		[String] = []
		) throws {
		do {
			try select(columns: [], whereclause: whereclause, params: params, orderby: orderby, cursor: cursor, joins: joins, having: having, groupBy: groupBy)
		} catch {
			throw StORMError.error("\(error)")
		}
	}

	/// Select function with specific where clause, and spefified columns to return.
	/// Parameterized statements are used, so all params should be passed in using the [Any] params array.
	/// The whereclause should be specified in the following format: "name = ? AND email LIKE ?"
	/// An orderby array can be specified in a String array like ["name DESC","email ASC"]
	/// A StORMCursor can be supplied, otherwise the default values are used.
	/// Note that the joins, having and groupBy functionality is unimplemented at this time.
	/// The select function will populate the object with the results of the query.
	public func select(
		columns:		[String],
		whereclause:	String,
		params:			[Any],
		orderby:		[String],
		cursor:			StORMCursor = StORMCursor(),
		joins:			[StORMDataSourceJoin] = [],
		having:			[String] = [],
		groupBy:		[String] = []
		) throws {

		let clauseCount = "COUNT(*) AS counter"
		var clauseSelectList = "*"
		var clauseWhere = ""
		var clauseOrder = ""

		if columns.count > 0 {
			clauseSelectList = columns.joined(separator: ",")
		} else {
			var keys = [String]()
			for i in cols() {
				keys.append(i.0)
			}
			clauseSelectList = keys.joined(separator: ",")
		}
		if whereclause.characters.count > 0 {
			clauseWhere = " WHERE \(whereclause)"
		}

		var paramsString = [String]()
		for i in 0..<params.count {
			paramsString.append(String(describing: params[i]))
		}
		if orderby.count > 0 {
			clauseOrder = " ORDER BY \(orderby.joined(separator: ", "))"
		}
		do {
			
            // JOIN
            var joinClause = ""
            for join in joins {
                switch join.direction {
                case .INNER:
                    joinClause += " INNER JOIN \(join.table) ON \(join.onCondition) "
                default: ()
                }
            }
            
            // SELECT ASSEMBLE
            var str = "SELECT \(clauseSelectList) FROM \(table()) \(joinClause) \(clauseWhere) \(clauseOrder)"
            
            // SELECT COUNT(*) ASSEMBLE
            let strCount = "SELECT \(clauseCount) FROM \(table()) \(joinClause) \(clauseWhere)"
            
            
			// TODO: having, groupby
            
            
            // LIMIT & OFFSET
			if cursor.limit > 0 {
                let limit = " LIMIT \(cursor.limit)"
				str += limit
//                strCount += limit
			}
			if cursor.offset > 0 {
                let offset = " OFFSET \(cursor.offset)"
				str += offset
//                strCount += offset
			}

            // get the number of records
            let getCount = try execRows(strCount, params: paramsString)
            let numrecords = getCount[0].data["counter"] ?? 0
            
            results.cursorData = StORMCursor(
                limit: cursor.limit,
                offset: cursor.offset,
                totalRecords: Int(numrecords as! Int64))
            
			// save results into ResultSet
			results.rows = try execRows(str, params: paramsString)

			// if just one row returned, act like a "GET"
			if results.cursorData.totalRecords == 1 { makeRow() }

			//return results
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}
	}

}
