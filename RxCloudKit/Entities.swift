//
//  Entities.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 22/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

public protocol Entity {
    
    associatedtype T: CKRecord
    associatedtype I: CKRecordID
    
    static var type: String { get }
    
    var name: String { get }
    
    init(record: T)
    
    func update(_ record: T)
    
}
