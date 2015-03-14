//
//  PluginListBaseViewController.swift
//  AlcatrazTour
//
//  Created by haranicle on 2015/03/14.
//  Copyright (c) 2015年 haranicle. All rights reserved.
//

import UIKit
import M2DWebViewController

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
}

class PluginListBaseViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "PluginTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: PluginCellReuseIdentifier)
    }

    override func viewWillAppear(animated: Bool) {
        navigationController?.toolbarHidden = true
    }
    
    func configureCell(cell:PluginTableViewCell, plugin:Plugin, indexPath:NSIndexPath) {
        cell.rankingLabel.text = "\(indexPath.row + 1)"
        cell.titleLabel.text = plugin.name
        cell.noteLabel.text = plugin.note
        cell.avaterImageView.sd_setImageWithURL(NSURL(string: plugin.avaterUrl))
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        
        cell.statusLabel.text = "\(Modes.Popularity.toIcon()) \(plugin.scoreAsString()) \(Modes.Stars.toIcon()) \(plugin.starGazersCount) \(Modes.Update.toIcon()) \(formatter.stringFromDate(plugin.updatedAt)) \(Modes.New.toIcon()) \(formatter.stringFromDate(plugin.createdAt))"
    }
    
    func pushWebViewController(url:String) {
        var webViewController = M2DWebViewController(URL: NSURL(string: url), type: M2DWebViewType.AutoSelect)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

}
