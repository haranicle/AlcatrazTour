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
        if let d = details["watchers_count"] as? Int {
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
        return NSString(format: "%0.2f", score)
    }
    
    // MARK: - Realm
    
    func save() {
        RLMRealm.defaultRealm().addObject(self)
    }
    
    class func deleteAll() {
        RLMRealm.defaultRealm().deleteAllObjects()
    }
    
    // MARK: - Score
    
    func calcScore() {
        let githubScore = watchersCount + starGazersCount + forkCount
        let ageFactor = calcAgeFactor(githubScore)
        score = Float(githubScore) - ageFactor
        println("score = \(score)")
        println("ageFactor = \(ageFactor)")
    }
   
    func calcAgeFactor(githubScore:Int) -> Float {
        return Float(githubScore) * Float(-updatedAt.timeIntervalSinceNow) / 86400.0 / 365
    }
}
