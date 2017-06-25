//
//  CKRecord+Rx.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 25/06/2017.
//  Copyright © 2017 Maxim Volgin. All rights reserved.
//

import RxSwift
import CloudKit

public extension Reactive where Base: CKRecord {

    public func save(in database: CKDatabase) -> Single<CKRecord> {
        return Single<CKRecord>.create { single in
            database.save(self.base) { (result, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard result != nil else {
                    single(.error(RxCKError.save))
                    return
                }
                single(.success(result!))
            }
            return Disposables.create()
        }
    }

}

