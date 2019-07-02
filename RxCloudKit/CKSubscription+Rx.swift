//
//  CKSubscription+Rx.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 25/06/2017.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxSwift
import CloudKit

public extension Reactive where Base: CKSubscription {

    func save(in database: CKDatabase) -> Maybe<CKSubscription> {
        return Maybe<CKSubscription>.create { maybe in
            database.save(self.base) { (result, error) in
                if let error = error {
                    maybe(.error(error))
                    return
                }
                guard result != nil else {
                    maybe(.completed)
                    return
                }
                maybe(.success(result!))
            }
            return Disposables.create()
        }
    }
    
    static func fetch(with subscriptionID: String, in database: CKDatabase) -> Maybe<CKSubscription> {
        return Maybe<CKSubscription>.create { maybe in
            database.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
                if let error = error {
                    maybe(.error(error))
                    return
                }
                guard subscription != nil else {
                    maybe(.completed)
                    return
                }
                maybe(.success(subscription!))
            }
            return Disposables.create()
        }
    }
    
    static func delete(with subscriptionID: String, in database: CKDatabase) -> Maybe<String> {
        return Maybe<String>.create { maybe in
            database.delete(withSubscriptionID: subscriptionID) { (subscriptionID, error) in
                if let error = error {
                    maybe(.error(error))
                    return
                }
                guard subscriptionID != nil else {
                    maybe(.completed)
                    return
                }
                maybe(.success(subscriptionID!))
            }
            return Disposables.create()
        }
    }
    
    static func modify(subscriptionsToSave: [CKSubscription]?, subscriptionIDsToDelete: [String]?, in database: CKDatabase) -> Single<([CKSubscription]?, [String]?)> {
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
