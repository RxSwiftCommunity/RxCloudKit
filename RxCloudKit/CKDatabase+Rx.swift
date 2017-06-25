//
//  CKDatabase+Rx.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 22/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

public extension Reactive where Base: CKDatabase {

    // MARK:- records

    func save(record: CKRecord) -> Single<CKRecord> {
        return record.rx.save(in: self.base)
    }

    // MARK:- subscriptions

    func save(record: CKSubscription) -> Single<CKSubscription> {
        return record.rx.save(in: self.base)
    }

    
    // MARK:- old

    private func create<E: RxCKRecord>(_ type: E.Type = E.self) -> Single<CKRecord> {
        //        let recordID = CKRecordID(recordName: E.name)
        //        let record = CKRecord(recordType: E.type, recordID: recordID)
        let record = CKRecord(recordType: E.type)
        return Single<CKRecord>.create { single in
            self.base.save(record) { (record, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard record != nil else {
                    single(.error(RxCKError.save))
                    return
                }
                single(.success(record!))
            }
            return Disposables.create()
        }
    }

//    private func fetch<E: RxCKRecord>(_ RxCKRecord: E) -> Single<CKRecord> {
//        let recordID = CKRecordID(recordName: RxCKRecord.name)
//        return Single<CKRecord>.create { single in
//            self.base.fetch(withRecordID: recordID) { (record, error) in
//                if let error = error {
//                    single(.error(error))
//                    return
//                }
//                guard record != nil else {
//                    single(.error(RxCKError.fetch))
//                    return
//                }
//                single(.success(record!))
//            }
//            return Disposables.create()
//        }
//    }

//    func update<E: RxCKRecord>(_ RxCKRecord: E) -> Single<CKRecord> {
//        return self.fetch(RxCKRecord).catchError { (error) -> PrimitiveSequence<SingleTrait, CKRecord> in
//            return self.create(E.self)
//        }
//    }
    
//    func save<E: RxCKRecord>(_ RxCKRecord: E) -> Single<CKRecord> {
//        let record = RxCKRecord.asCKRecord()
//        return Single<CKRecord>.create { single in
//            self.base.save(record) { (record, error) in
//                if let error = error {
//                    single(.error(error))
//                    return
//                }
//                guard record != nil else {
//                    single(.error(RxCKError.save))
//                    return
//                }
//                single(.success(record!))
//            }
//            return Disposables.create()
//        }
//    }
//
//    func delete<E: RxCKRecord>(_ RxCKRecord: E) -> Single<CKRecordID> {
//        return fetch(RxCKRecord).flatMap { (record) -> PrimitiveSequence<SingleTrait, CKRecordID> in
//            return Single<CKRecordID>.create { single in
//                self.base.delete(withRecordID: record.recordID) { (recordID, error) in
//                    if let error = error {
//                        single(.error(error))
//                        return
//                    }
//                    guard recordID != nil else {
//                        single(.error(RxCKError.delete))
//                        return
//                    }
//                    single(.success(recordID!))
//                }
//                return Disposables.create()
//            }
//        }
//    }

    func entities<E: RxCKRecord>(_ type: E.Type = E.self, predicate: NSPredicate = NSPredicate(value: true), sortDescriptors: [NSSortDescriptor]? = nil, limit: Int = 99) -> Observable<[CKRecord]> {
        return Observable.create { observer in
            let query = CKQuery(recordType: type.type, predicate:  predicate)
            query.sortDescriptors = sortDescriptors
            _ = Fetcher<E>(observer: observer, database: self.base, query: query, limit: limit)
            return Disposables.create()
        }.toArray()
    }

}

