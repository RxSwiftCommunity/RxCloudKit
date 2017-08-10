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

    public let cloud = Cloud()
    public let zoneIDs: [String]
    public let privateSubscriptionID: String
    public let sharedSubscriptionID: String

    public init(zoneIDs: [String], privateSubscriptionID: String, sharedSubscriptionID: String) {
        self.zoneIDs = zoneIDs
        self.privateSubscriptionID = privateSubscriptionID
        self.sharedSubscriptionID = sharedSubscriptionID
    }

    public func onFirstLaunch() {

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
        
        let subscription = CKDatabaseSubscription.init(subscriptionID: privateSubscriptionID)
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




    }


}
