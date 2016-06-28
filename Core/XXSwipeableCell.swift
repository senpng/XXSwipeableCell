//
//  XXSwipeableCell.swift
//

import UIKit

@objc public protocol XXSwipeableCellDelegate: NSObjectProtocol {
    optional func swipeableCell(cell: XXSwipeableCell, willBeginSliding slidingPoint: CGPoint)
    optional func swipeableCell(cell: XXSwipeableCell, didSliding slidingPoint: CGPoint)
    optional func swipeableCell(cell: XXSwipeableCell, willEndSliding slidingPoint: CGPoint)
    optional func swipeableCell(cell: XXSwipeableCell, didEndSliding slidingPoint: CGPoint)
}

public class XXSwipeableCell: UITableViewCell, XXOverlayViewDelegate {
    
    weak public var delegate: XXSwipeableCellDelegate?;
    
    /// 是否支持多个Cell滑动状态保持 默认false
    public static var enabledMultipleSliding: Bool = false;
    
    /// 开启滑动功能
    public var enabledSliding: Bool = true {
        didSet {
            if enabledSliding == false {
                self.close(false);
            }
        }
    };
    
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
    
    internal var overlayView: XXOverlayView?;
    
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
                    self.overlayView?.removeFromSuperview();
                    self.overlayView = nil;
                    self.removeTapGestureRecognizer(self.frontView);
                    self.removeTapGestureRecognizer(self.backView);
                    completion?(finish: finish);
            });
        } else {
            self.frontView.frame.origin.x = 0;
            overlayView?.removeFromSuperview();
            overlayView = nil;
            self.removeTapGestureRecognizer(self.frontView);
            self.removeTapGestureRecognizer(self.backView);
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
            
            self.willBeginSliding(point);
            
        case .Changed:
            
            self.didSliding(point);
            
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
            
            self.willEndSliding(point);
            
            if point.x < 0 { //左滑
                if rightPercentage > 1 || rightPercentage <= 0 {
                    self.close(true, completion: { (finish) in
                        self.didEndSliding(point);
                    })
                } else {
                    if CGRectGetMinX(frontView.frame) < width * rightPercentage * (-1) {
                        UIView.animateWithDuration(animationDuration, animations: {
                            
                            self.frontView.frame.origin.x = -width*self.rightVisiblePercentage;
                            
                            }, completion: { (finish) in
                                
                                self.addOverlayView();
                                
                                self.didEndSliding(point);
                        });
                    } else {
                        self.close(true, completion: { (finish) in
                            self.didEndSliding(point);
                        })
                    }
                }
            } else { //右滑
                if leftPercentage > 1 || leftPercentage <= 0 {
                    self.close(true, completion: { (finish) in
                        self.didEndSliding(point);
                    })
                } else {
                    if CGRectGetMinX(frontView.frame) > width * leftPercentage {
                        
                        UIView.animateWithDuration(animationDuration, animations: {
                            
                            self.frontView.frame.origin.x = width*self.leftVisiblePercentage;
                            
                            }, completion: { (finish) in
                                
                                self.addOverlayView();
                                
                                self.didEndSliding(point);
                        });
                        
                    } else {
                        self.close(true, completion: { (finish) in
                            self.didEndSliding(point);
                        })
                    }
                }
            }
            
        default:
            break
        }
        
    }
    
    private func addOverlayView() {
        self.overlayView?.removeFromSuperview();
        
        if XXSwipeableCell.enabledMultipleSliding == false {
            self.overlayView = XXOverlayView();
            
            if let window = self.window {
                self.overlayView?.frame = window.bounds;
                self.overlayView?.delegate = self;
                window.addSubview(self.overlayView!);
            }
        }
        
        frontView.addGestureRecognizer(UITapGestureRecognizer { (tapG) in
            self.close(true);
        });
        
        backView.addGestureRecognizer(UITapGestureRecognizer { (tapG) in
            self.close(true);
        });
    }
    
    private func removeTapGestureRecognizer(view: UIView) {
        
        guard let gestureRecognizers = view.gestureRecognizers where gestureRecognizers.count > 0 else {
            return;
        }
        
        for g in gestureRecognizers {
            if g is UITapGestureRecognizer {
                view.removeGestureRecognizer(g);
            }
        }
    }
    
    // MARK: - UIPanGestureRecognizerDelegate
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panG = gestureRecognizer as? UIPanGestureRecognizer {
            if enabledSliding == false {
                return false;
            }
            let distance = panG.translationInView(self);
            return abs(distance.x) > abs(distance.y);
        }
        return true;
    }
    
    private var removingOverlayView = false;
    // MARK: - OverlayViewDelegate
    public func overlayView(view: XXOverlayView, didHitTest point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        var p = frontView.convertPoint(point, fromView: view);
        if frontView.pointInside(p, withEvent: event) {
            return frontView.hitTest(p, withEvent: event);
        }

        p = backView.convertPoint(point, fromView: view);
        if backView.pointInside(p, withEvent: event) {
            return backView.hitTest(p, withEvent: event);
        }
        
        if !removingOverlayView {
            removingOverlayView = true;
            
            self.close(true, completion: { (finish) in
                self.removingOverlayView = false;
            })
        }
        
        //如果需要支持某个cell已经滑动展开，并且可以滑动其它cell，则返回nil。当某个cell滑动展开，需要无法滑动其它cell，可以返回view(XXOverlayView)
        return nil;
    }

    /// Override need super.
    func willBeginSliding(slidingPoint: CGPoint) {
        delegate?.swipeableCell?(self, willBeginSliding: slidingPoint);
    }
    
    func didSliding(slidingPoint: CGPoint) {
        delegate?.swipeableCell?(self, didSliding: slidingPoint);
    }
    
    func willEndSliding(slidingPoint: CGPoint) {
        delegate?.swipeableCell?(self, willEndSliding: slidingPoint);
    }
    
    func didEndSliding(slidingPoint: CGPoint) {
        delegate?.swipeableCell?(self, didEndSliding: slidingPoint);
    }
}

@objc public protocol XXOverlayViewDelegate {
    optional func overlayView(view: XXOverlayView, didHitTest point: CGPoint, withEvent event: UIEvent?) -> UIView?;
}

public class XXOverlayView: UIView {
    
    weak var delegate: XXOverlayViewDelegate?
    
    
    
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        var result = self.delegate?.overlayView?(self, didHitTest: point, withEvent: event);
        
        if result === self {
            result = super.hitTest(point, withEvent: event);
        }
        
        return result;
    }
}

public extension UITapGestureRecognizer {
    
    typealias ActionBlock = @convention(block) (tapG: UITapGestureRecognizer)->Void;
    
    private struct AssociatedKeys {
        static var actionBlockKey = "actionBlockKey"
    }
    
    private var actionBlock: ActionBlock? {
        set {
            
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.actionBlockKey, unsafeBitCast(value, AnyObject.self), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        
        get {
            guard let object = objc_getAssociatedObject(self, &AssociatedKeys.actionBlockKey) else {
                return nil;
            }

            return unsafeBitCast(object, ActionBlock.self);
        }
    }
    
    convenience public init(block: ActionBlock) {
        self.init(target: nil, action: nil);
        
        self.addTarget(self, action: #selector(UITapGestureRecognizer.tapAction(_:)))
        
        self.actionBlock = block;
    }
    
    @objc private func tapAction(tapG: UITapGestureRecognizer) {
        self.actionBlock?(tapG: self)
    }
    
}