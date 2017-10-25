//
//  RecordModifier.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 12/08/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

public enum RecordModifyEvent {
    case progress(CKRecord, Double)
    case result(CKRecord, Error?)
    case changed([CKRecord])
    case deleted([CKRecordID])
}

final class RecordModifier {
    
    typealias Observer = AnyObserver<RecordModifyEvent>
    
    fileprivate var index = 0
    fileprivate var chunk = 400
    
    private let observer: Observer
    private let database: CKDatabase
    private let records: [CKRecord]?
    private let recordIDs: [CKRecordID]?
    private let operation: CKModifyRecordsOperation
    
    init(observer: Observer, database: CKDatabase, recordsToSave records: [CKRecord]?, recordIDsToDelete recordIDs: [CKRecordID]?) {
        self.observer = observer
        self.database = database
        self.records = records
        self.recordIDs = recordIDs
        self.operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: recordIDs)
        self.operation.perRecordProgressBlock = self.perRecordProgressBlock
        self.operation.perRecordCompletionBlock = self.perRecordCompletionBlock
        self.operation.modifyRecordsCompletionBlock = self.modifyRecordsCompletionBlock
        self.database.add(self.operation)
    }
    
    private var count: Int {
        return max(self.records?.count ?? 0, self.recordIDs?.count ?? 0)
    }
    
    private func until() -> Int {
        return index + chunk
    }
    
    private func tuple() -> ([CKRecord]?, [CKRecordID]?) {
        let until = self.until()
        return (self.records == nil ? nil : Array(self.records![index..<until]), self.recordIDs == nil ? nil : Array(self.recordIDs![index..<until]))
    }
    
    // MARK:- callbacks
    
    private func perRecordProgressBlock(record: CKRecord, progress: Double) {
        observer.on(.next(.progress(record, progress)))
    }
    
    private func perRecordCompletionBlock(record: CKRecord, error: Error?) {
       observer.on(.next(.result(record, error)))
    }
    
    private func modifyRecordsCompletionBlock(records: [CKRecord]?, recordIDs: [CKRecordID]?, error: Error?) {
        if let error = error {
            if let ckError = error as? CKError {
                switch ckError.code {
                case .limitExceeded:
                    self.chunk = Int(self.chunk / 2)
                    let tuple = self.tuple()
                    self.operation.recordsToSave = tuple.0
                    self.operation.recordIDsToDelete = tuple.1
                    self.database.add(self.operation)
                    return
                default:
                    break
                }
            }
            observer.on(.error(error))
            return
        }
        if let records = records {
            observer.on(.next(.changed(records)))
        }
        if let recordIDs = recordIDs {
            observer.on(.next(.deleted(recordIDs)))
        }
        if self.until() < self.count {
            self.index += self.chunk
            let tuple = self.tuple()
            self.operation.recordsToSave = tuple.0
            self.operation.recordIDsToDelete = tuple.1
            self.database.add(self.operation)
        } else {
            observer.on(.completed)
        }
    }
    
}
