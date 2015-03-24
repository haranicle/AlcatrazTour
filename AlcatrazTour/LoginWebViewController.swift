//
//  LoginWebViewController.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import OAuthSwift

class LoginWebViewController: OAuthWebViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var url:NSURL?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func setUrl(url: NSURL) {
        self.url = url
    }
    
    override func viewDidLoad() {
        if let aUrl = url {
            webView.loadRequest(NSURLRequest(URL: aUrl))
        }
        
    }
}
