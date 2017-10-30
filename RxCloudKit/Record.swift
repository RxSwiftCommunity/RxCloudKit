//
//  Entities.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 22/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import CloudKit
import ObjectiveC

public protocol RxCKRecord {

    /** record type */
    static var type: String { get } // must be implemented by struct

    /** zone name */
    static var zone: String { get } // must be implemented by struct

    /** system fields */
    var metadata: Data? { get set }

    /** reads user fields */
    mutating func readUserFields(from record: CKRecord) // must be implemented by struct

    /** copies user fields via reflection */
    func writeUserFields(to record: CKRecord) throws

    /** read system and user fields form CKRecord */
    mutating func read(from record: CKRecord)

    /** generate CKRecord with user- and possibly system fields filled */
    func asCKRecord() throws -> CKRecord

    /** predicate to uniquely identify the record, such as: NSPredicate(format: "code == '\(code)'") */
    func predicate() -> NSPredicate

    /** custom recordName if desired (must be unique per DB) */
    func recordName() -> String?

}

//var AssociatedObjectHandle: UInt8 = 0

public extension RxCKRecord {

//    public var metadata: Data? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? Data
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }

    public func recordName() -> String? { return nil }

    /** CloudKit recordName (if metadata != nil) */
    public func id() -> String? {
        return self.fromMetadata()?.recordID.recordName
    }

    /** read from CKRecord */
    public mutating func read(from record: CKRecord) {
        self.readMetadata(from: record)
        self.readUserFields(from: record)
    }

    /** as CKRecord (will init metadata if metadata == nil ) */
    public func asCKRecord() throws -> CKRecord {
        let record = self.fromMetadata() ?? Self.newCKRecord(name: self.recordName())
        try self.writeUserFields(to: record)
        return record
    }

    /**  query on CKRecord system field(s) with NSArray.filtered(using: predicate) */
    func predicate(with block: @escaping (CKRecord) -> Bool) -> NSPredicate {
        return NSPredicate { (object, bindings) -> Bool in
            if let entity = object {
                if let rxCKRecord = entity as? Self {
                    if let ckRecord = rxCKRecord.fromMetadata() {
                        return block(ckRecord)
                    }
                }
            }
            return false
        }
    }

    /** CloudKit zoneID */
    public static var zoneID: CKRecordZoneID {
        get {
            return CKRecordZone(zoneName: Self.zone).zoneID
        }
    }

    /** create empty CKRecord for zone and type (and name, if provided via .recordName() method) */
    public static func newCKRecord(name: String? = nil) -> CKRecord {
        if let recordName = name {
            let id = CKRecordID(recordName: recordName, zoneID: Self.zoneID)
            let record = CKRecord(recordType: Self.type, recordID: id)
            return record
        } else {
            let record = CKRecord(recordType: Self.type, zoneID: Self.zoneID)
            return record
        }
    }


    /** create empty CKRecord with name for type */
    public static func create(name: String) -> CKRecord {
        let id = CKRecordID(recordName: name)
        let record = CKRecord(recordType: Self.type, recordID: id)
        return record
    }

    public mutating func readMetadata(from record: CKRecord) {
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

    public func writeUserFields(to record: CKRecord) throws {
        let mirror = Mirror(reflecting: self)
        if let displayStyle = mirror.displayStyle {
            guard displayStyle == .struct else {
                throw SerializationError.structRequired
            }
            for case let (label?, anyValue) in mirror.children {
                if label == "metadata" {
                    continue
                }
                if let value = anyValue as? CKRecordValue {
                    record.setValue(value, forKey: label)
                } else {
                    throw SerializationError.unsupportedSubType(label: label)
                }
//                let value = anyValue as? CKRecordValue
//                record.setValue(value, forKey: label)
            }
        }
    }

}


