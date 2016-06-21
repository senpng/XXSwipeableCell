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
    public var rightPercentage: CGFloat = 0.15;
    
    /// 左边显示比例 0 <= x <= 1
    public var leftVisiblePercentage: CGFloat = 0.05;
    
    /// 右边显示比例 0 <= x <= 1
    public var rightVisiblePercentage: CGFloat = 1.0;
    
    
    public let frontView = UIView();
    public let backView = UIView();
    
    internal var _overlayView: XXOverlayView?;
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
    
    public func close(animated: Bool) {
        self.close(animated, completion: nil);
    }
    
    public func close(animated: Bool, completion: ((finish: Bool)->Void)?) {
        if animated {
            UIView.animateWithDuration(animationDuration, animations: {
                self.frontView.frame.origin.x = 0;
                }, completion: { (finish) in
                    self._overlayView?.removeFromSuperview();
                    self._overlayView = nil;
                    completion?(finish: finish);
            });
        } else {
            self.frontView.frame.origin.x = 0;
            _overlayView?.removeFromSuperview();
            _overlayView = nil;
            completion?(finish: true);
        }
    }
    
    private func initView() {
        
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
    
    private func setViewFillConstraint(v: UIView) {
        
        v.translatesAutoresizingMaskIntoConstraints = false;
        
        let contraints_V = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["view":v]);
        
        let contraints_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["view":v]);
        
        self.contentView.addConstraints(contraints_V);
        self.contentView.addConstraints(contraints_H);

    }
    
    private var savedFrame = CGRectZero;
    // MARK: - Actions
    @objc private func panAction(panG: UIPanGestureRecognizer) {
        
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
                    self.close(true, completion: { (finish) in
                        self.delegate?.swipeableCell?(self, didEndSliding: point);
                    })
                } else {
                    if CGRectGetMinX(frontView.frame) < width * rightPercentage * (-1) {
                        UIView.animateWithDuration(animationDuration, animations: {
                            
                            self.frontView.frame.origin.x = -width*self.rightVisiblePercentage;
                            
                            }, completion: { (finish) in
                                
                                self.delegate?.swipeableCell?(self, didEndSliding: point);
                                
                                self.addOverlayView();
                        });
                    } else {
                        self.close(true, completion: { (finish) in
                            self.delegate?.swipeableCell?(self, didEndSliding: point);
                        })
                    }
                }
            } else { //右滑
                if leftPercentage > 1 || leftPercentage <= 0 {
                    self.close(true, completion: { (finish) in
                        self.delegate?.swipeableCell?(self, didEndSliding: point);
                    })
                } else {
                    if CGRectGetMinX(frontView.frame) > width * leftPercentage {
                        
                        UIView.animateWithDuration(animationDuration, animations: {
                            
                            self.frontView.frame.origin.x = width*self.leftVisiblePercentage;
                            
                            }, completion: { (finish) in
                                
                                self.delegate?.swipeableCell?(self, didEndSliding: point);
                                
                                self.addOverlayView();
                        });
                        
                    } else {
                        self.close(true, completion: { (finish) in
                            self.delegate?.swipeableCell?(self, didEndSliding: point);
                        })
                    }
                }
            }
            
        default:
            break
        }
        
    }
    
    private func addOverlayView() {
        self._overlayView?.removeFromSuperview();
        
        self._overlayView = XXOverlayView();
        
        if let window = self.window {
            self._overlayView?.frame = window.bounds;
            self._overlayView?.delegate = self;
            window.addSubview(self._overlayView!);
        }
    }
    
    // MARK: - UIPanGestureRecognizerDelegate
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if self.editing || self._overlayView != nil {
            return false;
        }

        
        if let panG = gestureRecognizer as? UIPanGestureRecognizer {
            
            let distance = panG.translationInView(self);
            
            return abs(distance.x) > abs(distance.y);
        }
        
        return false;
    }
    
    private var removingOverlayView = false;
    // MARK: - OverlayViewDelegate
    public func overlayView(view: XXOverlayView, didHitTest point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        var p = frontView.convertPoint(point, fromView: view);
        if frontView.pointInside(p, withEvent: event) {
            let result = frontView.hitTest(p, withEvent: event);
            if result !== frontView {
                return result;
            }
        }

        p = backView.convertPoint(point, fromView: view);
        if backView.pointInside(p, withEvent: event) {
            let result = backView.hitTest(p, withEvent: event);
            if result !== backView {
                return result;
            }
        }
        
        if !removingOverlayView {
            removingOverlayView = true;
            
            self.close(true, completion: { (finish) in
                self.removingOverlayView = false;
            })
        }
        
        return nil;
    }

}

@objc public protocol XXOverlayViewDelegate {
    optional func overlayView(view: XXOverlayView, didHitTest point: CGPoint, withEvent event: UIEvent?) -> UIView?;
}

public class XXOverlayView: UIView {
    
    weak var delegate: XXOverlayViewDelegate?
    
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        var result = self.delegate?.overlayView?(self, didHitTest: point, withEvent: event);
        
        if result == nil {
            result = super.hitTest(point, withEvent: event);
        }
        
        return result;
    }
    
}