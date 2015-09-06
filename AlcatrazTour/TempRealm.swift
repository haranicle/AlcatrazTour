//
//  TempRealm.swift
//  AlcatrazTour
//
//  Created by haranicle on 2015/08/16.
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import RealmSwift

struct RealmFile {
    // CurrentRealm
    static let currentRealmDirPath = NSSearchPathForDirectoriesInDomains(
        .DocumentDirectory,
        .UserDomainMask, true)[0] as! String
    static let tempRealmFileNameSaveKey = "tempRealmFileName"
    
    // TempRealm
    static let tempRealmDirPath = NSTemporaryDirectory()
}

class TempRealm {
    
    convenience init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        var fileName = "\(NSDate()).realm"
        if let name = defaults.objectForKey(RealmFile.tempRealmFileNameSaveKey) as? String {
            // already saved
            fileName = name
        } else {
            // not saved
            defaults.setObject(fileName, forKey: RealmFile.tempRealmFileNameSaveKey)
            defaults.synchronize()
        }
        let filePath = "\(RealmFile.currentRealmDirPath)\(fileName)"
        self.init(Realm(path: filePath))
    }
    
    func updateDefaultRealm() {
        let defaults = NSUserDefaults.standardUserDefaults()
        Realm.defaultPath = defaults.objectForKey(RealmFile.tempRealmFileNameSaveKey) as! String
        delete()
    }
    
    // MARK: Internal
    
    internal var realm: Realm
    
    internal init(_ realm: Realm) {
        self.realm = realm
    }
    
    internal func delete() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let fileName = defaults.objectForKey(RealmFile.tempRealmFileNameSaveKey) as! String
        let filePath = "\(RealmFile.currentRealmDirPath)\(fileName)"
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(filePath, error: nil)
        fileManager.removeItemAtPath("\(filePath).lock", error: nil)
        defaults.removeObjectForKey(RealmFile.tempRealmFileNameSaveKey)
    }
}
