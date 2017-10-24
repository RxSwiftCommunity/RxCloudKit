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

    // MARK:- zones

    public func fetch(with recordZoneID: CKRecordZoneID) -> Single<CKRecordZone> {
        return CKRecordZone.rx.fetch(with: recordZoneID, in: self.base)
    }

    public func modify(recordZonesToSave: [CKRecordZone]?, recordZoneIDsToDelete: [CKRecordZoneID]?) -> Single<([CKRecordZone]?, [CKRecordZoneID]?)> {
        return CKRecordZone.rx.modify(recordZonesToSave: recordZonesToSave, recordZoneIDsToDelete: recordZoneIDsToDelete, in: self.base)
    }
    
    public func fetchChanges(previousServerChangeToken: CKServerChangeToken?, limit: Int = 99) -> Observable<ZoneEvent> {
        return CKRecordZone.rx.fetchChanges(previousServerChangeToken: previousServerChangeToken, limit: limit, in: self.base)
    }

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

    public func fetch(recordType: String, predicate: NSPredicate = NSPredicate(value: true), sortDescriptors: [NSSortDescriptor]? = nil, limit: Int = 400) -> Observable<CKRecord> {
        return CKRecord.rx.fetch(recordType: recordType, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit, in: self.base)
    }
    
    public func fetchChanges(recordZoneIDs: [CKRecordZoneID], optionsByRecordZoneID: [CKRecordZoneID : CKFetchRecordZoneChangesOptions]? = nil) -> Observable<RecordEvent> {
        return CKRecord.rx.fetchChanges(recordZoneIDs: recordZoneIDs, optionsByRecordZoneID: optionsByRecordZoneID, in: self.base)
    }
    
    public func modify(recordsToSave records: [CKRecord]?, recordIDsToDelete recordIDs: [CKRecordID]?) -> Observable<RecordModifyEvent> {
        return CKRecord.rx.modify(recordsToSave: records, recordIDsToDelete: recordIDs, in: self.base)
    }

    // MARK:- subscriptions

    public func save(subscription: CKSubscription) -> Single<CKSubscription> {
        return subscription.rx.save(in: self.base)
    }

    public func fetch(with subscriptionID: String) -> Single<CKSubscription> {
        return CKSubscription.rx.fetch(with: subscriptionID, in: self.base)
    }

    public func delete(with subscriptionID: String) -> Single<String> {
        return CKSubscription.rx.delete(with: subscriptionID, in: self.base)
    }

    public func modify(subscriptionsToSave: [CKSubscription]?, subscriptionIDsToDelete: [String]?) -> Single<([CKSubscription]?, [String]?)> {
        return CKSubscription.rx.modify(subscriptionsToSave: subscriptionsToSave, subscriptionIDsToDelete: subscriptionIDsToDelete, in: self.base)
    }

}

