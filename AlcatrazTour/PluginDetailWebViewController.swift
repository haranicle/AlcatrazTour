//
//  PluginDetailWebViewController.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import M2DWebViewController
import JDStatusBarNotification
import Alamofire

class PluginDetailWebViewController: M2DWebViewController {
    
    var plugin = Plugin()
    let githubClient = GithubClient()
    var isStarred = false
    var starButton = UIBarButtonItem()
    var isStarButtonAdded = false
    var requestOfCheckIfStarredRepository:Request?
    let starringButtonTitle = "Star this repo"
    let unstarringButtonTitle = "Unstar this repo"
    
    init(plugin:Plugin) {
        super.init(URL: NSURL(string: plugin.url)!, type: M2DWebViewType.AutoSelect)
        self.plugin = plugin
        setupStarButton()
        refreshStarButton()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "onShareButtonPushed:")
        navigationItem.rightBarButtonItem = button
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addStarButton()
    }
    
    override func viewDidDisappear(animated: Bool) {
        requestOfCheckIfStarredRepository?.cancel()
    }
    
    // MARK: - button
    
    func onShareButtonPushed(sender:AnyObject) {
        let items = ["I love this Xcode plugin!\n[\(plugin.name)] ❤️:\(plugin.score) ⭐️:\(plugin.starGazersCount) 🔄:\(plugin.updatedAtAsString()) 🚀:\(plugin.createdAtAsString()) ", plugin.url, " #AlcatrazTour"]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func setupStarButton() {
        starButton.title = starringButtonTitle
        starButton.style = UIBarButtonItemStyle.Plain
        starButton.target = self
        starButton.action = "onStarButtonPushed:"
        starButton.enabled = false
    }
    
    func refreshStarButton() {
        starButton.enabled = false
        
        let onFailed = {(request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) -> Void in
            println("request = \(request)")
            println("response = \(response)")
            println("responseData = \(responseData)")
            println("error = \(error?.description)")
            JDStatusBarNotification.showWithStatus("Cannot connect to GitHub.", dismissAfter: 3, styleName: JDStatusBarStyleError)
        }
        
        let token = githubClient.oAuthToken()
        if token == nil {
            return
        }
        
        requestOfCheckIfStarredRepository = githubClient.checkIfStarredRepository(token! ,owner: plugin.owner, repositoryName: plugin.repositoryName, onSucceed: {[weak self] (isStarred) -> Void in
            self?.isStarred = isStarred
            self?.toggleStarButton()
            self?.starButton.enabled = true
            }, onFailed: onFailed)
    }
    
    func toggleStarButton() {
        starButton.title = isStarred ? unstarringButtonTitle : starringButtonTitle
    }

    func addStarButton() {
        if isStarButtonAdded {
            return
        }
        
        for view in self.parentViewController!.view.subviews {
            if view.isKindOfClass(UIToolbar.self) {
                var items:Array = view.items
                let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
                items.append(spacer)
                items.append(starButton)
                view.setItems(items, animated:false)
                isStarButtonAdded = true;
                return;
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onStarButtonPushed(sender:UIBarButtonItem) {
        starButton.enabled = false
        
        let token = githubClient.oAuthToken()
        if token == nil {
            return
        }
        
        let onFailed = {[weak self] (request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) -> Void in
            println("request = \(request)")
            println("response = \(response)")
            println("responseData = \(responseData)")
            println("error = \(error?.description)")
            JDStatusBarNotification.showWithStatus("Cannot connect to GitHub.", dismissAfter: 3, styleName: JDStatusBarStyleError)
            self?.starButton.enabled = true
        }
        
        githubClient.checkAndStarRepository(token!, isStarring: !isStarred, owner: plugin.owner, repositoryName: plugin.repositoryName, onSucceed: {[weak self]() -> Void in
            if let strongSelf = self {
                self?.isStarred = !strongSelf.isStarred
            }
            self?.toggleStarButton()
            self?.starButton.enabled = true
            }, onFailed: onFailed)
    }
}
