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
    
    override func viewWillAppear() {
        super.viewWillAppear()
        getRatesList()
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
            self.view?.updateCollectionView()
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
        self.view?.updateCollectionView()
    }
    
    func addOrRemoveFavorites(model: RatesDataModel) {
        RatesDataProvider.addOrRemoveFavorites(model, isFavorites: !model.isFavorites)
        switch type {
        case .list:
            if let idx = self.ratesModels.firstIndex(where: { $0.id == model.id }) {
                self.ratesModels[idx].isFavorites.toggle()
            }
        case .favorites:
            self.ratesModels.removeAll { $0.id == model.id }
        }
        self.view?.updateCollectionView()
    }
}

enum RatesControllerType: String {
    case list = "Rates"
    case favorites = "Favorites"
}
    
