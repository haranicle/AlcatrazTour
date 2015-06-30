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
    let githubStarApiUrl = "https://api.github.com/user/starred/"
    let appScheme = "alcatraztour:"
    
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
        
        let oAuthTokenKey = githubOauthTokenKey
        oauthswift.authorize_url_handler = LoginWebViewController()
        oauthswift.authorizeWithCallbackURL( NSURL(string: "\(appScheme)//oauth-callback/github")!, scope: "user,repo,public_repo", state: "GITHUB", success: {
            credential, response, parameters in
            
            NSUserDefaults.standardUserDefaults().setObject(credential.oauth_token, forKey:oAuthTokenKey)
            onSucceed()
            
            }, failure: {(error:NSError!) -> Void in
                println(error.localizedDescription)
        })
        
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
        weak var weakSelf = self
        
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
                plugin?.setDetails(pluginDetail)
                if let p = plugin {
                    p.save()
                }
                successCount++
                weakSelf!.updateProgress(weakSelf, pluginsCount: plugins.count)
                dispatch_group_leave(group)
            }
            
            func onFailed(request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) {
                weakSelf!.updateProgress(weakSelf, pluginsCount: plugins.count)
                dispatch_group_leave(group)
            }
            
            // start writing
            RLMRealm.defaultRealm().beginWriteTransaction()
            Plugin.deleteAll()
            
            for plugin in plugins {
                dispatch_group_enter(group)
                weakSelf!.requestRepoDetail(plugin, onSucceed: onSucceedRequestingRepoDetail, onFailed: onFailed)
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue(), {
                // Yay!!! All done!!!
                SVProgressHUD.dismiss()
                weakSelf!.isLoading = false
                
                // commit
                RLMRealm.defaultRealm().commitWriteTransaction()
                
                println("successCount = \(successCount)")
                println("plugins.count = \(plugins.count)")
                
                onComplete(nil)
            })
            
        }
        
        func onFailed(request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) {
            println("request = \(request)")
            println("response = \(response)")
            println("responseData = \(responseData)")
            println("error = \(error?.description)")
            
            weakSelf!.isLoading = false
            SVProgressHUD.dismiss()
            onComplete(error)
        }
        
        requestPlugins(onSucceedRequestingPlugins, onFailed: onFailed)
    }
    
    func updateProgress(weakSelf:GithubClient?, pluginsCount:Int) {
        weakSelf!.loadCompleteCount++
        SVProgressHUD.showProgress(Float(weakSelf!.loadCompleteCount) / Float(pluginsCount) , status: "Loading data", maskType: SVProgressHUDMaskType.Black)
    }
    
    // MARK: Staring
    
    func checkIfStarredRepository(owner:String, repositoryName:String, onSucceed:(AnyObject) -> Void, onFailed:(NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        let apiUrl = githubStarApiUrl + owner + "/" + repositoryName
        
        let token = NSUserDefaults.standardUserDefaults().stringForKey(githubOauthTokenKey)
        if(token == nil) {
            println("TOKEN NOT SAVED!")
            return
        }
        
        Alamofire
            .request(Method.GET, apiUrl, parameters: ["access_token": token!])
            .validate(statusCode: 200..<400)
            .responseString {request, response, responseData, error in
                if let aError = error {
                    onFailed(request, response, responseData, aError)
                    return
                }
                
                if let aResponseData: AnyObject = responseData {
                    onSucceed(aResponseData)
                } else {
                    onFailed(request, response, responseData, nil)
                }
                
        }
    }
    
    func starRepository(isStarring:Bool, owner:String, repositoryName:String, onSucceed:(AnyObject) -> Void, onFailed:(NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        
        let apiUrl = githubStarApiUrl + owner + "/" + repositoryName
        let method = isStarring ? Method.PUT : Method.DELETE
        
        let token = NSUserDefaults.standardUserDefaults().stringForKey(githubOauthTokenKey)
        if(token == nil) {
            println("TOKEN NOT SAVED!")
            return
        }
        
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "Content-Length" : "0",
            "token" : "\(token!)"
        ]
        
        Alamofire
            .request(method, apiUrl, parameters: ["access_token": token!])
            .validate(statusCode: 200..<400)
            .responseString {request, response, responseData, error in
                if let aError = error {
                    onFailed(request, response, responseData, aError)
                    return
                }
                
                if let aResponseData: AnyObject = responseData {
                    onSucceed(aResponseData)
                } else {
                    onFailed(request, response, responseData, nil)
                }
 
        }
    }
    
}
