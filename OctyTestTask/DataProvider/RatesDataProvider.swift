import Foundation

let RatesDataProvider = RatesDataProviderImpl.shared

final class RatesDataProviderImpl {
    
    fileprivate static let shared = RatesDataProviderImpl()
    
    private init() {}
    
    func insertAndUpdateRatesModel(_ model: ResponceRatesModel) -> RatesDataModel? {
        
        var ratesDataModel: RatesDataModel?
        
        if let currentRatesDataModel = getCoinBy(baseCurrency: model.baseCurrency, quoteCurrency: model.quoteCurrency) {
            ratesDataModel = currentRatesDataModel
        } else if let currentRatesDataModel = createNewEntity() {
            ratesDataModel = currentRatesDataModel
        }
        
        fillRatesDataModel(model, ratesDataModel: ratesDataModel)
        return ratesDataModel
    }
    
    private func createNewEntity() -> RatesDataModel? {
        guard let coin = ECDManager.createObject(type: RatesDataModel.self) else { return nil }
        coin.id = UUID().uuidString
        return coin
    }
    
    func getCoinBy(baseCurrency: String, quoteCurrency: String) -> RatesDataModel? {
        let predicate = NSPredicate(format: "baseCurrency == %@ && quoteCurrency == %@", baseCurrency, quoteCurrency)
        let coin = ECDManager.fetchFirstObject(type: RatesDataModel.self, predicate: predicate)
        return coin
    }
    
    private func fillRatesDataModel(_ model: ResponceRatesModel, ratesDataModel: RatesDataModel?) {
        ratesDataModel?.baseCurrency = model.baseCurrency
        ratesDataModel?.quoteCurrency = model.quoteCurrency
        ratesDataModel?.quote = model.quote
        ratesDataModel?.date = model.date
    }
    
    func insertAndUpdateArrayRatesModel(_ models: [ResponceRatesModel]) -> [RatesDataModel] {
        var ratesDataModels = [RatesDataModel]()
        
        models.forEach {
            if let ratesDataModel = insertAndUpdateRatesModel($0) {
                ratesDataModels.append(ratesDataModel)
            }
        }
        ECDManager.saveContextAndWait()
        return ratesDataModels
    }
    
    func addOrRemoveFavorites(_ model: RatesDataModel, isFavorites: Bool) {
        model.isFavorites = isFavorites
        ECDManager.saveContextAndWait()
    }
    
    func getRatesDataModels() -> [RatesDataModel] {
        guard let ratesDataModels = ECDManager.fetchObjects(type: RatesDataModel.self) else { return [RatesDataModel]() }
        return ratesDataModels
    }
    
    func getFavoritesRatesDataModels() -> [RatesDataModel] {
        let predicate = NSPredicate(format: "isFavorites == true")
        let ratesDataModels = ECDManager.fetchObjects(type: RatesDataModel.self, predicate: predicate)
        return ratesDataModels ?? []
    }
}
