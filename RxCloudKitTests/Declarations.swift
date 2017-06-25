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
}

extension MyRecord: RxCloudKit.RxCKRecord {

    static var type = "MyRecord"

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

