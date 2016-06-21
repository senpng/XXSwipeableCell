//
//  XXSwipeableCell.swift
//

import UIKit

@objc public protocol XXSwipeableCellDelegate {
    optional func swipeableCell(cell: XXSwipeableCell, willBeginSliding slidingPoint: CGPoint)
    optional func swipeableCell(cell: XXSwipeableCell, didSliding slidingPoint: CGPoint)
    optional func swipeableCell(cell: XXSwipeableCell, willEndSliding slidingPoint: CGPoint)
    optional func swipeableCell(cell: XXSwipeableCell, didEndSliding slidingPoint: CGPoint)
}

public class XXSwipeableCell: UITableViewCell, XXOverlayViewDelegate {
    
    weak public var delegate: XXSwipeableCellDelegate?;
    
    /// 动画时间
    public var animationDuration = 0.2;
    
    /// 左滑动显示触发比例 0<x<=1, if > 1 or <= 0 leftVisiblePercentage作为阻塞滑动参数
    public var leftPercentage: CGFloat = -1.0;
    
    /// 右滑动显示触发比例 0<x<1, if > 1 or <= 0 rightVisiblePerCentage作为阻塞滑动参数
    public var rightPercentage: CGFloat = 0.2;
    
    /// 左边显示比例 0 <= x <= 1
    public var leftVisiblePercentage: CGFloat = 0.1;
    
    /// 右边显示比例 0 <= x <= 1
    public var rightVisiblePercentage: CGFloat = 1.0;
    
    
    public let frontView = UIView();
    public let backView = UIView();
    
    private var _overlay = XXOverlayView();
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        initView();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initView();
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func initView() {
        
        self.contentView.addSubview(backView);
        setViewFillConstraint(backView);
        
        frontView.backgroundColor = UIColor.whiteColor();
        self.contentView.addSubview(frontView);
        setViewFillConstraint(frontView);
        
        
        let frontViewPan = UIPanGestureRecognizer(target: self, action: #selector(XXSwipeableCell.panAction(_:)));
        frontViewPan.delegate = self;
        frontView.addGestureRecognizer(frontViewPan);
        
        let backViewPan = UIPanGestureRecognizer(target: self, action: #selector(XXSwipeableCell.panAction(_:)));
        backViewPan.delegate = self;
        backView.addGestureRecognizer(backViewPan);
    }
    
    internal func setViewFillConstraint(v: UIView) {
        
        v.translatesAutoresizingMaskIntoConstraints = false;
        
        let contraints_V = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["view":v]);
        
        let contraints_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["view":v]);
        
        self.contentView.addConstraints(contraints_V);
        self.contentView.addConstraints(contraints_H);

    }
    
    var savedFrame = CGRectZero;
    // MARK: - Actions
    func panAction(panG: UIPanGestureRecognizer) {
        
        let point = panG.translationInView(self.contentView);
        let width = CGRectGetWidth(self.contentView.bounds);
        
        switch panG.state {
        case .Began:
            
            savedFrame = frontView.frame;
            
            delegate?.swipeableCell?(self, willBeginSliding: point);
            
        case .Changed:
            
            delegate?.swipeableCell?(self, didSliding: point);
            
            let offsetX = CGRectGetMinX(savedFrame) + point.x;
            
            frontView.frame.origin.x = offsetX;
            
            if point.x < 0 { //左滑
                
                if rightPercentage > 1 || rightPercentage <= 0 {
                    
                    if CGRectGetMinX(frontView.frame) < width * rightVisiblePercentage * (-1)  {
                        frontView.frame.origin.x = width * rightVisiblePercentage * (-1);
                    }
                    
                }
                
            } else { //右滑
                
                if leftPercentage > 1 || leftPercentage <= 0 {
                    
                    if CGRectGetMinX(frontView.frame) > width * leftVisiblePercentage {
                        frontView.frame.origin.x = width * leftVisiblePercentage;
                    }
                    
                }
            }
            
            
        case .Ended:
            
            delegate?.swipeableCell?(self, willEndSliding: point);
            
            if point.x < 0 { //左滑
                if rightPercentage > 1 || rightPercentage <= 0 {
                    UIView.animateWithDuration(animationDuration, animations: {
                        self.frontView.frame.origin.x = 0;
                        }, completion: { (finish) in
                            self.delegate?.swipeableCell?(self, didEndSliding: point);
                    });
                } else {
                    if CGRectGetMinX(frontView.frame) < width * rightPercentage * (-1) {
                        UIView.animateWithDuration(animationDuration, animations: {
                            
                            self.frontView.frame.origin.x = -width*self.rightVisiblePercentage;
                            
                            }, completion: { (finish) in
                                
                                self.delegate?.swipeableCell?(self, didEndSliding: point);
                                
                                self._overlay.removeFromSuperview();
                                
                                if let window = self.window {
                                    self._overlay.frame = window.bounds;
                                    self._overlay.delegate = self;
                                    window.addSubview(self._overlay);
                                }
                        });
                    } else {
                        UIView.animateWithDuration(animationDuration, animations: {
                            self.frontView.frame.origin.x = 0;
                            }, completion: { (finish) in
                            self.delegate?.swipeableCell?(self, didEndSliding: point);
                        });
                    }
                }
            } else { //右滑
                if leftPercentage > 1 || leftPercentage <= 0 {
                    UIView.animateWithDuration(animationDuration, animations: {
                        self.frontView.frame.origin.x = 0;
                        }, completion: { (finish) in
                        self.delegate?.swipeableCell?(self, didEndSliding: point);
                    });
                } else {
                    if CGRectGetMinX(frontView.frame) > width * leftPercentage {
                        
                        UIView.animateWithDuration(animationDuration, animations: {
                            
                            self.frontView.frame.origin.x = width*self.leftVisiblePercentage;
                            
                            }, completion: { (finish) in
                                
                                self.delegate?.swipeableCell?(self, didEndSliding: point);
                                
                                self._overlay.removeFromSuperview();
                                
                                if let window = self.window {
                                    self._overlay.frame = window.bounds;
                                    self._overlay.delegate = self;
                                    window.addSubview(self._overlay);
                                }
                        });
                        
                    } else {
                        UIView.animateWithDuration(animationDuration, animations: {
                            self.frontView.frame.origin.x = 0;
                            }, completion: { (finish) in
                            self.delegate?.swipeableCell?(self, didEndSliding: point);
                        });
                    }
                }
            }
            
        default:
            break
        }
        
    }
    
    // MARK: - UIPanGestureRecognizerDelegate
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if self.editing {
            return false;
        }

        
        if let panG = gestureRecognizer as? UIPanGestureRecognizer {
            
            let distance = panG.translationInView(self);
            
            return abs(distance.x) > abs(distance.y);
        }
        
        return false;
    }
    
    // MARK: - OverlayViewDelegate
    public func overlayView(view: XXOverlayView, didHitTest point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        if CGRectContainsPoint(self.contentView.frame, view.convertPoint(point, toView: self.contentView)) {
            if CGRectGetMinX(frontView.frame) < 0 {
                return backView
            }
            return frontView;
        }
        UIView.animateWithDuration(animationDuration) {
            self.frontView.frame.origin.x = 0
        }
        view.removeFromSuperview();
        
        return nil;
    }


}

@objc public protocol XXOverlayViewDelegate {
    optional func overlayView(view: XXOverlayView, didHitTest point: CGPoint, withEvent event: UIEvent?) -> UIView?;
}

public class XXOverlayView: UIView {
    
    weak var delegate: XXOverlayViewDelegate?
    
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return self.delegate?.overlayView?(self, didHitTest: point, withEvent: event);
    }
    
}