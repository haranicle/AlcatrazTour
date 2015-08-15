//
//  Plugin.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import RealmSwift

class Plugin: Object {
    
    dynamic var uuid = NSUUID().UUIDString
    override class func primaryKey() -> String {
        return "uuid"
    }
    
    dynamic var name = ""
    dynamic var url = ""
    dynamic var note = ""
    dynamic var screenshot = ""
    dynamic var type = 0
    
    // details
    dynamic var owner = ""
    dynamic var repositoryName  = ""
    dynamic var avaterUrl = ""
    dynamic var starGazersCount:Int = 0
    dynamic var updatedAt:NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var createdAt:NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var watchersCount:Int = 0
    dynamic var forkCount:Int = 0
    
    // score
    dynamic var score:Float = 0.0
    
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
        if let d = details["owner"]?["login"] as? String {
            owner = d
        }
        if let d = details["name"] as? String {
            repositoryName = d
        }
        if let d = details["owner"]?["avatar_url"] as? String {
            avaterUrl = d
        }
        if let d = details["stargazers_count"] as? Int {
            starGazersCount = d
        }
        if let d = details["pushed_at"] as? NSString {
            updatedAt = stringAsDate(d as String)
        }
        if let d = details["created_at"] as? NSString {
            createdAt = stringAsDate(d as String)
        }
        if let d = details["subscribers_count"] as? Int {
            watchersCount = d
        }
        if let d = details["forks"] as? Int {
            forkCount = d
        }
        calcScore()
    }
    
    func stringAsDate(string:String) -> NSDate {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        return formatter.dateFromString(string) ?? NSDate(timeIntervalSince1970: 0)
    }
    
    func scoreAsString() -> String {
        return NSString(format: "%0.2f", score) as String
    }
    
    // TODO: must be tested!!
    func formatDate(date:NSDate) -> String {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.stringFromDate(date)
    }
    
    func updatedAtAsString() -> String {
        return formatDate(updatedAt)
    }
    
    func createdAtAsString() -> String {
        return formatDate(createdAt)
    }
    
    // MARK: - Realm
    
    func save() {
        Realm().add(self, update: true)
    }
    
    class func deleteAll() {
        Realm().deleteAll()
    }
    
    // MARK: - Score
    
    func calcScore() {
        let githubScore = watchersCount + starGazersCount + forkCount
        score = 100 * Float(githubScore) / intervalFromCreated()
    }
   
    func intervalFromCreated() -> Float {
        return Float(-createdAt.timeIntervalSinceNow) / 86400.0
    }
}
