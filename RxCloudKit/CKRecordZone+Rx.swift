//
//  CKRecordZone+Rx.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 10/08/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

public extension Reactive where Base: CKRecordZone {
    
    public static func fetch(with recordZoneID: CKRecordZoneID, in database: CKDatabase) -> Single<CKRecordZone> {
        return Single<CKRecordZone>.create { single in
            database.fetch(withRecordZoneID: recordZoneID) { (zone, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard zone != nil else {
                    single(.error(RxCKError.fetch))
                    return
                }
                single(.success(zone!))
            }
            return Disposables.create()
        }
    }

    public static func modify(recordZonesToSave: [CKRecordZone]?, recordZoneIDsToDelete: [CKRecordZoneID]?, in database: CKDatabase) -> Single<([CKRecordZone]?, [CKRecordZoneID]?)> {
        return Single<([CKRecordZone]?, [CKRecordZoneID]?)>.create { single in
            let operation = CKModifyRecordZonesOperation(recordZonesToSave: recordZonesToSave, recordZoneIDsToDelete: recordZoneIDsToDelete)
            operation.qualityOfService = .userInitiated
            operation.modifyRecordZonesCompletionBlock = { (saved, deleted, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                single(.success((saved, deleted)))
            }
            database.add(operation)
            return Disposables.create()
        }
    }
    
}
