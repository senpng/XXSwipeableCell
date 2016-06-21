//
//  ViewController.swift
//  XXSwipeableCell
//
//  Created by 沈鹏 on 16/6/21.
//  Copyright © 2016年 沈鹏. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leftPercentageLabel: UILabel!
    @IBOutlet weak var leftVisiblePercentageLabel: UILabel!
    @IBOutlet weak var rightPercentageLabel: UILabel!
    @IBOutlet weak var rightVisiblePercentageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "XXSwipeableCell";
        
        self.tableView.tableFooterView = UIView();
        self.tableView.separatorStyle = .None;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.tableView.registerClass(XXSwipeableCell.self, forCellReuseIdentifier: "XXSwipeableCell");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func randomColor() -> UIColor {
        let r = CGFloat(arc4random()%256)/255;
        let g = CGFloat(arc4random()%256)/255;
        let b = CGFloat(arc4random()%256)/255;
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0);
    }

    @IBAction func slidingAction(sender: UISlider) {
        
        let str = NSString(format: "%.1f", Float(sender.value)) as String;
        
        switch sender.tag {
        case 1:
            leftPercentageLabel.text = str;
        case 2:
            leftVisiblePercentageLabel.text = str;
        case 3:
            rightPercentageLabel.text = str;
        case 4:
            rightVisiblePercentageLabel.text = str;
        default:
            break;
        }
        
        view.layoutIfNeeded();
        self.tableView.reloadData();
        
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        let cell = XXSwipeableCell(style: UITableViewCellStyle.Default, reuseIdentifier: "XXSwipeableCell");
        let cell = tableView.dequeueReusableCellWithIdentifier("XXSwipeableCell") as! XXSwipeableCell;
        
        cell.selectionStyle = .None;
        cell.backView.backgroundColor = randomColor();
        
        if cell.frontView.backgroundColor == UIColor.whiteColor() {
            cell.frontView.backgroundColor = randomColor();
        }

        cell.leftPercentage = CGFloat(Float(leftPercentageLabel.text!)!)
        cell.leftVisiblePercentage = CGFloat(Float(leftVisiblePercentageLabel.text!)!)
        cell.rightPercentage = CGFloat(Float(rightPercentageLabel.text!)!)
        cell.rightVisiblePercentage = CGFloat(Float(rightVisiblePercentageLabel.text!)!)
        
        return cell;
        
    }

}

