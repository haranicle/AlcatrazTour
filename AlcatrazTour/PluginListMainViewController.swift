//
//  PluginListMainViewController
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import Realm

class PluginListMainViewController: PluginListBaseViewController, UISearchResultsUpdating {
    
    var githubClient = GithubClient()
    var currentMode = Modes.Popularity
    let segments = [Modes.Popularity, Modes.Stars, Modes.Update, Modes.New]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onApplicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        // segmented control
        let attributes = [NSFontAttributeName:UIFont(name: "FontAwesome", size: 10)!]
        segmentedControl.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        
        // search controller
        searchController = UISearchController(searchResultsController: pluginListSearchResultController)
        configureSearchController()
        
        for i in 0 ..< segments.count {
            let mode = segments[i]
            segmentedControl.setTitle("\(mode.toIcon()) \(mode.toString())", forSegmentAtIndex: i)
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onApplicationDidBecomeActive(notification:NSNotification) {
        if !githubClient.isSignedIn() {
            showSignInAlert()
        }
    }
    
    // MARK: - Search Controller
    var searchResults:RLMResults?
    let pluginListSearchResultController = PluginListSearchResultViewController()
    var searchController:UISearchController?
    
    func configureSearchController() {
        searchController!.searchResultsUpdater = self
        searchController!.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController!.searchBar
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        searchResults = Plugin.objectsWhere("name contains[c] '\(searchText)' OR note contains[c] '\(searchText)'")
        
    }
    
    // MARK: - Realm
    
    var popularityResults = Plugin.allObjects().sortedResultsUsingProperty("score", ascending: false)
    var starsResults = Plugin.allObjects().sortedResultsUsingProperty("starGazersCount", ascending: false)
    var updateResults = Plugin.allObjects().sortedResultsUsingProperty("updatedAt", ascending: false)
    var newResults = Plugin.allObjects().sortedResultsUsingProperty("createdAt", ascending: false)
    
    func currentResult()->RLMResults {
        if searchController!.active {
            return searchResults!
        }
        
        switch currentMode {
        case Modes.Popularity: return popularityResults
        case Modes.Stars: return starsResults
        case Modes.Update: return updateResults
        case Modes.New: return newResults
        }
    }
    
    // MARK: - UI Parts
    
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
    
    // MARK: - Sign in
    
    var signInAlert:UIAlertController?
    
    func showSignInAlert() {
        signInAlert =  UIAlertController(title: "Sign in", message: "Please, sign in to github with Safari.", preferredStyle: UIAlertControllerStyle.Alert)
        weak var weakSelf = self
        signInAlert!.addAction(UIAlertAction(title: "Open Safari", style: UIAlertActionStyle.Default, handler: { action in
            weakSelf!.signIn()
        }))
        presentViewController(signInAlert!, animated: true, completion: nil)
    }
    
    func signIn() {
        weak var weakSelf = self
        githubClient.requestOAuth({
            if let alert = weakSelf!.signInAlert {
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            weakSelf!.reloadAllPlugins()
            }, onFailed: { error in
                // login failed. quit app.
                var errorAlert = UIAlertController(title: "Error", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Quit app", style: UIAlertActionStyle.Default, handler:{action in exit(0)} ))
                weakSelf!.presentViewController(errorAlert, animated: true, completion: nil)
        })
    }
    
    // MARK: - Reload data
    
    func reloadAllPlugins() {
        autoreleasepool{
            weak var weakSelf = self
            self.githubClient.reloadAllPlugins({(error:NSError?) in
                if let err = error {
                    weakSelf!.showErrorAlert(err)
                }
                weakSelf!.tableView.reloadData()
            })
        }
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Int(currentResult().count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let plugin = currentResult()[UInt(indexPath.row)] as Plugin
        
        var cell = tableView.dequeueReusableCellWithIdentifier(PluginCellReuseIdentifier) as PluginTableViewCell
        configureCell(cell, plugin: plugin, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selectedPlugin = currentResult()[UInt(indexPath.row)] as Plugin
        pushWebViewController(selectedPlugin.url)
    }
    
    // MARK: - Error
    
    func showErrorAlert(error:NSError) {
        var alert = UIAlertController(title: "Error", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}