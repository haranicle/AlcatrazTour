//
//  NewcomerPluginNotificator.swift
//  AlcatrazTour
//
//  Created by kazushi.hara on 2015/10/13.
//  Copyright © 2015年 haranicle. All rights reserved.
//

import Foundation

class NewcomerPluginNotificator {
    
    func checkIfNewcomerExists(plugins:[Plugin]) {
        let exists = true
        if exists {
            // notificate newcomer
//            if appInForeground {
//                
//            } else {
//                // local push
//            }
        }
        
        saveLastLoadedPlugins(plugins)
    }
    
    // MARK: User Defaults
    
    let lastLoadedPluginsSaveKey = "lastLoadedPluginsSaveKey"
    
    func saveLastLoadedPlugins(plugins:[Plugin]) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(plugins, forKey: lastLoadedPluginsSaveKey)
    }
    
    func loadLastLoadedPlugins() -> [Plugin] {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(lastLoadedPluginsSaveKey) as! [Plugin]
    }


}