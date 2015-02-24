//
//  GithubClient.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GithubClient: NSObject {
    
    let alcatrazPackagesUrlString = "https://raw.githubusercontent.com/supermarin/alcatraz-packages/master/packages.json"
    
    func requestPlugins() {
        Alamofire
            .request(.GET, alcatrazPackagesUrlString)
            .responseJSON {request, response, responseData, error in
                
                println("request = \(request)")
                println("response = \(response)")
                println("responseData = \(responseData)")
                println("error = \(error)")
                
                if let aError = error {
                    // onFailed(aError)
                }
                
                if let aResponseData: AnyObject = responseData {
                    println("Success")
                    
                    var plugins:[Plugin] = []
                    
                    let jsonData = JSON(aResponseData)
                    let jsonPlugins = jsonData["packages"]["plugins"].array
                    
                    if let count = jsonPlugins?.count {
                        for i in 0 ..< count {
                            if let pluginParams = jsonPlugins?[i].dictionaryObject {
                                var plugin = Plugin()
                                plugin.updateParams(pluginParams)
                            }
                        }
                    }
                    
                    // onSucceed(plugins)
                }
        }
    }
    
   
}
