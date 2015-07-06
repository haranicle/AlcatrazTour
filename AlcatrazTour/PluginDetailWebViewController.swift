//
//  PluginDetailWebViewController.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import M2DWebViewController
import JDStatusBarNotification

class PluginDetailWebViewController: M2DWebViewController {
    
    var plugin = Plugin()
    let githubClient = GithubClient()
    let starringButtonTitle = "Star this repo."
    let unstarringButtonTitle = "Unstar this repo."
    var isStarred = false
    
    init(plugin:Plugin) {
        super.init(URL: NSURL(string: plugin.url)!, type: M2DWebViewType.AutoSelect)
        self.plugin = plugin
        setupStarButton()
        refreshStarButton()
    }
    
    var starButton = UIBarButtonItem()
    var isStarButtonAdded = false
    
    func setupStarButton() {
        starButton.title = starringButtonTitle
        starButton.style = UIBarButtonItemStyle.Plain
        starButton.target = self
        starButton.action = ""
        starButton.enabled = false
    }
    
    func refreshStarButton() {
        func onFailed(request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) {
            println("request = \(request)")
            println("response = \(response)")
            println("responseData = \(responseData)")
            println("error = \(error?.description)")
            JDStatusBarNotification.showWithStatus("Cannot connect to GitHub.", dismissAfter: 3, styleName: JDStatusBarStyleError)
        }
        
        starButton.enabled = false
        
        weak var weakSelf = self
        githubClient.checkIfStarredRepository(plugin.owner, repositoryName: plugin.name, onSucceed: { (isStarred) -> Void in
            var strongSelf:PluginDetailWebViewController = weakSelf!
            strongSelf.starButton.title = isStarred ? strongSelf.unstarringButtonTitle : strongSelf.starringButtonTitle
            strongSelf.isStarred = isStarred
            strongSelf.starButton.enabled = true
            
            }, onFailed: onFailed)
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
        
        if isStarButtonAdded {
            return
        }
        
        for view in self.parentViewController!.view.subviews {
            if view.isKindOfClass(UIToolbar.self) {
                var items:Array = view.items
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
    
    func onShareButtonPushed(sender:AnyObject) {
        let items = ["I love this Xcode plugin!\n[\(plugin.name)] ❤️:\(plugin.score) ⭐️:\(plugin.starGazersCount) 🔄:\(plugin.updatedAtAsString()) 🚀:\(plugin.createdAtAsString()) ", plugin.url, " #AlcatrazTour"]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }

}
