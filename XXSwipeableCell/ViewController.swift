//
//  ViewController.swift
//  XXSwipeableCell
//
//  Created by 沈鹏 on 16/6/21.
//  Copyright © 2016年 沈鹏. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = XXSwipeableCell(style: UITableViewCellStyle.Default, reuseIdentifier: "XXSwipeableCell");
        cell.selectionStyle = .None;
        
        switch indexPath.row {
        case 0:
            
            cell.backView.backgroundColor = UIColor.blueColor();
            
        case 1:
            
            cell.backView.backgroundColor = UIColor.redColor();
            
            
        case 2:
            
            cell.backView.backgroundColor = UIColor.orangeColor();
            
        default:
            break;
        }

        
        return cell;
        
    }

}

