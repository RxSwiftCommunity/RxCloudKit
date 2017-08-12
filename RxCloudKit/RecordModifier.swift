//
//  RecordModifier.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 12/08/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

final class RecordModifier {
    
    typealias Observer = AnyObserver<Any>
    
    private let observer: Observer
    private let database: CKDatabase
    
    init(observer: Observer, database: CKDatabase, recordsToSave records: [CKRecord]?, recordIDsToDelete recordIDs: [CKRecordID]?) {
        self.observer = observer
        self.database = database
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: recordIDs)
        operation.perRecordProgressBlock = self.perRecordProgressBlock
        operation.perRecordCompletionBlock = self.perRecordCompletionBlock
        operation.modifyRecordsCompletionBlock = self.modifyRecordsCompletionBlock
        self.database.add(operation)
    }
    
    // MARK:- callbacks
    
    private func perRecordProgressBlock(record: CKRecord, progress: Double) {
        //
    }
    
    private func perRecordCompletionBlock(record: CKRecord, error: Error?) {
        //
    }
    
    private func modifyRecordsCompletionBlock(records: [CKRecord]?, recordIDs: [CKRecordID]?, error: Error?) {
        if let error = error {
            observer.on(.error(error))
            return
        }
        observer.on(.completed)
    }
    
}
