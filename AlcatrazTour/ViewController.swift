//
//  ViewController.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var githubClient = GithubClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !githubClient.isLoggedIn() {
            githubClient.requestOAuth({}, onFailed: {error in })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onOAuth(sender: AnyObject) {
        githubClient.requestOAuth({println("succeed")}, onFailed: {error in println("failed")})
    }
    
    @IBAction func onLoad(sender: AnyObject) {
        githubClient.reloadAllPlugins()
    }

}

