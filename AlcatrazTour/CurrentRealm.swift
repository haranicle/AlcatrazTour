//
//  CurrentRealm.swift
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
    static let currentRealmFileNameSaveKey = "currentRealmFileName"
    
    // TempRealm
    static let tempRealmDirPath = NSTemporaryDirectory()
}

class CurrentRealm {
    
    convenience init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        var fileName = "\(NSDate()).realm"
        if let name = defaults.objectForKey(RealmFile.currentRealmFileNameSaveKey) as? String {
            // already saved
            fileName = name
        } else {
            // not saved
            defaults.setObject(fileName, forKey: RealmFile.currentRealmFileNameSaveKey)
        }
        let filePath = "\(RealmFile.currentRealmDirPath)\(fileName)"
        self.init(Realm(path: filePath))
    }
    
    func update() {
        delete()
        
        
    }
    
    func delete() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let fileName = defaults.objectForKey(RealmFile.currentRealmFileNameSaveKey) as! String
        let filePath = "\(RealmFile.currentRealmDirPath)\(fileName)"
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(filePath, error: nil)
    }
    
    // MARK: Internal
    internal var realm: Realm
    
    internal init(_ realm: Realm) {
        self.realm = realm
    }
}

class TempRealm {
    
    convenience init(fileName:String) {
        self.init(Realm(path: "\(RealmFile.tempRealmDirPath)\(fileName).realm"))
    }
    
    func delete(fileName:String) {
        let filePath = "\(RealmFile.tempRealmDirPath)\(fileName)"
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(filePath, error: nil)
    }
    
    func copyToCurrentRealm(currentRealm:CurrentRealm) {
        let newCurrentRealmFileName = "\(NSDate()).realm"
        let newCurrentRealmPath = "\(RealmFile.currentRealmDirPath)\(newCurrentRealmFileName)"
        self.realm.writeCopyToPath(newCurrentRealmFileName, encryptionKey: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(newCurrentRealmFileName, forKey: RealmFile.currentRealmFileNameSaveKey)
        currentRealm.delete()
    }
    
    // MARK: Internal
    internal var realm: Realm
    
    internal init(_ realm: Realm) {
        self.realm = realm
    }
}
