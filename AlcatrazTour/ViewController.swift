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
    
    // MARK: - UI Parts
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Action
    
    @IBAction func onSegmentChanged(sender: UISegmentedControl) {
    }
    
    @IBAction func onRefreshPushed(sender: AnyObject) {
    }


}

