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
    
    var dataArray = Array (count: 10 , repeatedValue: 0 ) ;
    
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
        
        let str = NSString(format: "%.2f", Float(sender.value)) as String;
        
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
    
    // MARK: - button actions
    func buttonAction(sender:UIButton) {
        
        print(sender);
    }

    func deleteButtonAction(sender: UIButton) {// sender.tag = 1001 + indexPath.row
        
        let indexPath = NSIndexPath(forRow: sender.tag - 1001, inSection: 0);
        
        // 
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? XXSwipeableCell {
            cell.overlayView?.removeFromSuperview();
        }
        dataArray.removeAtIndex(indexPath.row);
        
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade);
        
        tableView.reloadData();
       
        print(sender)
    }
    
    func cancleButtonAction(sender:UIButton)  {// sender.tag = 1000 + indexPath.row
        
        let indexPath = NSIndexPath(forRow: sender.tag - 1000, inSection: 0);

        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? XXSwipeableCell {
            cell.close(true);
        }
        print(sender);
    }
    
    func collectionButtonAction(sender:UIButton) {// sender.tag = 999 + indexPath.row
     
        let indexPath = NSIndexPath(forRow: sender.tag - 999, inSection: 0);

        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? XXSwipeableCell {
            cell.close(true);
        }
        print(sender);
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count;
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
        
        
        // Remove the existing buttons before you create them once again.
        for view in cell.backView.subviews {
            view.removeFromSuperview();
        }
        var button = UIButton(type: UIButtonType.System);
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal);
        button.setTitle("collection", forState: UIControlState.Normal);
        button.addTarget(self, action: #selector(ViewController.collectionButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside);
        button.frame = CGRectMake(0, 0, cell.leftVisiblePercentage * CGRectGetWidth(self.view.frame), CGRectGetHeight(cell.frame));
        cell.backView.addSubview(button);
        button.tag = 999 + indexPath.row;
       
        // The width for each button on right visible backView .
        let backViewRightVisibleWidth = cell.rightVisiblePercentage * CGRectGetWidth(self.view.frame);
        
        // For example, we add two items on backView here.
        let btnWidth = backViewRightVisibleWidth / 2;
       
        // The Origin.x of first item on right visible backView.
        let backViewRightOriginX = (CGRectGetWidth(self.view.frame) - backViewRightVisibleWidth);

        // You can put a button with image on backView.
        button = UIButton(type: UIButtonType.System);
        button.setImage(UIImage(named: "cancle"), forState: .Normal);
        button.addTarget(self, action: #selector(ViewController.cancleButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside);
        button.frame = CGRectMake(backViewRightOriginX, 0, btnWidth, CGRectGetHeight(cell.frame));
        cell.backView.addSubview(button)
        button.tag = 1000 + indexPath.row;
        
        // You can also put a button with title on backView.
        button = UIButton(type: UIButtonType.System);
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal);
        button.setTitle("delete", forState: UIControlState.Normal);
        button.addTarget(self, action: #selector(ViewController.deleteButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside);
        button.frame = CGRectMake(backViewRightOriginX + btnWidth, 0, btnWidth, CGRectGetHeight(cell.frame));
        cell.backView.addSubview(button);
        button.tag = 1001 + indexPath.row;
       
        cell.frontView.viewWithTag(101)?.removeFromSuperview();
        
        // You can put anything you want to display on frontView like the backView above.
        button = UIButton(type: UIButtonType.System);
        button.setTitle("frontButton", forState: UIControlState.Normal);
        button.addTarget(self, action: #selector(ViewController.buttonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside);
        button.sizeToFit();
        cell.frontView.addSubview(button);
        button.tag = 101;
        
        return cell;
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("tableViewCell didSelect");
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? XXSwipeableCell {
            cell.close(true);
        }
    }

}

