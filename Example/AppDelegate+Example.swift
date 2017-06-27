//
//  AppDelegate+Example.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 23/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import CloudKit
import RxSwift

let disposeBag = DisposeBag()
let container = CKContainer.default()
let publicDB = container.publicCloudDatabase
let privateDB = container.privateCloudDatabase

struct Test {
    var title: String
    var number: Int
    var ok: Bool
}

extension Test: RxCKRecord {

    public static var type: String = "Test"

    public var name: String { return "test" }


    public init(record: CKRecord) {
        title = record["title"] as? String ?? ""
        number = record["number"] as? Int ?? 0
        ok = record["ok"] as? Bool ?? false
    }

    public func update(_ record: CKRecord) {
    }

    public func asCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Test.type)
        record["title"] = self.title as CKRecordValue
        record["number"] = self.number as CKRecordValue
        record["ok"] = self.ok as CKRecordValue
        return record
    }

}

extension AppDelegate {

    func example() {
        
        var record = CKRecord(recordType: "MyRecord")
        
        
        struct MyStruct {
            var myIntField: Int
            var myStringField: String
            
            mutating func setValue<T>(object: inout T, key: String) {
            }
            
            mutating func from(record: CKRecord) {
                setValue(object: &self.myIntField, key: "myIntField")
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
            
            func p( f: Any) {
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
            
            func setValue<T>(inout object:T, key: String) {
                switch key {
                case "String":
                    object = ("A String" as? T)!
                case "UIColor":
                    object = (UIColor.whiteColor() as? T)!
                case "Bool":
                    object = (true as? T)!
                default:
                    println("Unhandled key: \(key)")
                }
            }
        }
        
        
        
        

        var test = Test(record: CKRecord(recordType: Test.type))
        test.title = "test1"
        test.number = 123
        test.ok = true

        publicDB.rx.save(record: test.asCKRecord()).subscribe { event in
            switch event {
            case .success(let record):
                print("Record: ", record)
            case .error(let error):
                print("Error: ", error)
            }
        }.addDisposableTo(disposeBag)
        

    }

}
