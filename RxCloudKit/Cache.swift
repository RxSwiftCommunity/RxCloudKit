//
//  Cache.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 10/08/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

public class Cache {
    
    private let disposeBag = DisposeBag()
    
    static let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    static let privateSubscriptionID = "\(appName).privateDatabaseSubscriptionID"
    static let sharedSubscriptionID = "\(appName).sharedDatabaseSubscriptionID"
    static let privateTokenKey = "\(appName).privateDatabaseTokenKey"
    static let sharedTokenKey = "\(appName).sharedDatabaseTokenKey"
    
    public let defaults = UserDefaults.standard
    public let cloud = Cloud()
    public let zoneIDs: [String]
    
    public init(zoneIDs: [String]) {
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
        // Fetch any changes from the server that happened while the app wasn't running
//        createZoneGroup.notify(queue: DispatchQueue.global()) {
//            if self.createdCustomZone {
//                self.fetchChanges(in: .private) { }
//                //                self.fetchChanges(in: .shared) { }
//            }
//        }

    }

    public func applicationDidReceiveRemoteNotification(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as! [String: NSObject]
        guard let notification: CKDatabaseNotification = CKNotification(fromRemoteNotificationDictionary: dict) as? CKDatabaseNotification else { return }

//        viewController!.fetchChanges(in: notification.databaseScope) {
//            completionHandler(.newData)
//        }
    }
    
    public func fetchDatabaseChanges() {
        let token = defaults.object(forKey: Cache.privateTokenKey) as? CKServerChangeToken
        

    }

    public func fetchZoneChanges() {
        let token = defaults.object(forKey: Cache.privateTokenKey) as? CKServerChangeToken
        
        
    }


}
