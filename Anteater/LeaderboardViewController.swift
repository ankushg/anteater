//
//  LeaderboardViewController.swift
//  Anteater
//
//  Created by Ankush Gupta on 3/1/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

import Foundation

@objc class LeaderboardViewController : UITableViewController {
    var leaderboardData: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doRefresh()
    }
    
    func doRefresh() {
        AnteaterREST.getLeaderboard({ (d: [NSObject : AnyObject]!) in
            if let data = d["users"] as? [AnyObject]{
                self.leaderboardData = data
                self.tableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardData.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return tableView.dequeueReusableCellWithIdentifier("HeaderCell", forIndexPath: indexPath)
        } else {
            if let c : LeaderboardCell = tableView.dequeueReusableCellWithIdentifier("EntryCell", forIndexPath: indexPath) as? LeaderboardCell {
                if let d = leaderboardData[indexPath.row-1] as? [NSString : AnyObject] {
                    c.pointsField.text = d["points"]?.description
                    if (d["device_id"] as? String == UIDevice.currentDevice().identifierForVendor?.UUIDString) {
                        c.nameField.text = "YOU"
                        c.nameField.font = UIFont.boldSystemFontOfSize(c.nameField.font.pointSize)
                    } else {
                        c.nameField.text = d["user_id"] as? String
                        c.nameField.font = UIFont.systemFontOfSize(c.nameField.font.pointSize)
                    }
                    c.rankField.text = "\(CLong(indexPath.row))."
                }
                
                return c
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 30
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            
        }
    }
}