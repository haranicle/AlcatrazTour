//
//  ViewController.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = GithubClient()
        
        func onSucceed(plugins:[Plugin]) {
            plugins.map{println("\($0.name)")}
        }
        
        func onFailed(error:NSError) {
            println(error.description)
        }

        client.requestPlugins(onSucceed, onFailed: onFailed)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

