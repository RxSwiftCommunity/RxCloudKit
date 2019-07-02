//
//  RecordModifier.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 12/08/2017.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxSwift
import CloudKit

public enum RecordModifyEvent {
    case progress(CKRecord, Double) // save progress
    case result(CKRecord, Error?) // save result
    case changed([CKRecord])
    case deleted([CKRecord.ID])
}

final class RecordModifier {
    
    typealias Observer = AnyObserver<RecordModifyEvent>
    
    fileprivate var index = 0
    fileprivate var chunk = 400
    
    private let observer: Observer
    private let database: CKDatabase
    private let records: [CKRecord]?
    private let recordIDs: [CKRecord.ID]?
    
    init(observer: Observer, database: CKDatabase, recordsToSave records: [CKRecord]?, recordIDsToDelete recordIDs: [CKRecord.ID]?) {
        self.observer = observer
        self.database = database
        self.records = records
        self.recordIDs = recordIDs
        self.batch(recordsToSave: records, recordIDsToDelete: recordIDs)
    }
    
    private func batch(recordsToSave records: [CKRecord]?, recordIDsToDelete recordIDs: [CKRecord.ID]?) {
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: recordIDs)
        operation.perRecordProgressBlock = self.perRecordProgressBlock
        operation.perRecordCompletionBlock = self.perRecordCompletionBlock
        operation.modifyRecordsCompletionBlock = self.modifyRecordsCompletionBlock
        database.add(operation)
    }
    
    private func batch() {
        let tuple = self.tuple()
        self.batch(recordsToSave: tuple.0, recordIDsToDelete: tuple.1)
    }
    
    private var count: Int {
        return max(self.records?.count ?? 0, self.recordIDs?.count ?? 0)
    }
    
    private func until() -> Int {
        return index + chunk
    }
    
    private func tuple() -> ([CKRecord]?, [CKRecord.ID]?) {
        let until = self.until()
        return (self.records == nil ? nil : Array(self.records![index..<until]), self.recordIDs == nil ? nil : Array(self.recordIDs![index..<until]))
    }
    
    // MARK:- callbacks
    
    // save progress
    private func perRecordProgressBlock(record: CKRecord, progress: Double) {
        observer.on(.next(.progress(record, progress)))
    }
    
    // save result
    private func perRecordCompletionBlock(record: CKRecord, error: Error?) {
       observer.on(.next(.result(record, error)))
    }
    
    private func modifyRecordsCompletionBlock(records: [CKRecord]?, recordIDs: [CKRecord.ID]?, error: Error?) {
        if let error = error {
            if let ckError = error as? CKError {
                switch ckError.code {
                case .limitExceeded:
                    self.chunk = Int(self.chunk / 2)
                    self.batch()
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
            self.batch()
        } else {
            observer.on(.completed)
        }
    }
    
}
