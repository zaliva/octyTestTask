import XCTest
import CoreData
@testable import OctyTestTask

final class RatesDataProviderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        ECDManager.reset()
        ECDManager.loadPersistentStores()
        ECDManager.deleteObjects(type: RatesDataModel.self)
    }

    func test_insertAndUpdateArray_createsEntities_andPersists() {
        let models = [
            ResponceRatesModel(baseCurrency: "BTC", quoteCurrency: "USD", quote: 65000.0, date: "2024-05-10"),
            ResponceRatesModel(baseCurrency: "ETH", quoteCurrency: "USD", quote: 3000.0, date: "2024-05-10")
        ]

        let saved = RatesDataProvider.insertAndUpdateArrayRatesModel(models)
        XCTAssertEqual(saved.count, 2)

        let fetched = RatesDataProvider.getRatesDataModels()
        XCTAssertEqual(fetched.count, 2)
    }

    func test_insertAndUpdate_sameCurrency_updatesExisting_notDuplicate() {
        let m1 = ResponceRatesModel(baseCurrency: "BTC", quoteCurrency: "USD", quote: 60000.0, date: "2024-05-09")
        let m2 = ResponceRatesModel(baseCurrency: "BTC", quoteCurrency: "USD", quote: 61000.0, date: "2024-05-10")

        _ = RatesDataProvider.insertAndUpdateArrayRatesModel([m1])
        let first = RatesDataProvider.getRatesDataModels()
        XCTAssertEqual(first.count, 1)

        _ = RatesDataProvider.insertAndUpdateArrayRatesModel([m2])
        let second = RatesDataProvider.getRatesDataModels()
        XCTAssertEqual(second.count, 1)
        XCTAssertEqual(second.first?.quote, 61000.0)
        XCTAssertEqual(second.first?.date, "2024-05-10")
    }

    func test_favorites_add_and_fetchFavorites() {
        let models = [
            ResponceRatesModel(baseCurrency: "BTC", quoteCurrency: "USD", quote: 65000.0, date: "2024-05-10"),
            ResponceRatesModel(baseCurrency: "ETH", quoteCurrency: "USD", quote: 3000.0, date: "2024-05-10")
        ]
        let saved = RatesDataProvider.insertAndUpdateArrayRatesModel(models)
        XCTAssertEqual(saved.count, 2)

        guard let btc = saved.first(where: { $0.baseCurrency == "BTC" }) else {
            return XCTFail("Missing BTC model")
        }
        RatesDataProvider.addOrRemoveFavorites(btc, isFavorites: true)

        let favorites = RatesDataProvider.getFavoritesRatesDataModels()
        XCTAssertEqual(favorites.count, 1)
        XCTAssertTrue(favorites.first?.isFavorites == true)
        XCTAssertEqual(favorites.first?.baseCurrency, "BTC")
    }
}


