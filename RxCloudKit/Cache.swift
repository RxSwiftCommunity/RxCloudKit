//
//  Cache.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 10/08/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import os.log
import RxSwift
import CloudKit

public protocol CacheDelegate {
    // private db
    func cache(record: CKRecord)
    func deleteCache(for recordID: CKRecord.ID)
    func deleteCache(in zoneID: CKRecordZone.ID)
    // any db (via subscription)
    func query(notification: CKQueryNotification, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
}

public final class Cache {

    static let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    static let privateSubscriptionID = "\(appName).privateDatabaseSubscriptionID"
    static let sharedSubscriptionID = "\(appName).sharedDatabaseSubscriptionID"
    static let privateTokenKey = "\(appName).privateDatabaseTokenKey"
    static let sharedTokenKey = "\(appName).sharedDatabaseTokenKey"
    static let zoneTokenMapKey = "\(appName).zoneTokenMapKey"

    public let cloud = Cloud()
    public let zoneIDs: [String]
    public let local = Local()

    private let delegate: CacheDelegate
    private let disposeBag = DisposeBag()
    private var cachedZoneIDs: [CKRecordZone.ID] = []
//    private var missingZoneIDs: [CKRecordZoneID] = []

    public init(delegate: CacheDelegate, zoneIDs: [String]) {
        self.delegate = delegate
        self.zoneIDs = zoneIDs
    }

    public func applicationDidFinishLaunching(fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void = { _ in }) {

        let zones = zoneIDs.map({ Zone.create(name: $0) })

        cloud
            .privateDB
            .rx
            .modify(recordZonesToSave: zones, recordZoneIDsToDelete: nil).subscribe { event in
                switch event {
                case .success(let (saved, deleted)):
                    os_log("saved", log: Log.cache, type: .info)
                case .error(let error):
                    os_log("error: %@", log: Log.cache, type: .error, error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)

        if let subscriptionId = self.local.subscriptionID(for: Cache.privateSubscriptionID) {
//            cloud
//                .privateDB
//                .rx
//                .fetch(with: subscriptionId)
            // TODO
            //                        let subscription = CKDatabaseSubscription.init(subscriptionID: Cache.privateSubscriptionID)
        } else {

            let subscription = CKDatabaseSubscription()
            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            subscription.notificationInfo = notificationInfo

            cloud
                .privateDB
                .rx
                .modify(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil).subscribe { event in
                    switch event {
                    case .success(let (saved, deleted)):
                        os_log("saved", log: Log.cache, type: .info)
                        if let subscriptions = saved {
                            for subscription in subscriptions {
                                self.local.save(subscriptionID: subscription.subscriptionID, for: Cache.privateSubscriptionID)
                            }
                        }
                    case .error(let error):
                        os_log("error: %@", log: Log.cache, type: .error, error.localizedDescription)
                    }
                }
                .disposed(by: disposeBag)
        }

        // TODO same for shared

        //let createZoneGroup = DispatchGroup()
        //createZoneGroup.enter()
        //self.createZoneGroup.leave()
//        createZoneGroup.notify(queue: DispatchQueue.global()) {
//        }

        self.fetchDatabaseChanges(fetchCompletionHandler: completionHandler)

    }

    public func applicationDidReceiveRemoteNotification(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        
        guard let notificationType = notification?.notificationType else {
            return
        }
        
        switch notificationType {
        case CKNotificationType.query:
            let queryNotification = notification as! CKQueryNotification
            self.delegate.query(notification: queryNotification, fetchCompletionHandler: completionHandler)
        case CKNotificationType.database:
            self.fetchDatabaseChanges(fetchCompletionHandler: completionHandler)
        case CKNotificationType.readNotification:
            // TODO
            break
        case CKNotificationType.recordZone:
            // TODO
            break
        default:
            // TODO
            break
        }
    }

    public func fetchDatabaseChanges(fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let token = self.local.token(for: Cache.privateTokenKey)
        cloud.privateDB.rx.fetchChanges(previousServerChangeToken: token).subscribe { event in
            switch event {
            case .next(let zoneEvent):
                print("\(zoneEvent)")

                switch zoneEvent {
                case .changed(let zoneID):
                    os_log("changed: %@", log: Log.cache, type: .info, zoneID)
                    self.cacheChanged(zoneID: zoneID)
                case .deleted(let zoneID):
                    os_log("deleted: %@", log: Log.cache, type: .info, zoneID)
                    self.delegate.deleteCache(in: zoneID)
                case .token(let token):
                    os_log("token: %@", log: Log.cache, type: .info, token)
                    self.local.save(token: token, for: Cache.privateTokenKey)
                    self.processAndPurgeCachedZones(fetchCompletionHandler: completionHandler)
                }

            case .error(let error):
                os_log("error: %@", log: Log.cache, type: .error, error.localizedDescription)
                completionHandler(.failed)
            case .completed:

                if self.cachedZoneIDs.count == 0 {
                    completionHandler(.noData)
                }

            }
        }.disposed(by: disposeBag)
    }

    public func fetchZoneChanges(recordZoneIDs: [CKRecordZone.ID], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        var optionsByRecordZoneID: [CKRecordZone.ID: CKFetchRecordZoneChangesOperation.ZoneOptions] = [:]

        let tokenMap = self.local.zoneTokenMap(for: Cache.zoneTokenMapKey)
        for recordZoneID in recordZoneIDs {
            if let token = tokenMap[recordZoneID] {
                let options = CKFetchRecordZoneChangesOperation.ZoneOptions()
                options.previousServerChangeToken = token
                optionsByRecordZoneID[recordZoneID] = options
            }
        }

        cloud
            .privateDB
            .rx
            .fetchChanges(recordZoneIDs: recordZoneIDs, optionsByRecordZoneID: optionsByRecordZoneID).subscribe { event in
                switch event {
                case .next(let recordEvent):
                    print("\(recordEvent)")

                    switch recordEvent {
                    case .changed(let record):
                        os_log("changed: %@", log: Log.cache, type: .info, record)
                        self.delegate.cache(record: record)
                    case .deleted(let recordID):
                        os_log("deleted: %@", log: Log.cache, type: .info, recordID)
                        self.delegate.deleteCache(for: recordID)
                    case .token(let (zoneID, token)):
                        os_log("token: %@", log: Log.cache, type: .info, "\(zoneID)->\(token)")
                        self.local.save(zoneID: zoneID, token: token, for: Cache.zoneTokenMapKey)
                    }

                case .error(let error):
                    os_log("error: %@", log: Log.cache, type: .error, error.localizedDescription)
                    completionHandler(.failed)
                case .completed:
                    completionHandler(.newData)
                }
            }
            .disposed(by: disposeBag)
    }

    public func cacheChanged(zoneID: CKRecordZone.ID) {
        self.cachedZoneIDs.append(zoneID)
    }

    public func processAndPurgeCachedZones(fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard !self.cachedZoneIDs.isEmpty else {
            completionHandler(.noData)
            return
        }

        let recordZoneIDs = self.cachedZoneIDs
        self.cachedZoneIDs = []
        self.fetchZoneChanges(recordZoneIDs: recordZoneIDs, fetchCompletionHandler: completionHandler)
    }

}
