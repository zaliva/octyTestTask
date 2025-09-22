import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        
        self.delegate = self
        
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.selected.iconColor = .link
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.link]
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .link
        tabBar.unselectedItemTintColor = .gray
        tabBar.isTranslucent = false
    }
    
    private func setupTabs() {
        let ratesVC = createNavigationWith(CompositionRoot.resolveRatesViewController(), title: "Rates", image: UIImage(systemName: "list.bullet"), selectedImage: UIImage(systemName: "list.bullet"))
        let favoritesVC = createNavigationWith(CompositionRoot.resolveFavoritesViewController(), title: "Favorites", image: UIImage(systemName: "star"), selectedImage: UIImage(systemName: "star.fill"))
        self.setViewControllers([ratesVC, favoritesVC], animated: true)
    }
    
    private func createNavigationWith(_ vc: UIViewController?, title: String, image: UIImage?, selectedImage: UIImage?) -> UINavigationController {
        guard let vc = vc else { return UINavigationController() }
        let navVC = UINavigationController(rootViewController: vc)
        navVC.tabBarItem.title = title
        navVC.tabBarItem.image = image
        navVC.tabBarItem.selectedImage = selectedImage
        return navVC
    }
}

extension MainTabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let tabBarItemView = tabBarController.tabBar.selectedItem?.value(forKey: "view") as? UIView else { return }
        addScaleAnimationOnView(tabBarItemView)
    }

    // Animation of pressing tabbar items
    func addScaleAnimationOnView(_ animationView: UIView?) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values = [1.0, 1.15, 0.9, 1.08, 0.95, 1.02, 1.0]
        animation.duration = 0.5
        animation.calculationMode = .cubic
        animationView?.layer.add(animation, forKey: nil)
    }
}
