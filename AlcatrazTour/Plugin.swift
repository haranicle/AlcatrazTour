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
    
    func updateParams(params:NSDictionary) {
        name = params["name"] as String
        url = params["url"] as String
        note = params["description"] as String
        if let aScreenshot = params["screenshot"] as String? {
            self.screenshot = aScreenshot
        }
    }
   
}
