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
    
    func setParams(params:NSDictionary) {
        if let p = params["name"] as? String {
            self.name = p
        }
        if let p = params["url"] as? String {
            self.url = p
        }
        if let p = params["description"] as? String {
            self.note = p
        }
        if let p = params["screenshot"] as? String {
            self.screenshot = p
        }
    }
   
}
