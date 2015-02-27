//
//  PluginDetailViewController.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit

class PluginDetailViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var url:String = ""
    
    override func viewDidLoad() {
        webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
    }
}
