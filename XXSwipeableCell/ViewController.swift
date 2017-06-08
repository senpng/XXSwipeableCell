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
    
    var dataArray = Array (repeating: 0 , count: 10 ) ;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "XXSwipeableCell";
        
        self.tableView.tableFooterView = UIView();z
        self.tableView.separatorStyle = .none;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.tableView.register(XXSwipeableCell.self, forCellReuseIdentifier: "XXSwipeableCell");
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

    @IBAction func slidingAction(_ sender: UISlider) {
        
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
    func buttonAction(_ sender:UIButton) {
        
        print(sender);
    }

    func deleteButtonAction(_ sender: UIButton) {// sender.tag = 1001 + indexPath.row
        
        let indexPath = IndexPath(row: sender.tag - 1001, section: 0);
        
        // 
        if let cell = tableView.cellForRow(at: indexPath) as? XXSwipeableCell {
            cell.overlayView?.removeFromSuperview();
        }
        dataArray.remove(at: indexPath.row);
        
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade);
        
        tableView.reloadData();
       
        print(sender)
    }
    
    func cancleButtonAction(_ sender:UIButton)  {// sender.tag = 1000 + indexPath.row
        
        let indexPath = IndexPath(row: sender.tag - 1000, section: 0);

        if let cell = tableView.cellForRow(at: indexPath) as? XXSwipeableCell {
            cell.close(true);
        }
        print(sender);
    }
    
    func collectionButtonAction(_ sender:UIButton) {// sender.tag = 999 + indexPath.row
     
        let indexPath = IndexPath(row: sender.tag - 999, section: 0);

        if let cell = tableView.cellForRow(at: indexPath) as? XXSwipeableCell {
            cell.close(true);
        }
        print(sender);
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = XXSwipeableCell(style: UITableViewCellStyle.Default, reuseIdentifier: "XXSwipeableCell");
        let cell = tableView.dequeueReusableCell(withIdentifier: "XXSwipeableCell") as! XXSwipeableCell;
        
        cell.selectionStyle = .none;
        cell.backView.backgroundColor = randomColor();
        
        if cell.frontView.backgroundColor == UIColor.white {
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
        var button = UIButton(type: UIButtonType.system);
        button.setTitleColor(UIColor.white, for: UIControlState());
        button.setTitle("collection", for: UIControlState());
        button.addTarget(self, action: #selector(ViewController.collectionButtonAction(_:)), for: UIControlEvents.touchUpInside);
        button.frame = CGRect(x: 0, y: 0, width: cell.leftVisiblePercentage * self.view.frame.width, height: cell.frame.height);
        cell.backView.addSubview(button);
        button.tag = 999 + indexPath.row;
       
        // The width for each button on right visible backView .
        let backViewRightVisibleWidth = cell.rightVisiblePercentage * self.view.frame.width;
        
        // For example, we add two items on backView here.
        let btnWidth = backViewRightVisibleWidth / 2;
       
        // The Origin.x of first item on right visible backView.
        let backViewRightOriginX = (self.view.frame.width - backViewRightVisibleWidth);

        // You can put a button with image on backView.
        button = UIButton(type: UIButtonType.system);
        button.setImage(UIImage(named: "cancle"), for: UIControlState());
        button.addTarget(self, action: #selector(ViewController.cancleButtonAction(_:)), for: UIControlEvents.touchUpInside);
        button.frame = CGRect(x: backViewRightOriginX, y: 0, width: btnWidth, height: cell.frame.height);
        cell.backView.addSubview(button)
        button.tag = 1000 + indexPath.row;
        
        // You can also put a button with title on backView.
        button = UIButton(type: UIButtonType.system);
        button.setTitleColor(UIColor.white, for: UIControlState());
        button.setTitle("delete", for: UIControlState());
        button.addTarget(self, action: #selector(ViewController.deleteButtonAction(_:)), for: UIControlEvents.touchUpInside);
        button.frame = CGRect(x: backViewRightOriginX + btnWidth, y: 0, width: btnWidth, height: cell.frame.height);
        cell.backView.addSubview(button);
        button.tag = 1001 + indexPath.row;
       
        cell.frontView.viewWithTag(101)?.removeFromSuperview();
        
        // You can put anything you want to display on frontView like the backView above.
        button = UIButton(type: UIButtonType.system);
        button.setTitle("frontButton", for: UIControlState());
        button.addTarget(self, action: #selector(ViewController.buttonAction(_:)), for: UIControlEvents.touchUpInside);
        button.sizeToFit();
        cell.frontView.addSubview(button);
        button.tag = 101;
        
        return cell;
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tableViewCell didSelect");
        if let cell = tableView.cellForRow(at: indexPath) as? XXSwipeableCell {
            cell.close(true);
        }
    }

}

