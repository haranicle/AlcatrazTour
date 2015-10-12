//
//  NewestPluginNotification.swift
//  AlcatrazTour
//
//  Created by haranicle on 2015/09/14.
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import RealmSwift

class NewestPluginNotification:NSObject {
    
    let updateNewestPluginNotificationName = "updateNewestPluginNotificationName"
    let newestPluginSaveKey = "newestPluginSaveKey"
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNewestPlugin:", name: updateNewestPluginNotificationName, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: NotificationCenter
    
    func postUpdateNewestPluginNotification() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: updateNewestPluginNotificationName ,object: nil))
    }
    
    func updateNewestPlugin(notification:NSNotification) {
        saveNewestPlugin()
    }
    
    // MARK: UserDefaults
    
    func newestPlugin() -> Plugin? {
        let newestResults:Results<Plugin>
        
        do {
            try newestResults = Realm().objects(Plugin).sorted(Modes.New.propertyName(), ascending: false)
            if newestResults.count <= 0 {
                return nil
            }
            
        } catch {
            fatalError()
        }
        
        return newestResults.first
    }
    
    func saveNewestPlugin() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(newestPlugin(), forKey: newestPluginSaveKey)
    }
    
    func loadNewestPlugin() -> Plugin {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(newestPluginSaveKey) as! Plugin
    }
}
