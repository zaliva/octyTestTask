import UIKit

let Coordinator = CoordinatorImpl.shared

class CoordinatorImpl {
    
    static let shared = CoordinatorImpl()
    
    private init() {}
    
    func showRootViewController() {
        UIApplication.shared.delegate?.window??.rootViewController = CompositionRoot.resolveRootViewController()
        UIApplication.shared.delegate?.window??.makeKeyAndVisible()
    }
    
    func showMainTabBarController() {
        let navController = UINavigationController(rootViewController: CompositionRoot.resolveTabBarController())
        navController.navigationBar.isHidden = true
        navController.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.delegate?.window??.rootViewController = navController
        UIApplication.shared.delegate?.window??.makeKeyAndVisible()
    }
    
    func logout() {
        Persistance.clearAllUserDefaults()
    }
    
    func push(_ vc: UIViewController, animated: Bool = true) {
        currentNavigationController?.pushViewController(vc, animated: animated)
    }
    
    private var originKeyWindow: UIWindow?
    
    weak var currentNavigationController: UINavigationController? {
        get {
            if originKeyWindow == nil {
                originKeyWindow = UIApplication.shared.currentKeyWindow
            }
            let window = originKeyWindow ?? UIApplication.shared.currentKeyWindow
            
            var vc: UIViewController = window?.rootViewController ?? UIViewController()
            var navVC: UINavigationController?
            if vc.presentedViewController != nil {
                vc = vc.presentedViewController ?? UIViewController()
            }
            
            if vc is UINavigationController {
                navVC = vc as? UINavigationController
            } else if let tabBarVC = vc as? UITabBarController {
                navVC = tabBarVC.selectedViewController as? UINavigationController
            }
            
            if navVC == nil {
                debugPrint("error:1000.[Navigation not found,please restart application]")
            }
            
            return navVC
        }
    }
}
