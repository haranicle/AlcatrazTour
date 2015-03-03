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
        
        let attributes = [NSFontAttributeName:UIFont(name: "FontAwesome", size: 12)!]
        segmentedControl.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        
        for i in 0 ..< segments.count {
            let mode = segments[i]
            segmentedControl.setTitle("\(mode.toIcon()) \(mode.toString())", forSegmentAtIndex: i)
        }
        
        if !githubClient.isLoggedIn() {
            githubClient.requestOAuth({}, onFailed: {error in })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        githubClient.reloadAllPlugins({self.tableView.reloadData()})
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
        cell.titleLabel.text = "\(indexPath.row + 1). \(plugin.name)"
        cell.noteLabel.text = plugin.note
        cell.avaterImageView.sd_setImageWithURL(NSURL(string: plugin.avaterUrl))
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy"
                
        cell.statusLabel.text = "\(Modes.Popularity.toIcon()) \(plugin.scoreAsString()) \(Modes.Stars.toIcon()) \(plugin.starGazersCount) \(Modes.Update.toIcon()) \(formatter.stringFromDate(plugin.updatedAt)) \(Modes.New.toIcon()) \(formatter.stringFromDate(plugin.createdAt))"
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selectedPlugin = currentResult()[UInt(indexPath.row)] as Plugin
        
        var webViewController = M2DWebViewController(URL: NSURL(string: selectedPlugin.url), type: M2DWebViewType.AutoSelect)
        navigationController?.pushViewController(webViewController, animated: true)
    }

}