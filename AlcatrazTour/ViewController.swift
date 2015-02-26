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

        // client.requestPlugins(onSucceed, onFailed: onFailed)
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onOAuth(sender: AnyObject) {
        githubClient.requestOAuth({println("succeed")}, onFailed: {error in println("failed")})
    }
    
    @IBAction func onLoad(sender: AnyObject) {
        githubClient.reloadAllPlugins()
    }

}

