import UIKit

extension UIViewController {
    class func instantiateFromStoryboard(_ name: String) -> Self {
        return instantiateFromStoryboardHelper(name)
    }
    
    fileprivate class func instantiateFromStoryboardHelper<T>(_ name: String) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let identifier = String(describing: self)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return controller
    }
    
    func topBarHeight() -> Float {
        return Float(self.navigationController?.navigationBar.bounds.height ?? 0.0)
    }
    
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    func statusBarFrame() -> CGRect {
        let window = UIApplication.shared.currentKeyWindow
        return window?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
    }
    
    func isFirstController() -> Bool {
        return (presentingViewController != nil &&
                navigationController?.viewControllers.count == 1)
    }
    
    var safeAreaBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.currentKeyWindow?.safeAreaInsets.bottom ?? 0
        } else {
            return 0
        }
    }
    
    var safeAreaTopInset: CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.currentKeyWindow?.safeAreaInsets.top ?? 0
        } else {
            return 0
        }
    }
    
    var safeAreaTopWithNavigationBar: CGFloat {
        return safeAreaTopInset + (navigationController?.navigationBar.bounds.height ?? 0)
    }
}
