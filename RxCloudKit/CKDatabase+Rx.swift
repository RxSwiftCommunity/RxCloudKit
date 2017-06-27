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

    public func save(record: CKRecord) -> Single<CKRecord> {
        return record.rx.save(in: self.base)
    }

    public func fetch(with recordID: CKRecordID) -> Single<CKRecord> {
        return CKRecord.rx.fetch(with: recordID, in: self.base)
    }

    public func delete(with recordID: CKRecordID) -> Single<CKRecordID> {
        return CKRecord.rx.delete(with: recordID, in: self.base)
    }
    
    public static func fetch(recordType: String, predicate: NSPredicate = NSPredicate(value: true), sortDescriptors: [NSSortDescriptor]? = nil, limit: Int = 99) -> Observable<CKRecord> {
        return CKRecord.rx.fetch(recordType: recordType, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit, in: self.base)
    }

    // MARK:- subscriptions

    public func save(subscription: CKSubscription) -> Single<CKSubscription> {
        return subscription.rx.save(in: self.base)
    }



//    func entities<E: RxCKRecord>(_ type: E.Type = E.self, predicate: NSPredicate = NSPredicate(value: true), sortDescriptors: [NSSortDescriptor]? = nil, limit: Int = 99) -> Observable<[CKRecord]> {
//        return Observable.create { observer in
//            let query = CKQuery(recordType: type.type, predicate:  predicate)
//            query.sortDescriptors = sortDescriptors
//            _ = Fetcher<E>(observer: observer, database: self.base, query: query, limit: limit)
//            return Disposables.create()
//        }.toArray()
//    }

}

