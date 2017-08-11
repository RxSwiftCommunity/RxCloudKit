//
//  RecordChangeFetcher.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 11/08/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

public enum RecordEvent {
    case changed(CKRecord)
    case deleted(CKRecordID)
    case token(CKRecordZoneID, CKServerChangeToken)
}

final class RecordChangeFetcher {
    
    typealias Observer = AnyObserver<RecordEvent>
    
    private let observer: Observer
    private let database: CKDatabase
    
    private var recordZoneIDs: [CKRecordZoneID]
    private var optionsByRecordZoneID: [CKRecordZoneID : CKFetchRecordZoneChangesOptions]
    
    init(observer: Observer, database: CKDatabase, recordZoneIDs: [CKRecordZoneID], optionsByRecordZoneID: [CKRecordZoneID : CKFetchRecordZoneChangesOptions]? = nil) {
        self.observer = observer
        self.database = database
        self.recordZoneIDs = recordZoneIDs
        self.optionsByRecordZoneID = optionsByRecordZoneID ?? [:]
        self.fetch()
    }
    
    // MARK:- callbacks
    
    private func recordChangedBlock(record: CKRecord) {
        self.observer.on(.next(.changed(record)))
    }
    
    private func recordWithIDWasDeletedBlock(recordID: CKRecordID, undocumented: String) {
        print("\(recordID)|\(undocumented)") // TEMP
        self.observer.on(.next(.deleted(recordID)))
    }
    
    private func recordZoneChangeTokensUpdatedBlock(zoneID: CKRecordZoneID, serverChangeToken: CKServerChangeToken?, clientChangeTokenData: Data?) {
// TODO        self.serverChangeToken = serverChangeToken
        if let token = serverChangeToken {
            self.observer.on(.next(.token(zoneID, token)))
        }
// TODO clientChangeTokenData
    }
    
    private func recordZoneFetchCompletionBlock(zoneID: CKRecordZoneID, serverChangeToken: CKServerChangeToken?, clientChangeTokenData: Data?, moreComing: Bool, recordZoneError: Error?) {
// TODO        self.serverChangeToken = serverChangeToken
        if let token = serverChangeToken {
            self.observer.on(.next(.token(zoneID, token)))
        }
// TODO clientChangeTokenData
        if let error = recordZoneError {
            observer.on(.error(error)) // special handling for CKErrorChangeTokenExpired (purge local cache, fetch with token=nil)
            return
        }
        if moreComing {
            self.fetch() // TODO only for this zone!
            return
        }
    }
    
    private func fetchRecordZoneChangesCompletionBlock(operationError: Error?) {
        if let error = operationError {
            observer.on(.error(error))
            return
        }
        observer.on(.completed)
    }
    
    // MARK:- custom
    
    private func fetch() {
        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: self.recordZoneIDs, optionsByRecordZoneID: self.optionsByRecordZoneID)
        operation.fetchAllChanges = true
        operation.qualityOfService = .userInitiated
        operation.recordChangedBlock = self.recordChangedBlock
        operation.recordWithIDWasDeletedBlock = self.recordWithIDWasDeletedBlock
        operation.recordZoneChangeTokensUpdatedBlock = self.recordZoneChangeTokensUpdatedBlock
        operation.recordZoneFetchCompletionBlock = self.recordZoneFetchCompletionBlock
        operation.fetchRecordZoneChangesCompletionBlock = self.fetchRecordZoneChangesCompletionBlock
        self.database.add(operation)
    }
    
}
