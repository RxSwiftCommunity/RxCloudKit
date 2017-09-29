//
//  CKSubscription+Rx.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 25/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

public extension Reactive where Base: CKSubscription {

    public func save(in database: CKDatabase) -> Single<CKSubscription> {
        return Single<CKSubscription>.create { single in
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
    
    public static func fetch(with subscriptionID: String, in database: CKDatabase) -> Single<CKSubscription> {
        return Single<CKSubscription>.create { single in
            database.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard subscription != nil else {
                    single(.error(RxCKError.fetch))
                    return
                }
                single(.success(subscription!))
            }
            return Disposables.create()
        }
    }
    
    public static func delete(with subscriptionID: String, in database: CKDatabase) -> Single<String> {
        return Single<String>.create { single in
            database.delete(withSubscriptionID: subscriptionID) { (subscriptionID, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard subscriptionID != nil else {
                    single(.error(RxCKError.delete))
                    return
                }
                single(.success(subscriptionID!))
            }
            return Disposables.create()
        }
    }
    
    public static func modify(subscriptionsToSave: [CKSubscription]?, subscriptionIDsToDelete: [String]?, in database: CKDatabase) -> Single<([CKSubscription]?, [String]?)> {
        return Single<([CKSubscription]?, [String]?)>.create { single in
            let operation = CKModifySubscriptionsOperation(subscriptionsToSave: subscriptionsToSave, subscriptionIDsToDelete: subscriptionIDsToDelete)
            operation.qualityOfService = .utility
            operation.modifySubscriptionsCompletionBlock = { (subscriptions, deletedIds, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                single(.success((subscriptions, deletedIds)))
            }
            database.add(operation)
            return Disposables.create()
        }
    }

    /*
     func fetchAllSubscriptions(completionHandler: ([CKSubscription]?, Error?) -> Void)
     Fetches all subscription objects asynchronously, with a low priority, from the current database.
     */

}
