import Foundation

class RatesViewModel: ViewModel {
    
    var view: RatesViewControllerProtocol?
    var type: RatesControllerType
    var ratesModels = [RatesDataModel]()
    
    // MARK: - Initialization
    init(view: RatesViewControllerProtocol, type: RatesControllerType) {
        self.view = view
        self.type = type
    }
    
    func getRatesList() {
        Toast.show()
        NetworkManager.getRates { [weak self] array in
            Toast.dismiss()
            guard let self else { return }
            let ratesDataModels = RatesDataProvider.insertAndUpdateArrayRatesModel(array)
            switch self.type {
            case .list:
                self.ratesModels = ratesDataModels
            case .favorites:
                self.ratesModels = RatesDataProvider.getFavoritesRatesDataModels()
            }
            self.ratesModels.sort { $0.id < $1.id }
            self.view?.updateCollectionView(animating: false)
        } failure: { [weak self] error in
            Toast.dismiss()
            self?.getRatesFormCoreData()
            self?.view?.showError(error: error)
        }
    }
    
    func getRatesFormCoreData() {
        switch type {
        case .list:
            self.ratesModels = RatesDataProvider.getRatesDataModels()
        case .favorites:
            self.ratesModels = RatesDataProvider.getFavoritesRatesDataModels()
        }
        self.ratesModels.sort { $0.id < $1.id }
        self.view?.updateCollectionView(animating: true)
    }
    
    func addOrRemoveFavorites(model: RatesDataModel) {
        RatesDataProvider.addOrRemoveFavorites(model, isFavorites: !model.isFavorites)
        getRatesFormCoreData()
    }
}

enum RatesControllerType: String {
    case list = "Rates"
    case favorites = "Favorites"
}
    
