//
//  XCTestManifests.swift
//  PostgresSTORM
//
//  Created by Jonathan Guthrie on 2016-10-06.
//
//

import XCTest

#if !os(OSX)
	public func allTests() -> [XCTestCaseEntry] {
		return [
			testCase(MySQLStORMTests.allTests)
		]
	}
#endif
