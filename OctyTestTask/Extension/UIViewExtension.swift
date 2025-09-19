
import UIKit
import SnapKit

extension UIView {
    
    @discardableResult
    func fromNib<T: UIView>(withName name: String?) -> T? {
        guard let name = name, let view = Bundle.main.loadNibNamed(name, owner: self, options: nil)?[0] as? T else {
            return nil
        }
        self.backgroundColor = .clear
        fitted(view: view)
        return view
    }
    
    @discardableResult
    func fromNib<T: UIView>() -> T? {
        let name = String(describing: type(of: self))
        return fromNib(withName: name)
    }
    
    func fitted(view: UIView) {
        self.addSubview(view)
        
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension UIView {
    class TapHelper: UITapGestureRecognizer {
       var onTap : (() -> Void)? = nil
    }
    
    public func addClickedBlock(_ action : (() -> Void)?) {
        gestureRecognizers?.forEach({ gesture in
            if gesture is UITapGestureRecognizer {
                (gesture as? TapHelper)?.onTap = nil
                self.removeGestureRecognizer(gesture)
            }
        })
            
        self.isUserInteractionEnabled = true
        let tap = TapHelper(target: self, action: #selector(onViewTapped(sender:)))
        tap.onTap = action
        self.addGestureRecognizer(tap)
    }
    
    @objc func onViewTapped(sender: TapHelper) {
        if let onClick = sender.onTap {
            onClick()
        }
    }
}

extension UIView {
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }

        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var circle: Bool {
        get {
            return cornerRadiusWithMasks == self.frame.width/2
        }
        set {
            let minDimension = min(self.frame.width, self.frame.height)
            cornerRadiusWithMasks = (newValue ? minDimension/2 : 0)
        }
    }

    @IBInspectable var cornerRadiusWithMasks: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.masksToBounds = newValue > 0
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }

        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }

        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable var layerShadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }

    @IBInspectable var layerShadowColor: UIColor {
        get {
            if let layerShadowColor = layer.shadowColor {
                return UIColor.init(cgColor: layerShadowColor)
            } else {
                return UIColor.clear
            }
        }
        set { layer.shadowColor = newValue.cgColor }
    }

    @IBInspectable public var zPosition: CGFloat {
        get {
            return layer.zPosition
        }

        set {
            layer.zPosition = newValue
        }
    }
    
    class func animate(_ animations: @escaping (() -> Void), completion: (() -> Void)? = nil) {
        UIView.animate(withDecision: true,
                       animations: animations,
                       completion: completion)
    }
    
    class func animate(withDecision isAnimated: Bool,
                       animations: @escaping (() -> Void),
                       completion: (() -> Void)? = nil) {
        guard isAnimated else {
            animations()
            completion?()
            return
        }
        
        let parameters = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.230, y: 1.000),
                                                 controlPoint2: CGPoint(x: 0.320, y: 1.000))
        
        let animator = UIViewPropertyAnimator(duration: TimeInterval(0.4),
                                              timingParameters: parameters)
        animator.addAnimations(animations)
        animator.addCompletion { _ in
            completion?()
        }
        animator.startAnimation()
    }
}
