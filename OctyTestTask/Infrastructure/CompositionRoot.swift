import UIKit

let CompositionRoot = CompositionRootImpl.sharedInstance

class CompositionRootImpl {

    static var sharedInstance = CompositionRootImpl()

    private init() {}
    
    func resolveRootViewController() -> RootViewController {
        let vc = RootViewController.instantiateFromStoryboard("RootViewController")
        return vc
    }
    
    func resolveTabBarController() -> MainTabBarController {
        return MainTabBarController()
    }
    
    func resolveRatesViewController() -> RatesViewController {
        let vc = RatesViewController.instantiateFromStoryboard("RatesViewController")
        vc.viewModel = RatesViewModel(view: vc, type: .list)
        return vc
    }
    
    func resolveFavoritesViewController() -> RatesViewController {
        let vc = RatesViewController.instantiateFromStoryboard("RatesViewController")
        vc.viewModel = RatesViewModel(view: vc, type: .favorites)
        return vc
    }
}
