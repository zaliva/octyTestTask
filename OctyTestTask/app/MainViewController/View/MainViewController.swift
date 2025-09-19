import UIKit

protocol MainViewControllerProtocol: NSObjectProtocol {
    func showError(error: ApiError)
}

class MainViewController: BaseViewController<MainViewModel> {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MainViewController: MainViewControllerProtocol {
    
    func showError(error: ApiError) {
        let alert = UIAlertController(title: error.propertyName, message: error.displayMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
}


