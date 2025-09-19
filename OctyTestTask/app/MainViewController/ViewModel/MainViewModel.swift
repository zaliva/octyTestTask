import UIKit

class MainViewModel: ViewModel {
    
    var view: MainViewControllerProtocol?
    
    // MARK: - Initialization
    init(view: MainViewControllerProtocol) {
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
    
