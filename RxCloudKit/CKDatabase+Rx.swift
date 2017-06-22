//
//  RxCloudKit.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 22/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

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

    private func fetch<E: Entity>(_ entity: E) -> Single<E.T> {
        let recordID = CKRecordID(recordName: entity.name)
        return Single<E.T>.create { single in
            self.base.fetch(withRecordID: recordID) { (record, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard record != nil else {
                    single(.error(RxCKError.fetchRecord))
                    return
                }
                single(.success(record as! E.T))
            }
            return Disposables.create()
        }
    }

    func update<E: Entity>(_ entity: E) -> Single<E.T> {
        return self.fetch(entity).catchError { (error) -> PrimitiveSequence<SingleTrait, E.T> in
            return self.create(E.self)
        }
    }

    func delete<E: Entity>(_ entity: E) -> Single<E.I> {
        return fetch(entity).flatMap { (record) -> Single<E.I> in
            return Single<E.I>.create { single in
                self.base.delete(withRecordID: record.recordID) { (recordID, error) in
                    if let error = error {
                        single(.error(error))
                        return
                    }
                    guard recordID != nil else {
                        single(.error(RxCKError.deleteRecord))
                        return
                    }
                    single(.success(recordID as! E.I))
                }
                return Disposables.create()
            }
        }
    }


}

