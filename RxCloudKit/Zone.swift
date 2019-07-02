//
//  Zone.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 12/08/2017.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import CloudKit

/*public*/ class Zone {
    
    public static func id(name: String) -> CKRecordZone.ID {
        if #available(iOS 10.0, *) {
            return CKRecordZone.ID(zoneName: name, ownerName: CKCurrentUserDefaultName)
        } else {
            return CKRecordZone.ID(zoneName: name, ownerName: CKOwnerDefaultName)
        }
    }
    
    public static func create(zoneID: CKRecordZone.ID) -> CKRecordZone {
        let zone = CKRecordZone(zoneID: zoneID)
        return zone
    }
    
    public static func create(name: String) -> CKRecordZone {
        let zone = CKRecordZone(zoneName: name)
        return zone
    }
    
}
