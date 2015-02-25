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
    
    func requestRepoDetail(plugin:Plugin, onSucceed:(Plugin?, NSDictionary) -> Void, onFailed:NSError? -> Void) {
        Alamofire
            .request(.GET, plugin.url)
            .responseJSON {request, response, responseData, error in
                
                if let aError = error {
                    onFailed(aError)
                }
                
                if let aResponseData: AnyObject = responseData {
                    let jsonData = JSON(aResponseData)
                    
                    weak var weakPlugin = plugin
                    
                    if let pluginDetail = jsonData.object as? NSDictionary {
                        onSucceed(weakPlugin, pluginDetail)
                    }
                }
                
                onFailed(nil)
        }
        
    }
    
    // MARK: - Processing Flow
    
    func reloadAllPlugins() {
        
        if(isLoading) {
            println("NOW LOADING!!")
            return
        }
        
        isLoading = true
        loadCompleteCount = 0
        
        Plugin.deleteAll()
        
        // loading plugin list
        
        func onSucceedRequestingPlugins(plugins:[Plugin]) {
            
            // loading plugin details
            
            func onSucceedRequestingRepoDetail(plugin:Plugin?, pluginDetail:NSDictionary) {
                plugin?.setDetails(pluginDetail)
                if let p = plugin {
                    p.save()
                }
                inclementLoadCompleteCount(plugins.count)
            }
            
            func onFailed(error:NSError?) {
                println(error?.description)
                inclementLoadCompleteCount(plugins.count)
            }
            
            for plugin in plugins {
                requestRepoDetail(plugin, onSucceed: onSucceedRequestingRepoDetail, onFailed: onFailed)
            }
            
        }
        
        func onFailed(error:NSError?) {
            println(error?.description)
        }
        
        requestPlugins(onSucceedRequestingPlugins, onFailed: onFailed)
    }
    
    func inclementLoadCompleteCount(pluginsCount:Int) {
        loadCompleteCount++
        if loadCompleteCount == pluginsCount {
            // all done!!
            println("all done!!")
            isLoading = false
            loadCompleteCount = 0
        }
    }
    
    
}
