//
//  RxCloudKit.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 22/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import RxCocoa
import CloudKit

enum RxCKError: Error {
    case fetchRecord
    case saveRecord
    case unknown
}

public protocol Entity {

    associatedtype T: CKRecord

    static var type: String { get }

    var name: String { get }

    init(record: T)

    func update(_ record: T)

}

public extension Reactive where Base: CKDatabase {

    private func create<E: Entity>(_ type: E.Type = E.self) -> Single<E.T> {
        //        let recordID = CKRecordID(recordName: E.name)
        //        let record = CKRecord(recordType: E.type, recordID: recordID)
        let record = CKRecord(recordType: E.type)
        return Single<E.T>.create { single in
            self.base.save(record) { (record, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard record != nil else {
                    single(.error(RxCKError.saveRecord))
                    return
                }
                single(.success(record as! E.T))
            }
            return Disposables.create()
        }
    }

    private func get<E: Entity>(_ entity: E) -> Single<E.T> {
        let recordID = CKRecordID(recordName: entity.name)
        return Single<E.T>.create { single in
            self.base.fetch(withRecordID: recordID) { (record, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard record != nil else {
                    single(.error(RxCKError.saveRecord))
                    return
                }
                single(.success(record as! E.T))
            }
            return Disposables.create()
        }
    }

}

