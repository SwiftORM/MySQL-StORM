//
//  Upsert.swift
//  PostgresStORM
//
//  Created by Jonathan Guthrie on 2016-09-24.
//
//

import StORM
import PerfectLogger


/// An extention ot the main class that provides MySQL-specific "ON CONFLICT UPDATE" functionality.
extension MySQLStORM {
	
	/// Inserts the row with the specified data, on conflict (conflickkeys columns) it will perform an update.
	/// Specify matching arrays of columns and parameters, and an array of conflict key columns.
	public func upsert(cols: [String], params: [Any], conflictkeys: [String]) throws {

		var paramsString = [String]()
        var upsertParamsString = [String]()
		var substString = [String]()
		var upsertString = [String]()
		for i in 0..<params.count {
			paramsString.append(String(describing: params[i]))
			substString.append("?")

			if i >= conflictkeys.count {
				upsertString.append("\(String(describing: cols[i])) = ?")

            }
            
            if !conflictkeys.contains(cols[i]) {
                upsertParamsString.append(String(describing: params[i]))
            }

		}
        
        paramsString.append(contentsOf: upsertParamsString)
        
        let str = "INSERT INTO \(self.table()) (\(cols.joined(separator: ","))) VALUES(\(substString.joined(separator: ","))) ON DUPLICATE KEY UPDATE \(upsertString.joined(separator: ","))"
        
		do {
			try exec(str, params: paramsString)
		} catch {
			LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
			self.error = StORMError.error("\(error)")
			throw error
		}

	}

}
