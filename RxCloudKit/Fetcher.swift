//
//  Fetcher.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 22/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

final class Fetcher<E: Entity> {
    
    typealias Observer = AnyObserver<CKRecord>
    
    private let observer: Observer
    private let database: CKDatabase
    private let limit: Int
    
    init(observer: Observer, database: CKDatabase, query: CKQuery, limit: Int) {
        self.observer = observer
        self.database = database
        self.limit = limit
        self.fetch(query: query)
    }
    
    private func recordFetchedBlock(record: CKRecord) {
        self.observer.on(.next(record))
    }
    
    private func queryCompletionBlock(cursor: CKQueryCursor?, error: Error?) {
        if let error = error {
            observer.on(.error(error))
            return
        }
        if let cursor = cursor {
            let operation = CKQueryOperation(cursor: cursor)
            self.setupAndAdd(operation: operation)
            return
        }
        observer.on(.completed)
    }
    
    private func fetch(query: CKQuery) {
        let operation = CKQueryOperation(query: query)
        self.setupAndAdd(operation: operation)

    }
    
    private func setupAndAdd(operation: CKQueryOperation) {
        operation.resultsLimit = self.limit
        operation.recordFetchedBlock = self.recordFetchedBlock
        operation.queryCompletionBlock = self.queryCompletionBlock
        self.database.add(operation)
    }

}

