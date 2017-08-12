//
//  Errors.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 22/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift

public enum RxCKError: Error {
    case delete
    case fetch
    case save
    case unknown
}

public enum SerializationError: Error {
    case structRequired
    case unknownEntity(name: String)
    case unsupportedSubType(label: String?)
}
