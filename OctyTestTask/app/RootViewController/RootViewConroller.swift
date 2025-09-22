
import UIKit

class RootViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Coordinator.showMainTabBarController()
    }
}
