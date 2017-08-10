//
//  DataConverters.swift
//  MySQLStORM
//
//  Created by Jonathan Guthrie on 2017-08-10.
//

import Foundation

extension MySQLStORM {

	fileprivate func trim(_ str: String) -> String {
		return str.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	public func toArrayString(_ input: Any) -> [String] {
		return (input as? String ?? "").characters.split(separator: ",").map{ trim(String($0)) }
	}
	public func toArrayInt(_ input: Any) -> [Int] {
		// Needs refinement. Should not be 0
		return (input as? String ?? "").characters.split(separator: ",").map{ Int(trim(String($0))) ?? 0 }
	}
}
