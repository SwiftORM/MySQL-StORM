//
//  MySQLConnect.swift
//  MySQLStORM
//
//  Created by Jonathan Guthrie on 2016-09-23.
//
//

import StORM
import MySQL
import PerfectLogger

/// Base connector class, inheriting from StORMConnect.
/// Provides connection services for the Database Provider
open class MySQLConnect: StORMConnect {

	/// Server connection container
	public let server = MySQL()


	/// Init with no credentials
	override init() {
		super.init()
		self.datasource = .MySQL
	}

	/// Init with credentials
	public init(
	            host: String,
	            username: String = "",
	            password: String = "",
	            database: String = "",
	            port: Int = 0) {
		super.init()
		self.database = database
		self.datasource = .MySQL
		self.credentials = StORMDataSourceCredentials(host: host, port: port, user: username, pass: password)
	}


	/// Opens the connection
	/// If StORMdebug is true, the connection state will be output to console and to ./StORMlog.txt
	public func open() {
		let status = server.connect(
			host: self.credentials.host,
			user: self.credentials.username,
			password: self.credentials.password,
			db: self.database,
			port: UInt32(self.credentials.port)
		)

		guard status else {
			// verify connection success
			if StORMdebug { LogFile.error("MySQL connection error: \(server.errorMessage())", logFile: "./StORMlog.txt") }
			print(server.errorMessage())
			resultCode = .error(server.errorMessage())
			return
		}
		resultCode = .noError
	}

	/// Closes the connection
	public func close() {
		server.close()
	}
}


