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

    private func create<E: Entity>(_ type: E.Type = E.self) -> Single<CKRecord> {
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
                    single(.error(RxCKError.saveRecord))
                    return
                }
                single(.success(record!))
            }
            return Disposables.create()
        }
    }

    private func fetch<E: Entity>(_ entity: E) -> Single<CKRecord> {
        let recordID = CKRecordID(recordName: entity.name)
        return Single<CKRecord>.create { single in
            self.base.fetch(withRecordID: recordID) { (record, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard record != nil else {
                    single(.error(RxCKError.fetchRecord))
                    return
                }
                single(.success(record!))
            }
            return Disposables.create()
        }
    }

    func update<E: Entity>(_ entity: E) -> Single<CKRecord> {
        return self.fetch(entity).catchError { (error) -> PrimitiveSequence<SingleTrait, CKRecord> in
            return self.create(E.self)
        }
    }
    
    func save<E: Entity>(_ entity: E) -> Single<CKRecord> {
        let record = entity.asCKRecord()
        return Single<CKRecord>.create { single in
            self.base.save(record) { (record, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard record != nil else {
                    single(.error(RxCKError.saveRecord))
                    return
                }
                single(.success(record!))
            }
            return Disposables.create()
        }
    }

    func delete<E: Entity>(_ entity: E) -> Single<CKRecordID> {
        return fetch(entity).flatMap { (record) -> PrimitiveSequence<SingleTrait, CKRecordID> in
            return Single<CKRecordID>.create { single in
                self.base.delete(withRecordID: record.recordID) { (recordID, error) in
                    if let error = error {
                        single(.error(error))
                        return
                    }
                    guard recordID != nil else {
                        single(.error(RxCKError.deleteRecord))
                        return
                    }
                    single(.success(recordID!))
                }
                return Disposables.create()
            }
        }
    }

    func entities<E: Entity>(_ type: E.Type = E.self, predicate: NSPredicate = NSPredicate(value: true), sortDescriptors: [NSSortDescriptor]? = nil, limit: Int = 99) -> Observable<[CKRecord]> {
        return Observable.create { observer in
            let query = CKQuery(recordType: type.type, predicate:  predicate)
            query.sortDescriptors = sortDescriptors
            _ = Fetcher<E>(observer: observer, database: self.base, query: query, limit: limit)
            return Disposables.create()
        }.toArray()
    }

}

