//
//  SettingsTableViewController.swift
//  AlcatrazTour
//
//  Created by haranicle on 2015/06/27.
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import JDStatusBarNotification

class SettingsTableViewController: UITableViewController {

    weak var githubClient:GithubClient? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onDonePushed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0: // Github
            switch indexPath.row {
            case 0:
                signOut()
            default:
                fatalError("I don't have such a cell!")
            }
        case 1: // About
            switch indexPath.row {
            case 0:
                showSourceCodeOfThisApp()
            case 1:
                starThisAppOnGithub()
            default:
                fatalError("I don't have such a cell!")
            }
        default:
            fatalError("I don't have such a section!")
        }
       
    }
    
    func signOut() {
        if githubClient!.isSignedIn() {
            githubClient!.signOut()
            JDStatusBarNotification.showWithStatus("Signed out.", dismissAfter: 3, styleName: JDStatusBarStyleSuccess)
        } else {
            JDStatusBarNotification.showWithStatus("Already signed out.", dismissAfter: 3, styleName: JDStatusBarStyleError)
        }
    }
    
    func showSourceCodeOfThisApp() {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/haranicle/AlcatrazTour")!)
    }
    
    func starThisAppOnGithub() {
        func onSucceed(responseData:AnyObject) {
            NSLog("responseData = \(responseData)")
        }
        
        func onFailed(request:NSURLRequest, response:NSHTTPURLResponse?, responseData:AnyObject?, error:NSError?) {
            println("request = \(request)")
            println("response = \(response)")
            println("responseData = \(responseData)")
            println("error = \(error?.description)")
        }
        
        githubClient!.starRepository(true ,owner:"haranicle", repositoryName: "sandbox", onSucceed: onSucceed, onFailed: onFailed);
    }
    
    

}
