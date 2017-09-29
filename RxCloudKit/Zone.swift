//
//  Zone.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 12/08/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import CloudKit

/*public*/ class Zone {
    
    public static func id(name: String) -> CKRecordZoneID {
        if #available(iOS 10.0, *) {
            return CKRecordZoneID(zoneName: name, ownerName: CKCurrentUserDefaultName)
        } else {
            return CKRecordZoneID(zoneName: name, ownerName: CKOwnerDefaultName)
        }
    }
    
    public static func create(zoneID: CKRecordZoneID) -> CKRecordZone {
        let zone = CKRecordZone(zoneID: zoneID)
        return zone
    }
    
    public static func create(name: String) -> CKRecordZone {
        let zone = CKRecordZone(zoneName: name)
        return zone
    }
    
}
