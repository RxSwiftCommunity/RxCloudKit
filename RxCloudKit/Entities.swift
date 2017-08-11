//
//  Entities.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 22/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

// MARK:- zones

public class Zone {
    
    public static func id(name: String) -> CKRecordZoneID {
        if #available(iOS 10.0, *) {
            return CKRecordZoneID(zoneName: name, ownerName: CKCurrentUserDefaultName)
        } else {
            return CKRecordZoneID(zoneName: name, ownerName: CKOwnerDefaultName)
        }
    }

    public static func create(zoneID: CKRecordZoneID) -> CKRecordZone {
        let zone = CKRecordZone(zoneID: zoneID)
        return zone
    }

    public static func create(name: String) -> CKRecordZone {
        let zone = CKRecordZone(zoneName: name)
        return zone
    }
    
}

// MARK:- records

public protocol RxCKRecord {

    static var type: String { get }
    
    static func create() -> CKRecord

    static func create(name: String) -> CKRecord

    var metadata: Data? { get set }
    
    func update(record: CKRecord) throws
    
    mutating func parse(record: CKRecord) // must be implemented by struct

}


public extension RxCKRecord {

    public static func create() -> CKRecord {
        let record = CKRecord(recordType: Self.type)
        return record
    }

    public static func create(name: String) -> CKRecord {
        let id = CKRecordID(recordName: name)
        let record = CKRecord(recordType: Self.type, recordID: id)
        return record
    }
    
    public static func create(zoneID: CKRecordZoneID) -> CKRecord {
        let record = CKRecord(recordType: Self.type, zoneID: zoneID) // TODO static var?
        return record
    }
    
    public mutating func storeMetadata(record: CKRecord) {
        let data = NSMutableData()
        let coder = NSKeyedArchiver.init(forWritingWith: data)
        coder.requiresSecureCoding = true
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        self.metadata = data as Data
    }
    
    public func fromMetadata() -> CKRecord? {
        guard self.metadata != nil else {
            return nil
        }
        let coder = NSKeyedUnarchiver(forReadingWith: self.metadata!)
        coder.requiresSecureCoding = true
        let record = CKRecord(coder: coder)
        coder.finishDecoding()
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

// MARK:- subscriptions

public protocol RxCKSubscription {


}

public extension RxCKSubscription {

}
