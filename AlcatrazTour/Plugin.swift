//
//  Plugin.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import Realm

class Plugin: RLMObject {
    
    dynamic var uuid = NSUUID().UUIDString
    dynamic var name = ""
    dynamic var url = ""
    dynamic var note = ""
    dynamic var screenshot = ""
    
    // details
    dynamic var avaterUrl = ""
    dynamic var starGazersCount:Int = 0 // star
    dynamic var updatedAt:NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var createdAt:NSDate = NSDate(timeIntervalSince1970: 0)
    
    // MARK: - Params
    
    func setParams(params:NSDictionary) {
        if let p = params["name"] as? String {
            name = p
        }
        if let p = params["url"] as? String {
            url = p
        }
        if let p = params["description"] as? String {
            note = p
        }
        if let p = params["screenshot"] as? String {
            screenshot = p
        }
    }
    
    func setDetails(details:NSDictionary) {
        if let d = details["owner"]?["avatar_url"] as? String {
            avaterUrl = d
        }
        if let d = details["stargazers_count"] as? Int {
            starGazersCount = d
        }
        if let d = details["updated_at"] as? NSString {
            updatedAt = stringAsDate(d)
        }
        if let d = details["created_at"] as? NSString {
            createdAt = stringAsDate(d)
        }
    }
    
    func stringAsDate(string:String) -> NSDate {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        return formatter.dateFromString(string) ?? NSDate(timeIntervalSince1970: 0)
    }
    
    // MARK: - Realm
    func save() {
        let realm = RLMRealm.defaultRealm()
        realm.transactionWithBlock{
            realm.addObject(self)
        }
    }
    
    class func deleteAll() {
        let realm = RLMRealm.defaultRealm()
        realm.transactionWithBlock{
            realm.deleteAllObjects()
        }
    }
   
}
