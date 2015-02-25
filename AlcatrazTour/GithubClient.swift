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
    
    let alcatrazPackagesUrl = "https://raw.githubusercontent.com/supermarin/alcatraz-packages/master/packages.json"
    
    let githubRepoUrl = "https://github.com"
    let githubRepoApiUrl = "https://api.github.com/repos"
    
    // MARK: - Create URL
    
    func createRepoDetailUrl(repoUrl:String) -> String {
        return repoUrl.stringByReplacingOccurrencesOfString(githubRepoUrl, withString: githubRepoApiUrl, options: nil, range: nil)
    }
    
    // MARK: - Request
    
    func requestPlugins(onSucceed:[Plugin] -> Void, onFailed:NSError? -> Void) {
        Alamofire
            .request(.GET, alcatrazPackagesUrl)
            .responseJSON {request, response, responseData, error in
                
                if let aError = error {
                    onFailed(aError)
                }
                
                if let aResponseData: AnyObject = responseData {
                    
                    var plugins:[Plugin] = []
                    
                    let jsonData = JSON(aResponseData)
                    let jsonPlugins = jsonData["packages"]["plugins"].array
                    
                    if let count = jsonPlugins?.count {
                        for i in 0 ..< count {
                            if let pluginParams = jsonPlugins?[i].object as? NSDictionary {
                                var plugin = Plugin()
                                plugin.setParams(pluginParams)
                                plugins.append(plugin)
                            }
                        }
                    }
                    
                    onSucceed(plugins)
                }
                
                onFailed(nil)
        }
    }
    
    func requestRepoDetail(url:String, onSucceed:NSDictionary -> Void, onFailed:NSError? -> Void) {
        Alamofire
            .request(.GET, url)
            .responseJSON {request, response, responseData, error in
                
                if let aError = error {
                    onFailed(aError)
                }
                
                if let aResponseData: AnyObject = responseData {
                    let jsonData = JSON(aResponseData)
                    
                    if let pluginDetail = jsonData.object as? NSDictionary {
                        onSucceed(pluginDetail)
                    }
                }
                
                onFailed(nil)
        }
        
    }
    
    
}
