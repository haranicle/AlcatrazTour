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
import OAuthSwift
import SVProgressHUD

class GithubClient: NSObject {
    
    // MARK: - Const
    
    let alcatrazPackagesUrl = "https://raw.githubusercontent.com/supermarin/alcatraz-packages/master/packages.json"
    
    let githubRepoUrl = "https://github.com"
    let githubRepoApiUrl = "https://api.github.com/repos"
    
    // MARK: - Status
    
    var isLoading = false
    var loadCompleteCount:Int = 0
    
    // MARK: - Create URL
    
    func createRepoDetailUrl(repoUrl:String) -> String {
        // create api url
        var repoDetailUrl:String = repoUrl.stringByReplacingOccurrencesOfString(githubRepoUrl, withString: githubRepoApiUrl, options: nil, range: nil)
        // remove last "/"
        if repoDetailUrl.hasSuffix("/") {
            repoDetailUrl = repoDetailUrl[repoDetailUrl.startIndex..<advance(repoDetailUrl.endIndex, -1)]
        }
        // remove last ".git"
        if repoDetailUrl.hasSuffix(".git") {
            repoDetailUrl = repoDetailUrl[repoDetailUrl.startIndex..<advance(repoDetailUrl.endIndex, -4)]
        }
        
        return repoDetailUrl
    }
    
    // MARK: - OAuth
    let githubOauthTokenKey = "githubTokenKey"
    
    func isSignedIn()->Bool {
        if let token = NSUserDefaults.standardUserDefaults().stringForKey(githubOauthTokenKey) {
            return true
        }
        return false
    }
    
    func signOut() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(githubOauthTokenKey)
    }
    
    func requestOAuth(onSucceed:Void->Void, onFailed:NSError -> Void ){
        let oauthswift = OAuth2Swift(
            consumerKey:    GithubKey["consumerKey"]!,
            consumerSecret: GithubKey["consumerSecret"]!,
            authorizeUrl:   "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType:   "code"
        )
        
        func callOnSucceed(credential: OAuthSwiftCredential, response: NSURLResponse?) -> Void {
            // save tokent to user default
            println("AUTH COMPLETE!!")
            
            NSUserDefaults.standardUserDefaults().setObject(credential.oauth_token, forKey: githubOauthTokenKey)
            onSucceed()
        }
        
        oauthswift.authorizeWithCallbackURL( NSURL(string: "alcatraztour://oauth-callback/github")!, scope: "user,repo", state: "GITHUB", success:callOnSucceed, failure:onFailed)
    }
    
    // MARK: - Request
    
    func requestPlugins(onSucceed:[Plugin] -> Void, onFailed:(NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        Alamofire
            .request(.GET, alcatrazPackagesUrl)
            .validate(statusCode: 200..<400)
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
        
        let token = NSUserDefaults.standardUserDefaults().stringForKey(githubOauthTokenKey)
        if(token == nil) {
            println("TOKEN NOT SAVED!")
            return
        }
        
        Alamofire
            .request(Method.GET, createRepoDetailUrl(plugin.url), parameters: ["access_token": token!])
            .validate(statusCode: 200..<400)
            .responseJSON {request, response, responseData, error in
                
                if let aError = error {
                    onFailed(request, response, responseData, aError)
                    return
                }
                
                if let aResponseData: AnyObject = responseData {
                    let jsonData = JSON(aResponseData)
                    
                    if let pluginDetail = jsonData.object as? NSDictionary {
                        onSucceed(plugin, pluginDetail)
                    }
                } else {
                    onFailed(request, response, responseData, nil)
                }
        }
        
    }
    
    // MARK: - Processing Flow
    
    func reloadAllPlugins(onComplete:NSError?->Void) {
        
        if(isLoading) {
            println("NOW LOADING!!")
            return
        }
        
        println("START LOADING!!")
        SVProgressHUD.showWithStatus("Loading list", maskType: SVProgressHUDMaskType.Black)
        
        isLoading = true
        loadCompleteCount = 0
        
        // loading plugin list
        
        func onSucceedRequestingPlugins(plugins:[Plugin]) {
            
            println("PLUGIN LIST LOAD COMPLETE!!")
            
            SVProgressHUD.dismiss()
            SVProgressHUD.showProgress(0, status: "Loading data", maskType: SVProgressHUDMaskType.Black)
            
            // Dispatch Group
            let group = dispatch_group_create()
            var successCount = 0
            
            // loading plugin details
            
            func onSucceedRequestingRepoDetail(plugin:Plugin?, pluginDetail:NSDictionary) {
                
                println("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
                println("plugin.name = \(plugin?.name)")
                println("plugin.url = \(plugin?.url)")
                println("plugin.repoUrl = \(createRepoDetailUrl(plugin!.url))")
                println("pluginDetail = \(pluginDetail)")
                
                plugin?.setDetails(pluginDetail)
                if let p = plugin {
                    p.save()
                }
                successCount++
                updateProgress(plugins.count)
                dispatch_group_leave(group)
            }
            
            func onFailed(request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) {
                println("request = \(request)")
                println("response = \(response)")
                println("responseData = \(responseData)")
                println("error = \(error?.description)")
                
                updateProgress(plugins.count)
                dispatch_group_leave(group)
            }
            
            // start writing
            RLMRealm.defaultRealm().beginWriteTransaction()
            Plugin.deleteAll()
            
            for plugin in plugins {
                dispatch_group_enter(group)
                self.requestRepoDetail(plugin, onSucceed: onSucceedRequestingRepoDetail, onFailed: onFailed)
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue(), {
                // Yay!!! All done!!!
                SVProgressHUD.dismiss()
                self.isLoading = false
                
                // commit
                RLMRealm.defaultRealm().commitWriteTransaction()
                
                println("successCount = \(successCount)")
                
                onComplete(nil)
            })
            
        }
        
        func onFailed(request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) {
            println("request = \(request)")
            println("response = \(response)")
            println("responseData = \(responseData)")
            println("error = \(error?.description)")
            
            isLoading = false
            SVProgressHUD.dismiss()
            onComplete(error)
        }
        
        requestPlugins(onSucceedRequestingPlugins, onFailed: onFailed)
    }
    
    func updateProgress(pluginsCount:Int) {
        loadCompleteCount++
        SVProgressHUD.showProgress(Float(loadCompleteCount) / Float(pluginsCount) , status: "Loading data", maskType: SVProgressHUDMaskType.Black)
    }
    
    
}
