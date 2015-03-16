//
//  PluginDetailWebViewController.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import M2DWebViewController

class PluginDetailWebViewController: M2DWebViewController {
    
    var plugin = Plugin()
    
    init(plugin:Plugin) {
        super.init(URL: NSURL(string: plugin.url)!, type: M2DWebViewType.AutoSelect)
        self.plugin = plugin
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
