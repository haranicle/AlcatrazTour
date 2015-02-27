//
//  ViewController.swift
//  AlcatrazTour
//
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import Realm

enum Modes:Int {
    case Stars = 0
    case Update = 1
    case New = 2
    case Popularity = 3
}

class ViewController: UIViewController {
    
    var githubClient = GithubClient()
    var currentMode = Modes.Stars

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !githubClient.isLoggedIn() {
            githubClient.requestOAuth({}, onFailed: {error in })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Realm
    
    var starsResults = Plugin.allObjects().sortedResultsUsingProperty("starGazersCount", ascending: false)
    var updateResults = Plugin.allObjects().sortedResultsUsingProperty("updatedAt", ascending: false)
    var newResults = Plugin.allObjects().sortedResultsUsingProperty("createdAt", ascending: false)
    
    func currentResult()->RLMResults {
        switch currentMode {
        case Modes.Stars: return starsResults
        case Modes.Update: return updateResults
        case Modes.New: return newResults
        default: return starsResults
        }
    }
    
    // MARK: - UI Parts
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Action
    
    @IBAction func onSegmentChanged(sender: UISegmentedControl) {
        currentMode = Modes(rawValue: sender.selectedSegmentIndex)!
        tableView.reloadData()
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
    }
    
    @IBAction func onRefreshPushed(sender: AnyObject) {
        githubClient.reloadAllPlugins({self.tableView.reloadData()})
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Int(currentResult().count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let plugin = currentResult()[UInt(indexPath.row)] as Plugin
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as PluginTableViewCell
        cell.plugin = plugin
        cell.titleLabel.text = plugin.name
        cell.noteLabel.text = plugin.note
        cell.avaterImageView.sd_setImageWithURL(NSURL(string: plugin.avaterUrl))
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        
        cell.statusLabel.text = "⭐️\(plugin.starGazersCount) 🔄\(formatter.stringFromDate(plugin.updatedAt)) 👺\(formatter.stringFromDate(plugin.createdAt))"
        
        return cell
    }

}