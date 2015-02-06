//
//  ViewController.swift
//  DeviantArtBrowser
//
//  Created by Joshua Greene on 10/22/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // MARK: Instance Variables
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    let parser = RSSParser()
    let deviantArtBaseUrlString = "http://backend.deviantart.com/rss.xml"
    
    var items:[RSSItem] = []
    
    let basicCellIdentifier = "BasicCell"
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        refreshData()
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        deselectAllRows()
    }
    
    func deselectAllRows() {
        if let selectedRows = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {
            for indexPath in selectedRows {
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        }
    }
    
    // MARK: Refresh Content
    
    func refreshData() {
        searchTextField.resignFirstResponder()
        parseForQuery(searchTextField.text)
    }
    
    func parseForQuery(query: String?) {
        showProgressHUD()
        
        parser.parseRSSFeed(deviantArtBaseUrlString,
            parameters: parametersForQuery(query),
            success: {(let channel: RSSChannel!) -> Void  in
                
                self.convertItemPropertiesToPlainText(channel.items as [RSSItem])
                self.items = (channel.items as [RSSItem])
                
                self.hideProgressHUD()
                self.reloadTableViewContent()
                
            }, failure: {(let error:NSError!) -> Void in
                
                self.hideProgressHUD()
                println("Error: \(error)")
        })
    }
    
    func showProgressHUD() {
        var hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Loading"
    }
    
    func parametersForQuery(query: NSString?) -> [String: String] {
        if query != nil && query!.length > 0 {
            return ["q": "\(query!)"]
            
        } else {
            return ["q": "boost:popular"]
        }
    }
    
    func hideProgressHUD() {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
    }
    
    func convertItemPropertiesToPlainText(rssItems:[RSSItem]) {
        for item in rssItems {
            let charSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            
            if let title = item.title as NSString! {
                item.title = title.stringByConvertingHTMLToPlainText().stringByTrimmingCharactersInSet(charSet)
            }
            
            if let mediaDescription = item.mediaDescription as NSString! {
                item.mediaDescription = mediaDescription.stringByConvertingHTMLToPlainText().stringByTrimmingCharactersInSet(charSet)
            }
            
            if let mediaText = item.mediaText as NSString! {
                item.mediaText = mediaText.stringByConvertingHTMLToPlainText().stringByTrimmingCharactersInSet(charSet)
            }
        }
    }
    
    func reloadTableViewContent() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        })
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return basicCellAtIndexPath(indexPath)
    }
    
    func basicCellAtIndexPath(indexPath:NSIndexPath) -> BasicCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(basicCellIdentifier) as BasicCell
        setTitleForCell(cell, indexPath: indexPath)
        setSubtitleForCell(cell, indexPath: indexPath)
        return cell
    }
    
    func setTitleForCell(cell:BasicCell, indexPath: NSIndexPath) {
        let item = items[indexPath.row] as RSSItem
        cell.titleLabel.text = item.title ?? "[No Title]"
    }
    
    func setSubtitleForCell(cell: BasicCell, indexPath: NSIndexPath) {
        let item = items[indexPath.row] as RSSItem
        var subtitle: NSString! = item.mediaText ?? item.mediaDescription
        
        // Some subtitles are really long, so only display the first 200 characters
        if subtitle != nil {
            cell.subtitleLabel.text = subtitle.length > 200 ? "\(subtitle.substringToIndex(200))..." : subtitle
        } else {
            cell.subtitleLabel.text = ""
        }
    }
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        refreshData()
        return false
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = tableView.indexPathForSelectedRow()
        let item = items[indexPath!.row]
        
        let detailViewController = segue.destinationViewController as DetailViewController
        detailViewController.item = item
    }
}

