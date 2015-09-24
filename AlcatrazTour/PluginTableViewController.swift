//
//  PluginListMainViewController
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import RealmSwift

let PluginCellReuseIdentifier = "Cell"

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
    
    func propertyName() -> String {
        switch self {
        case Modes.Popularity: return "score"
        case Modes.Stars: return "starGazersCount"
        case Modes.Update: return "updatedAt"
        case Modes.New: return "createdAt"
        default: return ""
        }
    }
}

class PluginTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var githubClient = GithubClient()
    var currentMode = Modes.Popularity
    let segments = [Modes.Popularity, Modes.Stars, Modes.Update, Modes.New]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCellNib(self.tableView)
        
        // settings button
        let settingsAttributes = [NSFontAttributeName:UIFont(name: "FontAwesome", size: 24)!]
        settingsButton.setTitleTextAttributes(settingsAttributes, forState: UIControlState.Normal)
        settingsButton.title = "\u{f013}"
        
        // notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onApplicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        // segmented control
        let attributes = [NSFontAttributeName:UIFont(name: "FontAwesome", size: 10)!]
        segmentedControl.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        
        // search controller
        configureSearchController()
        
        // hide search bar
        if githubClient.isSignedIn() {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }
        
        for i in 0 ..< segments.count {
            let mode = segments[i]
            segmentedControl.setTitle("\(mode.toIcon()) \(mode.toString())", forSegmentAtIndex: i)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.toolbarHidden = true
    }
    
    func onApplicationDidBecomeActive(notification:NSNotification) {
        if githubClient.isSignedIn() {
            reloadAllPlugins()
        } else {
            showSignInAlert()
        }
    }
    
    // MARK: - Search Controller
    let searchResultTableViewController = UITableViewController()
    var searchController:UISearchController?
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: searchResultTableViewController)
        searchController!.searchResultsUpdater = self
        searchController!.delegate = self
        searchController!.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController!.searchBar
        searchResultTableViewController.tableView.delegate = self
        searchResultTableViewController.tableView.dataSource = self
        registerTableViewCellNib(searchResultTableViewController.tableView)
        searchResultTableViewController.tableView.tableHeaderView = nil
        
        // https://developer.apple.com/library/ios/samplecode/TableSearch_UISearchController/Introduction/Intro.html
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = true // know where you want UISearchController to be displayed
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        // TODO: Must be tested here!!
        searchResults = Realm().objects(Plugin).filter("name contains[c] '\(searchText)' OR note contains[c] '\(searchText)'").sorted(currentMode.propertyName(), ascending: false)
        searchResultTableViewController.tableView.reloadData()
    }
    
    // MARK: - Realm
    var searchResults:Results<Plugin>?
    var popularityResults:Results<Plugin> = Realm ().objects(Plugin).sorted(Modes.Popularity.propertyName(), ascending: false)
    var starsResults:Results<Plugin> = Realm ().objects(Plugin).sorted(Modes.Stars.propertyName(), ascending: false)
    var updateResults:Results<Plugin> = Realm ().objects(Plugin).sorted(Modes.Update.propertyName(), ascending: false)
    var newResults:Results<Plugin> = Realm ().objects(Plugin).sorted(Modes.New.propertyName(), ascending: false)
    
    func currentResult()->Results<Plugin> {
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
        if !githubClient.isSignedIn() {
            showSignInAlert()
            return
        }
        
        if !tableView.decelerating {
            self.reloadAllPlugins()
        }
    }
    
    // MARK: - Sign in
    
    var signInAlert:UIAlertController?
    
    func showSignInAlert() {
        signInAlert =  UIAlertController(title: "Sign in", message: "Please, sign in github to get repository data.", preferredStyle: UIAlertControllerStyle.Alert)
        signInAlert!.addAction(UIAlertAction(title: "Sign in", style: UIAlertActionStyle.Default,
            handler: {[weak self] action in
            self?.signIn()
            self?.signInAlert?.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(signInAlert!, animated: true, completion: nil)
    }
    
    func signIn() {
        githubClient.requestOAuth({[weak self] in
            self?.signInAlert?.dismissViewControllerAnimated(true, completion: nil)
            self?.reloadAllPlugins()
            }, onFailed: {[weak self] error in
                // login failed. quit app.
                let errorAlert = UIAlertController(title: "Error", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Quit app", style: UIAlertActionStyle.Default, handler:{action in exit(0)} ))
                self?.presentViewController(errorAlert, animated: true, completion: nil)
        })
    }
    
    // MARK: - Reload data
    
    func reloadAllPlugins() {
        autoreleasepool{
            self.githubClient.reloadAllPlugins({[weak self] (error:NSError?) in
                if let err = error {
                    self?.showErrorAlert(err)
                }
                self?.tableView.reloadData()
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
        let plugin = currentResult()[Int(indexPath.row)] as Plugin
        
        var cell = tableView.dequeueReusableCellWithIdentifier(PluginCellReuseIdentifier) as! PluginTableViewCell
        configureCell(cell, plugin: plugin, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selectedPlugin = currentResult()[Int(indexPath.row)] as Plugin
        var webViewController = PluginDetailWebViewController(plugin: selectedPlugin)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - UISearchControllerDelegate
    

    func didDismissSearchController(searchController: UISearchController) {
        tableView.reloadData()
    }
    
    // MARK: - Cell
    
    func configureCell(cell:PluginTableViewCell, plugin:Plugin, indexPath:NSIndexPath) {
        cell.rankingLabel.text = "\(indexPath.row + 1)"
        cell.titleLabel.text = plugin.name
        cell.noteLabel.text = plugin.note
        cell.avaterImageView.sd_setImageWithURL(NSURL(string: plugin.avaterUrl))
        
        cell.statusLabel.text = "\(Modes.Popularity.toIcon()) \(plugin.scoreAsString()) \(Modes.Stars.toIcon()) \(plugin.starGazersCount) \(Modes.Update.toIcon()) \(plugin.updatedAtAsString()) \(Modes.New.toIcon()) \(plugin.createdAtAsString())"
    }
    
    func registerTableViewCellNib(tableView:UITableView) {
        let nib = UINib(nibName: "PluginTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: PluginCellReuseIdentifier)
    }
    
    // MARK: - Error
    
    func showErrorAlert(error:NSError) {
        let alert = UIAlertController(title: "Error", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settings" {
            let settingsNavigationController = segue.destinationViewController as! UINavigationController
            let settingTableViewController = settingsNavigationController.childViewControllers[0] as! SettingsTableViewController
            settingTableViewController.githubClient = githubClient
        }
    }
    
}