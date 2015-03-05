//
//  ViewController.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import Realm
import M2DWebViewController

enum Modes:Int {
    case Popularity = 0
    case Stars = 1
    case Update = 2
    case New = 3
    
    func toIcon() -> String {
        switch self {
            case Modes.Popularity: return "\u{f004}"
            case Modes.Stars: return "\u{f005}"
            case Modes.Update: return "\u{f021}"
            case Modes.New: return "\u{f135}"
            default: return ""
        }
    }
    
    func toString() -> String {
        switch self {
        case Modes.Popularity: return "Popularity"
        case Modes.Stars: return "Stars"
        case Modes.Update: return "Update"
        case Modes.New: return "New"
        default: return ""
        }
    }
}

class ViewController: UIViewController {
    
    var githubClient = GithubClient()
    var currentMode = Modes.Popularity
    let segments = [Modes.Popularity, Modes.Stars, Modes.Update, Modes.New]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // notification center 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onApplicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        let attributes = [NSFontAttributeName:UIFont(name: "FontAwesome", size: 10)!]
        segmentedControl.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        
        for i in 0 ..< segments.count {
            let mode = segments[i]
            segmentedControl.setTitle("\(mode.toIcon()) \(mode.toString())", forSegmentAtIndex: i)
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController!.toolbarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onApplicationDidBecomeActive(notification:NSNotification) {
        if !githubClient.isSignedIn() {
            showSignInAlert()
        }
    }
    
    // MARK: - Realm
    
    var popularityResults = Plugin.allObjects().sortedResultsUsingProperty("score", ascending: false)
    var starsResults = Plugin.allObjects().sortedResultsUsingProperty("starGazersCount", ascending: false)
    var updateResults = Plugin.allObjects().sortedResultsUsingProperty("updatedAt", ascending: false)
    var newResults = Plugin.allObjects().sortedResultsUsingProperty("createdAt", ascending: false)
    
    func currentResult()->RLMResults {
        switch currentMode {
        case Modes.Popularity: return popularityResults
        case Modes.Stars: return starsResults
        case Modes.Update: return updateResults
        case Modes.New: return newResults
        }
    }
    
    // MARK: - UI Parts
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Action
    
    @IBAction func onSegmentChanged(sender: UISegmentedControl) {
        currentMode = Modes(rawValue: sender.selectedSegmentIndex)!
        tableView.reloadData()
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
    }
    
    @IBAction func onRefreshPushed(sender: AnyObject) {
        if !tableView.decelerating {
            self.reloadAllPlugins()
        }
        
    }
    
    // MARK: - Table View Data Source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Int(currentResult().count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let plugin = currentResult()[UInt(indexPath.row)] as Plugin
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as PluginTableViewCell
        cell.rankingLabel.text = "\(indexPath.row + 1)"
        cell.titleLabel.text = plugin.name
        cell.noteLabel.text = plugin.note
        cell.avaterImageView.sd_setImageWithURL(NSURL(string: plugin.avaterUrl))
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy"
                
        cell.statusLabel.text = "\(Modes.Popularity.toIcon()) \(plugin.scoreAsString()) \(Modes.Stars.toIcon()) \(plugin.starGazersCount) \(Modes.Update.toIcon()) \(formatter.stringFromDate(plugin.updatedAt)) \(Modes.New.toIcon()) \(formatter.stringFromDate(plugin.createdAt))"
        
        return cell
    }
    
    // MARK: - Sign in
    
    var signInAlert:UIAlertController?
    
    func showSignInAlert() {
        signInAlert =  UIAlertController(title: "Sign in", message: "Please, sign in to github with Safari.", preferredStyle: UIAlertControllerStyle.Alert)
        signInAlert!.addAction(UIAlertAction(title: "Open Safari", style: UIAlertActionStyle.Default, handler: { action in
            self.signIn()
        }))
        presentViewController(signInAlert!, animated: true, completion: nil)
    }
    
    func signIn() {
        githubClient.requestOAuth({
            if let alert = self.signInAlert {
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            self.reloadAllPlugins()
            }, onFailed: { error in
                // login failed. quit app.
                var errorAlert = UIAlertController(title: "Error", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Quit app", style: UIAlertActionStyle.Default, handler:{action in exit(0)} ))
                self.presentViewController(errorAlert, animated: true, completion: nil)
        })
    }
    
    // MARK: - Reload data
    
    func reloadAllPlugins() {
        self.githubClient.reloadAllPlugins({(error:NSError?) in
            if let err = error {
                self.showErrorAlert(err)
            }
            self.tableView.reloadData()
        })
    }

    // MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selectedPlugin = currentResult()[UInt(indexPath.row)] as Plugin
        
        var webViewController = M2DWebViewController(URL: NSURL(string: selectedPlugin.url), type: M2DWebViewType.AutoSelect)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    // MARK: - Error
    
    func showErrorAlert(error:NSError) {
        var alert = UIAlertController(title: "Error", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}