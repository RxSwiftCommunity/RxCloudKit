//
//  Entities.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 22/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

public protocol RxCKRecord {

    static var type: String { get }

    static func create() -> CKRecord

    static func create(name: String) -> CKRecord

    func update(record: CKRecord)
    
    mutating func parse(record: CKRecord) // must be implemented by struct

}

public extension RxCKRecord {

    public func create() -> CKRecord {
        let record = CKRecord(recordType: Self.type)
        return record
    }

    public func create(name: String) -> CKRecord {
        let id = CKRecordID(recordName: name)
        let record = CKRecord(recordType: Self.type, recordID: id)
        return record
    }

    public func update(record: CKRecord) throws {
        let mirror = Mirror(reflecting: self)
        if let displayStyle = mirror.displayStyle {
            guard displayStyle == .struct else {
                throw SerializationError.structRequired
            }
            for case let (label?, anyValue) in mirror.children {
                if let value = anyValue as? CKRecordValue {
                    record.setValue(value, forKey: label)
                } else {
                    throw SerializationError.unsupportedSubType(label: label)
                }
            }
        }
    }

}

// TODO

public protocol RxCKSubscription {


}

public extension RxCKSubscription {

}
