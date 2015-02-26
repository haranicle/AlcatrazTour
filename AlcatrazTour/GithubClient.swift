//
//  GithubClient.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Realm

class GithubClient: NSObject {
    
    // MARK: - Const
    
    let alcatrazPackagesUrl = "https://raw.githubusercontent.com/supermarin/alcatraz-packages/master/packages.json"
    
    let githubRepoUrl = "https://github.com"
    let githubRepoApiUrl = "https://api.github.com/repos"
    
    // MARK: - Status
    
    var isLoading = false
    var loadCompleteCount = 0
    
    // MARK: - Create URL
    
    func createRepoDetailUrl(repoUrl:String) -> String {
        return repoUrl.stringByReplacingOccurrencesOfString(githubRepoUrl, withString: githubRepoApiUrl, options: nil, range: nil)
    }
    
    // MARK: - Request
    
    func requestPlugins(onSucceed:[Plugin] -> Void, onFailed:(NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        Alamofire
            .request(.GET, alcatrazPackagesUrl)
            .responseJSON {request, response, responseData, error in
                
                if let aError = error {
                    onFailed(request, response, responseData, aError)
                    return
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
                } else {
                    onFailed(request, response, responseData, nil)
                }
        }
    }
    
    func requestRepoDetail(plugin:Plugin, onSucceed:(Plugin?, NSDictionary) -> Void, onFailed:(NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        Alamofire
            .request(.GET, createRepoDetailUrl(plugin.url))
            .responseJSON {request, response, responseData, error in
                
                if let aError = error {
                    onFailed(request, response, responseData, aError)
                    return
                }
                
                if let aResponseData: AnyObject = responseData {
                    let jsonData = JSON(aResponseData)
                    
                    weak var weakPlugin = plugin
                    
                    if let pluginDetail = jsonData.object as? NSDictionary {
                        onSucceed(weakPlugin, pluginDetail)
                    }
                } else {
                    onFailed(request, response, responseData, nil)
                }
        }
        
    }
    
    // MARK: - Processing Flow
    
    func reloadAllPlugins() {
        
        if(isLoading) {
            println("NOW LOADING!!")
            return
        }
        
        println("START LOADING!!")
        
        isLoading = true
        loadCompleteCount = 0
        
        Plugin.deleteAll()
        
        // loading plugin list
        
        func onSucceedRequestingPlugins(plugins:[Plugin]) {
            
            println("PLUGIN LIST LOAD COMPLETE!!")
            
            // loading plugin details
            
            func onSucceedRequestingRepoDetail(plugin:Plugin?, pluginDetail:NSDictionary) {
                
                println("pluginDetail = \(pluginDetail)")
                
                plugin?.setDetails(pluginDetail)
                if let p = plugin {
                    p.save()
                }
                inclementLoadCompleteCount(plugins.count)
            }
            
            func onFailed(request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) {
                println("request = \(request)")
                println("response = \(response)")
                println("responseData = \(responseData)")
                println("error = \(error?.description)")
                inclementLoadCompleteCount(plugins.count)
            }
            
            for plugin in plugins {
                requestRepoDetail(plugin, onSucceed: onSucceedRequestingRepoDetail, onFailed: onFailed)
            }
            
        }
        
        func onFailed(request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) {
            println("request = \(request)")
            println("response = \(response)")
            println("responseData = \(responseData)")
            println("error = \(error?.description)")
        }
        
        requestPlugins(onSucceedRequestingPlugins, onFailed: onFailed)
    }
    
    func inclementLoadCompleteCount(pluginsCount:Int) {
        loadCompleteCount++
        if loadCompleteCount == pluginsCount {
            println("ALL DONE!!")
            isLoading = false
            loadCompleteCount = 0
        }
    }
    
    
}
