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

    public static func fetch(with recordZoneID: CKRecordZoneID, in database: CKDatabase) -> Maybe<CKRecordZone> {
        return Maybe<CKRecordZone>.create { maybe in
            database.fetch(withRecordZoneID: recordZoneID) { (zone, error) in
                if let error = error {
                    maybe(.error(error))
                    return
                }
                guard zone != nil else {
                    maybe(.completed)
                    return
                }
                maybe(.success(zone!))
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

    public static func fetchChanges(previousServerChangeToken: CKServerChangeToken?, limit: Int = 99, in database: CKDatabase) -> Observable<ZoneEvent> {
        return Observable.create { observer in
            _ = ZoneChangeFetcher(observer: observer, database: database, previousServerChangeToken: previousServerChangeToken, limit: limit)
            return Disposables.create()
        }
    }

}
