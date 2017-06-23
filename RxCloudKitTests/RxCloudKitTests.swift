//
//  RxCloudKitTests.swift
//  RxCloudKitTests
//
//  Created by Maxim Volgin on 22/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import XCTest
import CloudKit
@testable import RxCloudKit
@testable import RxSwift

class RxCloudKitTests: XCTestCase {

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    struct Test: RxCloudKit.Entity {
        var title: String
        var number: Int
        var ok: Bool

        public static var type: String = "Test"

        public var name: String = "test"

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

    func temp() {

        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        let privateDB = container.privateCloudDatabase

        var test = Test(record: CKRecord(recordType: Test.type))
        test.title = "test1"
        test.number = 123
        test.ok = true

        publicDB.rx.save(test).subscribe { event in
            switch event {
            case .success(let record):
                print("Record: ", record)
            case .error(let error):
                print("Error: ", error)
            }
        }.addDisposableTo(disposeBag)
    }


}
