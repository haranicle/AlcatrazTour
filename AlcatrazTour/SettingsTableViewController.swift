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
        case 0:
            switch indexPath.row {
            case 0:
                signOut()
            default:
                fatalError("I don't have such a cell!")
            }
        case 1:
            switch indexPath.row {
            case 0:
                1+1
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

}
