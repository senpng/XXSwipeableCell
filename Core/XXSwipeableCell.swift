//
//  XXSwipeableCell.swift
//

import UIKit

@objc public protocol XXSwipeableCellDelegate: NSObjectProtocol {
    @objc optional func swipeableCell(_ cell: XXSwipeableCell, willBeginSliding slidingPoint: CGPoint)
    @objc optional func swipeableCell(_ cell: XXSwipeableCell, didSliding slidingPoint: CGPoint)
    @objc optional func swipeableCell(_ cell: XXSwipeableCell, willEndSliding slidingPoint: CGPoint)
    @objc optional func swipeableCell(_ cell: XXSwipeableCell, didEndSliding slidingPoint: CGPoint)
}

open class XXSwipeableCell: UITableViewCell, XXOverlayViewDelegate {
    
    weak open var delegate: XXSwipeableCellDelegate?;
    
    /// Whether to support multiple cells keep sliding state, default is false.
    open static var enabledMultipleSliding: Bool = false;
    
    /// Open the sliding function
    open var enabledSliding: Bool = true {
        didSet {
            if enabledSliding == false {
                self.close(false);
            }
        }
    };
    
    /// The duration of the animation
    open var animationDuration = 0.2;
    
    /// The trigger ratio of left slide: 0<x<=1, if > 1 or <= 0 leftVisiblePercentage as a block sliding parameter
    open var leftPercentage: CGFloat = -1.0;
    
    /// The trigger ratio of right slide : 0<x<1, if > 1 or <= 0 rightVisiblePerCentage as a block sliding parameter
    open var rightPercentage: CGFloat = 0.15;
    
    /// The visible percentage on the left: 0 <= x <= 1
    open var leftVisiblePercentage: CGFloat = 0.05;
    
    /// The visible percentage on the right: 0 <= x <= 1
    open var rightVisiblePercentage: CGFloat = 1.0;
    
    /// The front view in cell.
    open let frontView = UIView();
    
    /// The back view in cell.
    open let backView = UIView();
    
    
    internal var overlayView: XXOverlayView?;
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        initView();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initView();
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /**
     Whether an animation is required when close view.
     
     - parameter animated: BOOL, default is false.
     */
    open func close(_ animated: Bool) {
        self.close(animated, completion: nil);
    }

    /**
     Whether an animation is required and completion action when close view.
     
     - parameter animated:   BOOL, default is false.
     - parameter completion: default is nil.
     */
    open func close(_ animated: Bool, completion: ((_ finish: Bool)->Void)?) {
        
        if animated { // Need animation.
            
            UIView.animate(withDuration: animationDuration, animations: {
                self.frontView.frame.origin.x = 0;
                }, completion: { (finish) in
                    self.overlayView?.removeFromSuperview();
                    self.overlayView = nil;
                    self.removeTapGestureRecognizer(self.frontView);
                    self.removeTapGestureRecognizer(self.backView);
                    completion?(finish);
            });
        } else { /// Don't need animation.
            
            self.frontView.frame.origin.x = 0;
            overlayView?.removeFromSuperview();
            overlayView = nil;
            self.removeTapGestureRecognizer(self.frontView);
            self.removeTapGestureRecognizer(self.backView);
            completion?(true);
        }
    }
    
    /// Initialize
    fileprivate func initView() {
        
        self.contentView.addSubview(backView);
        setViewFillConstraint(backView);
        
        frontView.backgroundColor = UIColor.white;
        self.contentView.addSubview(frontView);
        setViewFillConstraint(frontView);
        
        let frontViewPan = UIPanGestureRecognizer(target: self, action: #selector(XXSwipeableCell.panAction(_:)));
        frontViewPan.delegate = self;
        frontView.addGestureRecognizer(frontViewPan);
        
        let backViewPan = UIPanGestureRecognizer(target: self, action: #selector(XXSwipeableCell.panAction(_:)));
        backViewPan.delegate = self;
        backView.addGestureRecognizer(backViewPan);
    }
    
    /**
     Set up the constraints of view
     
     - parameter v: the view to set up the constraints
     */
    fileprivate func setViewFillConstraint(_ v: UIView) {
        
        v.translatesAutoresizingMaskIntoConstraints = false;
        
        let contraints_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view":v]);
        
        let contraints_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view":v]);
        
        self.contentView.addConstraints(contraints_V);
        self.contentView.addConstraints(contraints_H);

    }
    
    fileprivate var savedFrame = CGRect.zero;
    // MARK: - pan Actions
    @objc fileprivate func panAction(_ panG: UIPanGestureRecognizer) {
        
        let point = panG.translation(in: self.contentView);
        let width = self.contentView.bounds.width;
        
        switch panG.state {
        case .began:
        
            savedFrame = frontView.frame;
            
            self.willBeginSliding(point);
            
        case .changed:
            
            self.didSliding(point);
            
            let offsetX = savedFrame.minX + point.x;
            
            frontView.frame.origin.x = offsetX;
            
            if point.x < 0 { // left slide
                
                if rightPercentage > 1 || rightPercentage <= 0 {
                    
                    if frontView.frame.minX < width * rightVisiblePercentage * (-1)  {
                        frontView.frame.origin.x = width * rightVisiblePercentage * (-1);
                    }
                    
                }
                
            } else { // right slide
                
                if leftPercentage > 1 || leftPercentage <= 0 {
                    
                    if frontView.frame.minX > width * leftVisiblePercentage {
                        frontView.frame.origin.x = width * leftVisiblePercentage;
                    }
                    
                }
            }
            
            
        case .ended:
            
            self.willEndSliding(point);
            
            if point.x < 0 { // left slide
                if rightPercentage > 1 || rightPercentage <= 0 {
                    self.close(true, completion: { (finish) in
                        self.didEndSliding(point);
                    })
                } else {
                    if frontView.frame.minX < width * rightPercentage * (-1) {
                        UIView.animate(withDuration: animationDuration, animations: {
                            
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
            } else { // right slide
                if leftPercentage > 1 || leftPercentage <= 0 {
                    self.close(true, completion: { (finish) in
                        self.didEndSliding(point);
                    })
                } else {
                    if frontView.frame.minX > width * leftPercentage {
                        
                        UIView.animate(withDuration: animationDuration, animations: {
                            
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
    
    /// Add XXOverlayView
    fileprivate func addOverlayView() {
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
    
    ///  Remove the gestures on view
    fileprivate func removeTapGestureRecognizer(_ view: UIView) {
        
        guard let gestureRecognizers = view.gestureRecognizers, gestureRecognizers.count > 0 else {
            return;
        }
        
        for g in gestureRecognizers {
            if g is UITapGestureRecognizer {
                view.removeGestureRecognizer(g);
            }
        }
    }
    
    // MARK: - UIPanGestureRecognizerDelegate
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panG = gestureRecognizer as? UIPanGestureRecognizer {
            if enabledSliding == false {
                return false;
            }
            let distance = panG.translation(in: self);
            return abs(distance.x) > abs(distance.y);
        }
        return true;
    }
    
    fileprivate var removingOverlayView = false;
    // MARK: - OverlayViewDelegate
    open func overlayView(_ view: XXOverlayView, didHitTest point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        var p = frontView.convert(point, from: view);
        if frontView.point(inside: p, with: event) {
            return frontView.hitTest(p, with: event);
        }

        p = backView.convert(point, from: view);
        if backView.point(inside: p, with: event) {
            return backView.hitTest(p, with: event);
        }
        
        if !removingOverlayView {
            removingOverlayView = true;
            
            self.close(true, completion: { (finish) in
                self.removingOverlayView = false;
            })
        }
        
        // If you need to support a cell has been slided to expand, and can slide other cells, it returns nil. When a cell was slided to expand, you need to can not slide other cells, can return view (XXOverlayView).
        return nil;
    }

    /// Override need super.
    func willBeginSliding(_ slidingPoint: CGPoint) {
        delegate?.swipeableCell?(self, willBeginSliding: slidingPoint);
    }
    
    func didSliding(_ slidingPoint: CGPoint) {
        delegate?.swipeableCell?(self, didSliding: slidingPoint);
    }
    
    func willEndSliding(_ slidingPoint: CGPoint) {
        delegate?.swipeableCell?(self, willEndSliding: slidingPoint);
    }
    
    func didEndSliding(_ slidingPoint: CGPoint) {
        delegate?.swipeableCell?(self, didEndSliding: slidingPoint);
    }
}

// MARK: - XXOverlayView
@objc public protocol XXOverlayViewDelegate {
    @objc optional func overlayView(_ view: XXOverlayView, didHitTest point: CGPoint, withEvent event: UIEvent?) -> UIView?;
}

/// Cover the entire screen, disappear when you click on the screen.
open class XXOverlayView: UIView {
    
    weak var delegate: XXOverlayViewDelegate?
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        var result = self.delegate?.overlayView?(self, didHitTest: point, withEvent: event);
        
        if result === self {
            result = super.hitTest(point, with: event);
        }
        
        return result;
    }
}

// MARK: - extension for UITapGestureRecognizer
public extension UITapGestureRecognizer {
    
    typealias ActionBlock = @convention(block) (_ tapG: UITapGestureRecognizer)->Void;
    
    fileprivate struct AssociatedKeys {
        static var actionBlockKey = "actionBlockKey"
    }
    
    fileprivate var actionBlock: ActionBlock? {
        set {
            
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.actionBlockKey, unsafeBitCast(value, to: AnyObject.self), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        
        get {
            guard let object = objc_getAssociatedObject(self, &AssociatedKeys.actionBlockKey) else {
                return nil;
            }

            return unsafeBitCast(object, to: ActionBlock.self);
        }
    }
    
    convenience public init(block: @escaping ActionBlock) {
        self.init(target: nil, action: nil);
        
        self.addTarget(self, action: #selector(UITapGestureRecognizer.tapAction(_:)))
        
        self.actionBlock = block;
    }
    
    @objc fileprivate func tapAction(_ tapG: UITapGestureRecognizer) {
        self.actionBlock?(self)
    }
    
}
