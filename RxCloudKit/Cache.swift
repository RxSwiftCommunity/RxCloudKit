//
//  Cache.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 10/08/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

typealias ZoneTokenMap = [Data: Data]

public protocol CacheDelegate {
    func cache(record: CKRecord)
    func deleteCache(for recordID: CKRecordID)
    func deleteCache(in zoneID: CKRecordZoneID)
}

public final class Cache {

    static let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    static let privateSubscriptionID = "\(appName).privateDatabaseSubscriptionID"
    static let sharedSubscriptionID = "\(appName).sharedDatabaseSubscriptionID"
    static let privateTokenKey = "\(appName).privateDatabaseTokenKey"
    static let sharedTokenKey = "\(appName).sharedDatabaseTokenKey"
    static let zoneTokenMapKey = "\(appName).zoneTokenMapKey"

    public let defaults = UserDefaults.standard
    public let cloud = Cloud()
    public let zoneIDs: [String]

    private let delegate: CacheDelegate
    private let disposeBag = DisposeBag()
    private var cachedZoneIDs: [CKRecordZoneID] = []

    public init(delegate: CacheDelegate, zoneIDs: [String]) {
        self.delegate = delegate
        self.zoneIDs = zoneIDs
    }

    public func applicationDidFinishLaunching() {

        // TODO fetch zones, for missing zones create zones

        for zoneID in zoneIDs.map({ Zone.id(name: $0) }) {

            cloud.privateDB.rx.fetch(with: zoneID).subscribe { event in
                switch event {
                case .success(let zone):
                    print("\(zone)")
                case .error(let error):
                    print("Error: ", error)
                }
            }.disposed(by: disposeBag)

            let zone = Zone.create(zoneID: zoneID)

            cloud.privateDB.rx.modify(recordZonesToSave: [zone], recordZoneIDsToDelete: nil).subscribe { event in
                switch event {
                case .success(let (saved, deleted)):
                    print("\(saved)")
                case .error(let error):
                    print("Error: ", error)
                }
            }.disposed(by: disposeBag)

        }

        let subscription = CKDatabaseSubscription.init(subscriptionID: Cache.privateSubscriptionID)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        cloud.privateDB.rx.modify(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil).subscribe { event in
            switch event {
            case .success(let (saved, deleted)):
                print("\(saved)")
            case .error(let error):
                print("Error: ", error)
            }
        }.disposed(by: disposeBag)

        // TODO same for shared

        //let createZoneGroup = DispatchGroup()
        //createZoneGroup.enter()
        //self.createZoneGroup.leave()
//        createZoneGroup.notify(queue: DispatchQueue.global()) {
//        }

    }

    public func applicationDidReceiveRemoteNotification(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as! [String: NSObject]
        guard let notification: CKDatabaseNotification = CKNotification(fromRemoteNotificationDictionary: dict) as? CKDatabaseNotification else { return }
        self.fetchDatabaseChanges(fetchCompletionHandler: completionHandler)
    }

    public func fetchDatabaseChanges(fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let token = self.token(for: Cache.privateTokenKey)
        cloud.privateDB.rx.fetchChanges(previousServerChangeToken: token).subscribe { event in
            switch event {
            case .next(let zoneEvent):
                print("\(zoneEvent)")
                
                switch zoneEvent {
                case .changed(let zoneID):
                    print("changed: \(zoneID)")
                    self.cacheChanged(zoneID: zoneID)
                case .deleted(let zoneID):
                    print("deleted: \(zoneID)")
                    self.delegate.deleteCache(in: zoneID)
                case .token(let token):
                    print("token: \(token)")
                    self.save(token: token, for: Cache.privateTokenKey)
                    self.processAndPurgeCachedZones(fetchCompletionHandler: completionHandler)
                }
                
            case .error(let error):
                print("Error: ", error)
                completionHandler(.failed)
            case .completed:
                
                if self.cachedZoneIDs.count == 0 {
                    completionHandler(.noData)
                }
                
            }
        }.disposed(by: disposeBag)
    }

    public func fetchZoneChanges(recordZoneIDs: [CKRecordZoneID], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        var optionsByRecordZoneID: [CKRecordZoneID: CKFetchRecordZoneChangesOptions] = [:]

        if let tokenMap = defaults.object(forKey: Cache.zoneTokenMapKey) as? ZoneTokenMap {
            
            for recordZoneID in recordZoneIDs {
                
                if let token = tokenMap[self.key(zoneID: recordZoneID)] {
                    let options = CKFetchRecordZoneChangesOptions()
                    options.previousServerChangeToken = self.value(token: token)
                    optionsByRecordZoneID[recordZoneID] = options
                }
                
            }
            
        } else {
            defaults.set(ZoneTokenMap(), forKey: Cache.zoneTokenMapKey)
        }

        cloud.privateDB.rx.fetchChanges(recordZoneIDs: recordZoneIDs, optionsByRecordZoneID: optionsByRecordZoneID).subscribe { event in
            switch event {
            case .next(let recordEvent):
                print("\(recordEvent)")
                
                switch recordEvent {
                case .changed(let record):
                    print("changed: \(record)")
                    self.delegate.cache(record: record)
                case .deleted(let recordID):
                    print("deleted: \(recordID)")
                    self.delegate.deleteCache(for: recordID)
                case .token(let (zoneID, token)):
                    print("token: \(zoneID)->\(token)")
                    self.save(zoneID: zoneID, token: token, for: Cache.zoneTokenMapKey)
                }
                
            case .error(let error):
                print("Error: ", error)
                completionHandler(.failed)
            case .completed:
                completionHandler(.newData)
            }
        }.disposed(by: disposeBag)
    }
    
    public func cacheChanged(zoneID: CKRecordZoneID) {
        self.cachedZoneIDs.append(zoneID)
    }
    
    public func processAndPurgeCachedZones(fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let recordZoneIDs = self.cachedZoneIDs
        self.cachedZoneIDs = []
        self.fetchZoneChanges(recordZoneIDs: recordZoneIDs, fetchCompletionHandler: completionHandler)
    }


    // MARK:- token
    
    private func save(token: CKServerChangeToken, for key: String) {
        self.defaults.set(self.value(token: token), forKey: key)
    }
    
    private func token(for key: String) -> CKServerChangeToken? {
        
        if let object = self.defaults.object(forKey: key) as? NSData {
            return self.value(token: object as Data)
        }
        
        return nil
    }
    
    private func save(zoneID: CKRecordZoneID, token: CKServerChangeToken, for key: String) {
        let aZoneID = self.key(zoneID: zoneID) as Data
        let aToken = self.value(token: token)
        if var tokenMap = self.defaults.object(forKey: key) as? ZoneTokenMap {
            tokenMap[aZoneID] = aToken
            self.defaults.set(tokenMap, forKey: Cache.zoneTokenMapKey)
        }
    }
    
    private func key(zoneID: CKRecordZoneID) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: zoneID)
    }
    
    private func value(token: CKServerChangeToken) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: token)
    }
    
    private func value(token: Data) ->  CKServerChangeToken? {
        return NSKeyedUnarchiver.unarchiveObject(with: token) as? CKServerChangeToken
    }
    
}
