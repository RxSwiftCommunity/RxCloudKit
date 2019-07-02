//
//  Local.swift
//  RxCloudKit
//
//  Created by Maxim Volgin on 11/08/2017.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//
// local storage for Cache class

import UIKit
import CloudKit

public typealias ZoneTokenMap = [CKRecordZone.ID: CKServerChangeToken]

public final class Local {

    private let defaults = UserDefaults.standard

    // MARK:- public

    // MARK:- subscription

    public func subscriptionID(for key: String) -> String? {
        return self.defaults.string(forKey: key)
    }

    public func save(subscriptionID: String, for key: String) {
        self.defaults.set(subscriptionID, forKey: key)
    }

    // MARK:- token

    public func save(token: CKServerChangeToken, for key: String) {
        self.defaults.set(self.value(token: token), forKey: key)
    }

    public func token(for key: String) -> CKServerChangeToken? {
        if let object = self.defaults.object(forKey: key) as? NSData {
            return self.value(token: object as Data)
        }
        return nil
    }

    public func zoneTokenMap(for key: String) -> ZoneTokenMap {
        if let data = self.data(for: key) {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? ZoneTokenMap ?? ZoneTokenMap()
        }
        return ZoneTokenMap()
    }

    public func save(zoneID: CKRecordZone.ID, token: CKServerChangeToken, for key: String) {
        var zoneTokenMap = self.zoneTokenMap(for: key)
        zoneTokenMap[zoneID] = token
        self.save(zoneTokenMap: zoneTokenMap, for: key)
    }

    // MARK:- private

    private func data(for key: String) -> Data? {
        return self.defaults.object(forKey: key) as? Data
    }

    private func save(zoneTokenMap: ZoneTokenMap, for key: String) {
        let data = NSKeyedArchiver.archivedData(withRootObject: zoneTokenMap)
        self.defaults.set(data, forKey: key)
    }

    private func key(zoneID: CKRecordZone.ID) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: zoneID)
    }

    private func value(token: CKServerChangeToken) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: token)
    }

    private func value(token: Data) -> CKServerChangeToken? {
        return NSKeyedUnarchiver.unarchiveObject(with: token) as? CKServerChangeToken
    }

}

