//
//  Errors.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 22/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift

enum RxCKError: Error {
    case deleteRecord
    case fetchRecord
    case saveRecord
    case unknown
}
