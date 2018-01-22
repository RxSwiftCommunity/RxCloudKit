//
//  Declarations.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 25/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import XCTest
import CloudKit
@testable import RxCloudKit
@testable import RxSwift

struct MyRecord {
    var myIntField: Int
    var myBoolField: Bool
    var myStringField: String
    // required
    var metadata: Data? = nil
}

extension MyRecord: RxCloudKit.RxCKRecord {
    static var type = "MyRecord"
    static var zone = CKRecordZone.default().zoneID.zoneName

    mutating func readUserFields(from record: CKRecord) {
        self.myStringField = record.object(forKey: "myStringField") as? String ?? ""
        // TODOmyStringField
    }
    func predicate() -> NSPredicate {
        return NSPredicate(format: "myStringField = \(myStringField)")
    }
    func recordName() -> String? {
        return myStringField
    }
    
    init(record: CKRecord) {
        self.myIntField = record["myIntField"] as? Int ?? 0
        self.myBoolField = record["myBoolField"] as? Bool ?? false
        self.myStringField = record["myStringField"] as? String ?? ""
    }

    func update(_ record: CKRecord) {
        record["myIntField"] = self.myIntField as CKRecordValue
        record["myBoolField"] = self.myBoolField as CKRecordValue
        record["myStringField"] = self.myStringField as CKRecordValue
    }

}


enum MySerializer {
    case intField(String, Int)
    case boolField(String, Bool)
    case stringField(String, String)
}


enum MyRecordE {
    case myIntField(Int)
    case myBoolField(Bool)
    case myStringField(String)
}

extension MySerializer {

    func p(f: inout Any) {
        switch self {
        case .intField(let name, let value):
            print("\(self)=\(value)")
            f = 123
//            self.myStringField = record["myStringField"] as? String ?? ""
//            record["myIntField"] = self.myIntField as CKRecordValue
            break
        default:
            break
        }
    }

    func setValue<T>(object: inout T, key: String) {
        switch key {
        case "String":
            object = ("A String" as? T)!
        case "UIColor":
            object = (UIColor.white as? T)!
        case "Bool":
            object = (true as? T)!
        default:
            print("Unhandled key: \(key)")
        }
    }
}

public protocol RxCKSerializer {

    static var type: String { get }

//    init()
//
//    init(name: String)

}

public extension RxCKSerializer {

//    init() {
//        let record = CKRecord(recordType: Self.type)
//        self.init(record: record)
//    }

//    init(name: String) {
//        let id = CKRecordID(recordName: name)
//        let record = CKRecord(recordType: Self.type, recordID: id)
//        self.init(record: record)
//    }

}


//protocol MyRxCKSerializer: RxCKSerializer {
//    var myIntField: Int { get set }
//    var myBoolField: Bool { get set }
//    var myStringField: String { get set }
//}

struct MyRecord1: RxCKSerializer {

    static var type: String = "MyRecord1"

//        var myIntField: Int { get set }
//        var myBoolField: Bool { get set }
//        var myStringField: String { get set }
//
//    init(record: CKRecord) {
//        self.myIntField = record["myIntField"] as? Int ?? 0
//        self.myBoolField = record["myBoolField"] as? Bool ?? false
//        self.myStringField = record["myStringField"] as? String ?? ""
//    }
//
//    func update(_ record: CKRecord) {
//        record["myIntField"] = self.myIntField as CKRecordValue
//        record["myBoolField"] = self.myBoolField as CKRecordValue
//        record["myStringField"] = self.myStringField as CKRecordValue
//    }


}

