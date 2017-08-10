//
//  CKRecord+Rx.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 25/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

public extension Reactive where Base: CKRecord {
    
    public func save(in database: CKDatabase) -> Single<CKRecord> {
        return Single<CKRecord>.create { single in
            database.save(self.base) { (result, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard result != nil else {
                    single(.error(RxCKError.save))
                    return
                }
                single(.success(result!))
            }
            return Disposables.create()
        }
    }

    public static func fetch(with recordID: CKRecordID, in database: CKDatabase) -> Single<CKRecord> {
        return Single<CKRecord>.create { single in
            database.fetch(withRecordID: recordID) { (record, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard record != nil else {
                    single(.error(RxCKError.fetch))
                    return
                }
                single(.success(record!))
            }
            return Disposables.create()
        }
    }

    public static func delete(with recordID: CKRecordID, in database: CKDatabase) -> Single<CKRecordID> {
        return Single<CKRecordID>.create { single in
            database.delete(withRecordID: recordID) { (recordID, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard recordID != nil else {
                    single(.error(RxCKError.delete))
                    return
                }
                single(.success(recordID!))
            }
            return Disposables.create()
        }
    }

    public static func fetch(recordType: String, predicate: NSPredicate = NSPredicate(value: true), sortDescriptors: [NSSortDescriptor]? = nil, limit: Int = 99, in database: CKDatabase) -> Observable<CKRecord> {
        return Observable.create { observer in
            let query = CKQuery(recordType: recordType, predicate: predicate)
            query.sortDescriptors = sortDescriptors
            _ = RecordFetcher(observer: observer, database: database, query: query, limit: limit)
            return Disposables.create()
        }
    }

}
