//
//  MySQLConnect.swift
//  MySQLStORM
//
//  Created by Jonathan Guthrie on 2016-09-23.
//
//

import StORM
import MySQL

open class MySQLConnect: StORMConnect {

	// server connection
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


	// Initiates the connection
	public func open() {
		let status = server.connect(
			host: self.credentials.host,
			user: self.credentials.username,
			password: self.credentials.password,
			db: self.database,
			port: UInt32(self.credentials.port)
		)

		guard status else {
			// verify we connected successfully
			print(server.errorMessage())
			resultCode = .error(server.errorMessage())
			return
		}
		resultCode = .noError
	}

	public func close() {
		server.close()
	}
}


