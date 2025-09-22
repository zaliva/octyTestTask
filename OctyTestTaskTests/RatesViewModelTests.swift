import XCTest
@testable import OctyTestTask

private final class MockView: NSObject, RatesViewControllerProtocol {
    var updateCount = 0
    var lastError: ApiError?
    func updateCollectionView(animating: Bool) { updateCount += 1 }
    func showError(error: ApiError) { lastError = error }
}

final class RatesViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        ECDManager.reset()
        ECDManager.loadPersistentStores()
        ECDManager.deleteObjects(type: RatesDataModel.self)
    }

    func seed(_ models: [ResponceRatesModel]) -> [RatesDataModel] {
        RatesDataProvider.insertAndUpdateArrayRatesModel(models)
    }

    func test_getRatesFormCoreData_forList_loadsAll() {
        let _ = seed([
            .init(baseCurrency: "BTC", quoteCurrency: "USD", quote: 65000, date: "2024-05-10"),
            .init(baseCurrency: "ETH", quoteCurrency: "USD", quote: 3000, date: "2024-05-10"),
        ])
        let view = MockView()
        let vm = RatesViewModel(view: view, type: .list)

        vm.getRatesFormCoreData()
        XCTAssertEqual(vm.ratesModels.count, 2)
        XCTAssertEqual(view.updateCount, 1)
    }

    func test_getRatesFormCoreData_forFavorites_loadsOnlyFavorites() {
        let saved = seed([
            .init(baseCurrency: "BTC", quoteCurrency: "USD", quote: 65000, date: "2024-05-10"),
            .init(baseCurrency: "ETH", quoteCurrency: "USD", quote: 3000, date: "2024-05-10"),
        ])
        if let btc = saved.first(where: { $0.baseCurrency == "BTC" }) {
            RatesDataProvider.addOrRemoveFavorites(btc, isFavorites: true)
        }

        let view = MockView()
        let vm = RatesViewModel(view: view, type: .favorites)
        vm.getRatesFormCoreData()

        XCTAssertEqual(vm.ratesModels.count, 1)
        XCTAssertEqual(vm.ratesModels.first?.baseCurrency, "BTC")
        XCTAssertEqual(view.updateCount, 1)
    }

    func test_addOrRemoveFavorites_toggles_inList() {
        let saved = seed([
            .init(baseCurrency: "BTC", quoteCurrency: "USD", quote: 65000, date: "2024-05-10")
        ])
        let view = MockView()
        let vm = RatesViewModel(view: view, type: .list)
        vm.ratesModels = saved

        let model = saved[0]
        let original = model.isFavorites
        let id = model.id
        vm.addOrRemoveFavorites(model: model)

        XCTAssertEqual(vm.ratesModels.count, 1)
        let reloaded = vm.ratesModels.first { $0.id == id }
        XCTAssertNotNil(reloaded)
        XCTAssertEqual(reloaded?.isFavorites, !original)
        XCTAssertEqual(view.updateCount, 1)
    }

    func test_addOrRemoveFavorites_removes_fromFavoritesList() {
        let saved = seed([
            .init(baseCurrency: "BTC", quoteCurrency: "USD", quote: 65000, date: "2024-05-10")
        ])
        if let btc = saved.first { RatesDataProvider.addOrRemoveFavorites(btc, isFavorites: true) }

        let view = MockView()
        let vm = RatesViewModel(view: view, type: .favorites)
        vm.ratesModels = RatesDataProvider.getFavoritesRatesDataModels()
        XCTAssertEqual(vm.ratesModels.count, 1)

        let model = vm.ratesModels[0]
        vm.addOrRemoveFavorites(model: model)
        XCTAssertEqual(vm.ratesModels.count, 0)
        XCTAssertTrue(RatesDataProvider.getFavoritesRatesDataModels().isEmpty)
        XCTAssertEqual(view.updateCount, 1)
    }
}


