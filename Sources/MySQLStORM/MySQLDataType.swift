//
//  MySQLDataType.swift
//  MySQLStORM
//
//  Created by Fatih Nayebi on 2018-01-04.
//

import Foundation

public protocol StORMFieldTypeProtocol {
    func fieldType() -> String
}

public enum MySQLDataType: StORMFieldTypeProtocol {
    case notDefined
    case bit(length: UInt8)
    case tinyInt(length: UInt8)
    case smallInt(length: UInt8)
    case mediumInt(length: UInt8)
    case int(length: UInt8)
    case integer(length: UInt8)
    case bigInt(length: UInt8)
    case decimal(length: UInt8, scale: UInt8)
    case dec(length: UInt8, scale: UInt8)
    case float(length: UInt8, scale: UInt8)
    case double(length: UInt8, scale: UInt8)
    case date
    case dateTime
    case timeStamp(fsp: UInt8)
    case time(fsp: UInt8)
    case year
    case char(length: UInt8)
    case varChar(length: UInt8)
    case binary(length: UInt8)
    case varBinary(length: UInt8)
    case tinyBlob
    case blob(length: UInt8)
    case text
    case mediumBlob
    case mediumText
    case longBlob
    case longText
    
    public func fieldType() -> String {
        switch self {
        case .notDefined:
            return "NOT DEFINED"
        case .bit(let lngt):
            return "BIT(\(lngt))"
        case .tinyInt(let lngt):
            return "TINYINT(\(lngt))"
        case .smallInt(let lngt):
            return "SMALLINT(\(lngt))"
        case .mediumInt(let lngt):
            return "MEDIUMINT(\(lngt))"
        case .int(let lngt):
            return "INT(\(lngt))"
        case .integer(let lngt):
            return "INTEGER(\(lngt))"
        case .bigInt(let lngt):
            return "BIGINT(\(lngt))"
        case .decimal(let lngt, let scale):
            return "DECIMAL(\(lngt),\(scale))"
        case .dec(let lngt, let scale):
            return "DEC(\(lngt),\(scale))"
        case .float(let lngt, let scale):
            return "FLOAT(\(lngt),\(scale))"
        case .double(let lngt, let scale):
            return "DOUBLE(\(lngt),\(scale))"
        case .date:
            return "DATE"
        case .dateTime:
            return "DATETIME"
        case .timeStamp(let fsp):
            return "TIMESTAMP(\(fsp))"
        case .time(let fsp):
            return "TIME(\(fsp))"
        case .year:
            return "YEAR"
        case .char(let lngt):
            return "CHAR(\(lngt))"
        case .varChar(let lngt):
            return "VARCHAR(\(lngt))"
        case .binary(let lngt):
            return "BINARY(\(lngt))"
        case .varBinary(let lngt):
            return "VARBINARY(\(lngt))"
        case .tinyBlob:
            return "TINYBLOB"
        case .blob(let lngt):
            return "BLOB(\(lngt))"
        case .text:
            return "TEXT"
        case .mediumBlob:
            return "MEDIUMBLOB"
        case .mediumText:
            return "MEDIUMTEXT"
        case .longBlob:
            return "LONGBLOB"
        case .longText:
            return "LONGTEXT"
        }
    }
}
