//
//  LoginWebViewController.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import OAuthSwift

class LoginWebViewController: OAuthWebViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    var aUrl:NSURL?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        if let theUrl = aUrl {
            webView.loadRequest(NSURLRequest(URL: theUrl))
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        indicatorView.stopAnimating()
        indicatorView.hidden = true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        indicatorView.stopAnimating()
        indicatorView.hidden = true
    }
}
