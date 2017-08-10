//
//  Cloud.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 10/08/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

public class Cloud {
    
    public let container: CKContainer
    public let privateDB: CKDatabase
    public let sharedDB: CKDatabase
    public let publicDB: CKDatabase
    
    public init() {
        self.container = CKContainer.default()
        self.privateDB = container.privateCloudDatabase
        self.sharedDB = container.sharedCloudDatabase
        self.publicDB = container.publicCloudDatabase
    }
    
}
