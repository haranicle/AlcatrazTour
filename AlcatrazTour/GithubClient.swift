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
import JDStatusBarNotification

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

    func oAuthToken() -> String? {
        let token = NSUserDefaults.standardUserDefaults().stringForKey(githubOauthTokenKey)
        if token == nil {
            JDStatusBarNotification.showWithStatus("Not signed in.", dismissAfter: 3, styleName: JDStatusBarStyleError)
        }
        return token
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
    
    func requestRepoDetail(token:String, plugin:Plugin, onSucceed:(Plugin?, NSDictionary) -> Void, onFailed:(NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        
        Alamofire
            .request(Method.GET, createRepoDetailUrl(plugin.url), parameters: ["access_token": token])
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
        
        let onSucceedRequestingPlugins = {[weak self] (plugins:[Plugin]) -> Void in
            
            println("PLUGIN LIST LOAD COMPLETE!!")
            
            SVProgressHUD.dismiss()
            SVProgressHUD.showProgress(0, status: "Loading data", maskType: SVProgressHUDMaskType.Black)
            
            // Dispatch Group
            let group = dispatch_group_create()
            var successCount = 0
            
            // loading plugin details
            let onSucceedRequestingRepoDetail = {[weak self] (plugin:Plugin?, pluginDetail:NSDictionary) -> Void in
                plugin?.setDetails(pluginDetail)
                if let p = plugin {
                    p.save()
                }
                successCount++
                self?.updateProgress(plugins.count)
                dispatch_group_leave(group)
            }
            
            let onFailed = {[weak self] (request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) -> Void in
                self?.updateProgress(plugins.count)
                dispatch_group_leave(group)
            }
            
            // start writing
            RLMRealm.defaultRealm().beginWriteTransaction()
            Plugin.deleteAll()
            
            let token = self?.oAuthToken()
            if token == nil {
                return
            }
            
            for plugin in plugins {
                dispatch_group_enter(group)
                self?.requestRepoDetail(token!, plugin: plugin, onSucceed: onSucceedRequestingRepoDetail, onFailed: onFailed)
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue(), {
                // Yay!!! All done!!!
                SVProgressHUD.dismiss()
                self?.isLoading = false
                
                // commit
                RLMRealm.defaultRealm().commitWriteTransaction()
                
                println("successCount = \(successCount)")
                println("plugins.count = \(plugins.count)")
                
                onComplete(nil)
            })
            
        }
        
        let onFailed = {[weak self] (request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) -> Void in
            println("request = \(request)")
            println("response = \(response)")
            println("responseData = \(responseData)")
            println("error = \(error?.description)")
            
            self?.isLoading = false
            SVProgressHUD.dismiss()
            onComplete(error)
        }
        
        requestPlugins(onSucceedRequestingPlugins, onFailed: onFailed)
    }
    
    func updateProgress(pluginsCount:Int) {
        self.loadCompleteCount++
        SVProgressHUD.showProgress(Float(self.loadCompleteCount) / Float(pluginsCount) , status: "Loading data", maskType: SVProgressHUDMaskType.Black)
    }
    
    // MARK: - Staring
    
    func checkIfStarredRepository(token:String, owner:String, repositoryName:String, onSucceed:(Bool) -> Void, onFailed:(NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) -> Request  {
        let apiUrl = githubStarApiUrl + owner + "/" + repositoryName

        return Alamofire
            .request(Method.GET, apiUrl, parameters: ["access_token": token])
            .validate(statusCode: 204...404)
            .responseString {request, response, responseData, error in
                if let aError = error {
                    onFailed(request, response, responseData, aError)
                    return
                }
                
                if(response?.statusCode==204){
                    onSucceed(true)
                    return
                }
                if(response?.statusCode==404){
                    onSucceed(false)
                    return
                }
                onFailed(request, response, responseData, nil)
        }
    }
    
    func starRepository(token:String, isStarring:Bool, owner:String, repositoryName:String, onSucceed:() -> Void, onFailed:(NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        
        let apiUrl = githubStarApiUrl + owner + "/" + repositoryName
        let method = isStarring ? Method.PUT : Method.DELETE
        
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "Content-Length" : "0",
            "Authorization" : "token \(token)"
        ]
        
        Alamofire
            .request(method, apiUrl, parameters: nil)
            .validate(statusCode: 200..<400)
            .responseString {request, response, responseData, error in
                if let aError = error {
                    onFailed(request, response, responseData, aError)
                    return
                }
                
                onSucceed()
        }
    }
    
    func checkAndStarRepository(token:String, isStarring:Bool, owner:String, repositoryName:String, onSucceed:() -> Void, onFailed:(NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void){
        
        checkIfStarredRepository(token, owner: owner, repositoryName: repositoryName, onSucceed: { (isStarred) -> Void in
            if isStarring && isStarred {
                JDStatusBarNotification.showWithStatus("Already starred.", dismissAfter: 3, styleName: JDStatusBarStyleWarning)
                return
            } else if !isStarring && !isStarred {
                JDStatusBarNotification.showWithStatus("Already unstarred.", dismissAfter: 3, styleName: JDStatusBarStyleWarning)
                return;
            }
            self.starRepository(token, isStarring: isStarring, owner: owner, repositoryName: repositoryName, onSucceed: { (responseObject) -> Void in
                let action = isStarring ? "starred" : "unstarred"
                JDStatusBarNotification.showWithStatus("Your \(action) \(repositoryName).", dismissAfter: 3, styleName: JDStatusBarStyleSuccess)
                onSucceed()
                }, onFailed: onFailed)
            
            
        }, onFailed: onFailed)
    }
    
}
